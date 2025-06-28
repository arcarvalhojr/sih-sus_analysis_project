# %%
import duckdb
import os

# Open the connection with the data base
con = duckdb.connect("../../sih_sus.duckdb")
con.execute("SET SCHEMA 'bronze'")

# %%
# Load sih sus data into the bronze schema
sih_path = os.path.join("../../data/sih", "**", "*.parquet").replace("\\", "/")

sih_columns = [
    'ANO_CMPT', 'UF_ZI', 'MUNIC_RES', 'DIAS_PERM', 'SEXO',
    'IDADE', 'DIAG_PRINC', 'VAL_SH', 'VAL_TOT', 'US_TOT'
]
columns_str = ", ".join(sih_columns)

con.execute(f"""
    CREATE OR REPLACE TABLE bronze.sih_sus AS
    SELECT {columns_str}
    FROM read_parquet('{sih_path}', union_by_name= True)
""")

# %%
sih_sus_result = con.sql(f'''
    SELECT 
        ANO_CMPT,
        COUNT (*) AS Total_registros,
        SUM(VAL_TOT) AS Total_gastos
    FROM sih_sus
    GROUP BY ANO_CMPT
    ORDER BY ANO_CMPT
''').df()
sih_sus_result

# %%
# Load the localidade file into the bronze schema
con.execute(f"""
    CREATE OR REPLACE TABLE bronze.localidade AS
    SELECT * FROM read_parquet('../../data/localidade.parquet')
""")

localidade_result = con.sql('SELECT * FROM localidade LIMIT 10').df()
localidade_result

# %%
# Load the cid10_icsap file into the bronze schema
con.execute(f"""
    CREATE OR REPLACE TABLE bronze.cid10_icsap AS
    SELECT * FROM read_csv_auto('../../data/cid10_icsap.csv', header= True)
""")

cid10_icsap_result = con.sql('SELECT * FROM cid10_icsap LIMIT 10').df()
cid10_icsap_result

# %%
# Last check if all tables were created
con.sql("""
    SELECT table_schema, table_name
    FROM information_schema.tables
    WHERE table_type = 'BASE TABLE'
""").df()

# %%
con.close()