# %%
import requests
from bs4 import BeautifulSoup
import pandas as pd
from io import StringIO
import re
# %%
# Fetch and Parse the Web Page
url = "https://bvsms.saude.gov.br/bvs/saudelegis/sas/2008/prt0221_17_04_2008.html"
response = requests.get(url) # Send a GET request to the URL from the Brazilian Ministry of Health
response.encoding = "ISO-8859-1"
soup = BeautifulSoup(response.text, "html.parser") # Parse the HTML content of the page

table_html = str(soup.find_all("table")[0]) # Find the first table in the HTML document, which contains the data we need
df_raw = pd.read_html(StringIO(table_html), encoding="ISO-8859-1")[0]

# The raw table has a malformed header
df_raw.columns = df_raw.iloc[1]
df = df_raw.drop(index=[0, 1]).reset_index(drop=True) # Promote the second row (index 1) to be the new header

# The CID-10 codes appear in two columns. We only need one. Drop the first one.
df.columns = ["Grupo", "Diagnostico", "CID10_A", "CID10_B"]
df = df.drop(columns=["CID10_A"])
df = df.rename(columns={"CID10_B": "CID10"})


df["Categoria"] = None # Initialize a new 'Categoria' column with null values

# This loop iterates through the DataFrame to assign a category to each diagnosis
categoria_atual = None
for i, row in df.iterrows():
    #  row is identified as a category header if the 'Diagnostico' and 'CID10' values are identical
    if row["Diagnostico"] == row["CID10"]:  
        categoria_atual = row["Diagnostico"]
        df.at[i, "Categoria"] = categoria_atual
    # For all regular diagnosis rows, assign the last found category
    else:
        df.at[i, "Categoria"] = categoria_atual 

# Now that the category information is propagated to all rows, we can remove
# the original category header rows, which are now redundant.
df = df[df["Diagnostico"] != df["CID10"]].reset_index(drop=True)

df2 = df[["Grupo", "Categoria", "Diagnostico", "CID10"]]
df2

# %%
# Function to expand CID-10 code ranges into individual codes
def expand_cid10(cid_string):
    if pd.isna(cid_string):
        return []

    # Standardize text formatting
    text = cid_string.upper().replace(';', ',').replace(' A ', ' a ')  
    codigos = set()

    # Expand CID ranges with decimals (e.g., A15.0 to A15.3 → A150, A151, A152, A153)
    text = re.sub(
        r'([A-Z]\d{2})\.(\d{1,2})\s+a\s+([A-Z]\d{2})\.(\d{1,2})',
        lambda m: ','.join(
            f"{m.group(1)}{i}" for i in range(int(m.group(2)), int(m.group(4)) + 1)
        ),
        text
    )

    # Expand ranges without decimals (e.g., A15 to A19 → A15, A16, A17, A18, A19)
    text = re.sub(
        r'([A-Z])(\d{2})\s+a\s+([A-Z])(\d{2})',
        lambda m: ','.join(
            f"{m.group(1)}{i:02d}" for i in range(int(m.group(2)), int(m.group(4)) + 1)
        ),
        text
    )

     # Extract all valid CID-10 codes
    for part in re.split(r'[,\s]+', text):
        part = part.strip().replace('.', '')
        if re.fullmatch(r'[A-Z]\d{2,4}', part):
            codigos.add(part)

    return sorted(codigos)

# Create one new record per individual code,
# preserving the associated 'Categoria' and 'Diagnostico' information
registros = []

for _, row in df2.iterrows():
    cid_expandidos = expand_cid10(row["CID10"])
    for cid in cid_expandidos:
        registros.append({
            "Categoria": row["Categoria"],
            "Diagnostico": row["Diagnostico"],
            "CID10": cid
        })

df_exp = pd.DataFrame(registros)
df_exp

# %%
# Save into a csv file
df_exp.to_csv("./data/cid10_icsap.csv", index=False, encoding="utf-8")
