# %%
import requests
from bs4 import BeautifulSoup
import pandas as pd
from io import StringIO
from pathlib import Path

# %%
# Define path
base_dir = Path.cwd().parent.parent
data_dir = base_dir / "data"

# %%
# Fetch and Parse the Web Page
url = "https://www.ibge.gov.br/explica/codigos-dos-municipios.php"
response = requests.get(url) # Send a GET request to the URL
response.encoding = "UTF-8"

# Parse the HTML content of the page
soup = BeautifulSoup(response.text, "html.parser") 
tb_html = str(soup.find("table"))

df = pd.read_html(StringIO(tb_html))[0]
df

# %%
# Get the ufs code in a new column
df["codigo_uf"] = df["Códigos"].str.extract(r"(\d+)")

df_final = df.rename(columns={"UFs": "nome_estado"}
                         ).drop("Códigos", axis=1)
df_final

# %%
# Map the brazilian regions according to the official IBGE rules 
regions = {
    '1': 'Norte',
    '2': 'Nordeste',
    '3': 'Sudeste',
    '4': 'Sul',
    '5': 'Centro-Oeste'
}

df_final['regiao_br'] = df_final['codigo_uf'].str[0].map(regions)
df_final

# %%
df_path = data_dir / "localidade_ufs.csv"
df_final.to_csv(df_path, index=False, encoding="utf-8-sig")