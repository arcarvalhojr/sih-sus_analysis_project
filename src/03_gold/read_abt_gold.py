# %%
from pathlib import Path
import duckdb

# define paths
base_dir = Path.cwd().parent.parent
query_file = Path("sih_abt_ml_gold.sql")
duckdb_path = base_dir / "sih_sus.duckdb"
output_dir = base_dir / "data" / "tables_gold" / "sih_sus_abt.parquet"

# %%
# Open the connection with the data base
con = duckdb.connect(str(duckdb_path))

# %%
# Read and create the table
with open(query_file, "r", encoding="utf-8") as f:
    query = f.read()

    con.execute(f"""
    COPY (
            {query}            
    )
    TO '{output_dir}'
    (FORMAT 'parquet');
    """)
