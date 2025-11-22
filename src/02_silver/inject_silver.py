# %%
import duckdb
from pathlib import Path

# Define paths
base_dir = Path.cwd().parent.parent
data_path = base_dir / "data" / "raw" / "sih" / "**" / "*.parquet"
sql_query_dir = base_dir / "src" / "02_silver" 

# Open the connection with the data base
duckdb_file = base_dir / "sih_sus.duckdb"
con = duckdb.connect(str(duckdb_file))

# %%
sql_scripts = [
    ("silver.sih_sus", "sih_sus_silver.sql", {"{{data_path}}": str(data_path)}),
    ("silver.uf_localidade", "uf_localidade_silver.sql", {}),
    ("silver.cid10_icsap", "cid10_icsap_silver.sql", {}),
    ("silver.sih_bed_speciality", "sih_bed_speciality_silver.sql", {}),
    ("silver.sih_complexity", "sih_complexity_silver.sql", {}),
    ("silver.sih_procedures", "sih_procedures_silver.sql", {})
]

# %%
for table_name, filename, substitutions in sql_scripts:
    query_path = sql_query_dir / filename

    with open(query_path, "r", encoding= "utf-8") as f:
        query = f.read()
    
    for key, value in substitutions.items():
        query = query.replace(key, value)

    con.execute(f"""
        CREATE OR REPLACE TABLE {table_name} AS
        {query}
    """)

# %%
con.sql("""
    SELECT table_schema, table_name
    FROM information_schema.tables
    WHERE table_type = 'BASE TABLE'
""").df()

# %%
con.close()