# %%
from pathlib import Path
import duckdb
import pandas as pd

# Define paths
base_dir = Path.cwd().parent.parent
sih_procedures_path = base_dir / "data" / "raw" / "sp_procrea.csv"
sih_dictionary_path = base_dir / "data" / "raw" / "SCNES_DOMINIOS.xls"
uf_localidade_path = base_dir / "data" / "raw" / "localidade_ufs.csv"
cid10_icsap_path = base_dir / "data" / "raw" / "cid10_icsap.csv"
db_path = base_dir / "sih_sus.duckdb"

# Open the connection with the data base
con = duckdb.connect(str(db_path))

# %%
# Load sih_procedures table into the bronze schema
con.execute(f"""
    CREATE OR REPLACE TABLE bronze.sih_procedures AS
    SELECT
        IP_COD,
        IP_DSCR
    FROM read_csv_auto('{sih_procedures_path}')
""")

# %%
# Load the uf codes table into the bronze schema
con.execute(f"""
    CREATE OR REPLACE TABLE bronze.uf_localidade AS
    SELECT
        codigo_uf,
        nome_estado,
        regiao_br
    FROM read_csv_auto('{uf_localidade_path}')
""")

# %%
# Load the cid10_icsap table into the bronze schema
con.execute(f"""
    CREATE OR REPLACE TABLE bronze.cid10_icsap AS
    SELECT
        Categoria,
        Diagnostico,
        CID10
    FROM read_csv_auto('{cid10_icsap_path}')
""")

# %%
# Read tables from sih_dictionary
sheets = ["LEITOS", "NÍVEL DE ATENÇAO"]

tables = pd.read_excel(sih_dictionary_path, sheet_name=sheets)
sheet_names = {
    "LEITOS": "sih_bed_speciality",
    "NÍVEL DE ATENÇAO": "sih_complexity"
}

for sheet_name, tbls in tables.items():
    table_name = sheet_names[sheet_name]
    con.execute(f"""
                CREATE OR REPLACE TABLE bronze.{table_name} AS SELECT * 
                FROM tbls
    """)

# %%
# Check if all tables were created
con.sql("""
    SELECT table_schema, table_name
    FROM information_schema.tables
    WHERE table_type = 'BASE TABLE'
""").df()

# %%
con.close()