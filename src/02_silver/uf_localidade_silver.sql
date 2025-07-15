
-- Aplie some type casting for optimization
-- and english readable names
SELECT
    CAST(codigo_uf AS SMALLINT) AS state_code,
    CAST(nome_estado AS VARCHAR) AS state_name,
    CAST(regiao_br AS VARCHAR) AS big_region_name

FROM bronze.uf_localidade