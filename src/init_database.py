# %%
from pathlib import Path
import duckdb

# Define the path for the database
base_dir = Path.cwd().parent
db_path = base_dir / "sih_sus.duckdb"

# %%
# Create a DuckDB data base
con = duckdb.connect(str(db_path))

# Create schemas
con.execute("CREATE SCHEMA IF NOT  EXISTS bronze")
con.execute("CREATE SCHEMA IF NOT  EXISTS silver")
con.execute("CREATE SCHEMA IF NOT  EXISTS gold")

con.close()