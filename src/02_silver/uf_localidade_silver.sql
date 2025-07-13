
-- Aplie some type casting for optimization
-- and english readable names
SELECT
    nome_estado AS state_name,
    CAST(codigo_uf AS SMALLINT) AS state_code

FROM bronze.uf_localidade