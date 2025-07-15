# %%
from pathlib import Path
import duckdb

# Define paths
base_dir = Path.cwd().parent.parent
uf_localidade_path = base_dir / "data" / "localidade_ufs.csv"
cid10_icsap_path = base_dir / "data" / "cid10_icsap.csv"
db_path = base_dir / "sih_sus.duckdb"

# Open the connection with the data base
con = duckdb.connect(str(db_path))
con.execute("SET SCHEMA 'bronze'")

# %%
# Load the uf codes file into the bronze schema
con.execute(f"""
    CREATE OR REPLACE TABLE bronze.uf_localidade AS
    SELECT
        codigo_uf,
        nome_estado,
        regiao_br
    FROM read_csv_auto('{uf_localidade_path}')
""")

localidade_result = con.sql('SELECT * FROM uf_localidade').df()
localidade_result

# %%
# Load the cid10_icsap file into the bronze schema
con.execute(f"""
    CREATE OR REPLACE TABLE bronze.cid10_icsap AS
    SELECT
        Categoria,
        Diagnostico,
        CID10
    FROM read_csv_auto('{cid10_icsap_path}')
""")

cid10_icsap_result = con.sql('SELECT * FROM cid10_icsap LIMIT 10').df()
cid10_icsap_result

# %%
# Check if all tables were created
con.sql("""
    SELECT table_schema, table_name
    FROM information_schema.tables
    WHERE table_type = 'BASE TABLE'
""").df()

# %%
con.close()