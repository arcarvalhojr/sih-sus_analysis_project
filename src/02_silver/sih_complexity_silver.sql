-- Aplie some type casting for optimization,
-- english readable names
-- and lowercase
SELECT
    CAST(NIVEL_ATENCAO AS SMALLINT) AS complexity_code,
    LOWER(CAST(DESCRICAO AS VARCHAR)) AS complexity_description,
    CAST(TIPO AS SMALLINT) AS complexity_type_code,
    LOWER(CAST(DESCRICAO_TIPO AS VARCHAR)) AS complexity_type_description

FROM bronze.sih_complexity