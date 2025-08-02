# %%
import duckdb
from pathlib import Path

# Define paths
base_dir = Path.cwd().parent.parent
sql_query_dir = base_dir / "src" / "03_gold"

# Open connection with the database
duckdb_file = base_dir / "sih_sus.duckdb"
con = duckdb.connect(str(duckdb_file))

# %%
sql_scripts = [
    ("gold.sih_by_year", "sih_by_year_gold.sql", {}),
    ("gold.sih_by_region", "sih_by_region_gold.sql", {}),
    ("gold.sih_last_year", "sih_last_year_gold.sql", {}),
    ("gold.sih_last_year_region", "sih_last_year_region_gold.sql", {})
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