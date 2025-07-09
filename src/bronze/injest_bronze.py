# %%
import duckdb

# Open the connection with the data base
con = duckdb.connect("../../sih_sus.duckdb")
con.execute("SET SCHEMA 'bronze'")

# %%
# Load the localidade file into the bronze schema
con.execute(f"""
    CREATE OR REPLACE TABLE bronze.localidade AS
    SELECT
        CAST(codigo_ibge_cidade AS INTEGER) AS codigo_ibge_cidade,
        nome_cidade,
        CAST(codigo_uf AS INTEGER) AS codigo_uf,
        sigla_uf,
        nome_estado
    FROM read_parquet('../../data/localidade.parquet')
""")

localidade_result = con.sql('SELECT * FROM localidade LIMIT 10').df()
localidade_result

# %%
# Load the cid10_icsap file into the bronze schema
con.execute(f"""
    CREATE OR REPLACE TABLE bronze.cid10_icsap AS
    SELECT * 
    FROM read_csv_auto('../../data/cid10_icsap.csv', header= True)
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