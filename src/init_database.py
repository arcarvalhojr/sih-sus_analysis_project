# %%
import duckdb


# Create a DuckDB data base
con = duckdb.connect("../sih_sus.duckdb")

# Create schemas
con.execute("CREATE SCHEMA IF NOT  EXISTS bronze")
con.execute("CREATE SCHEMA IF NOT  EXISTS silver")
con.execute("CREATE SCHEMA IF NOT  EXISTS gold")

con.close()