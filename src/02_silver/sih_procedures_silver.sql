-- Aplie some type casting for optimization,
-- english readable names
-- and lowercase
SELECT
    CAST(IP_COD AS VARCHAR) AS procedure_code,
    LOWER(CAST(IP_DSCR AS VARCHAR)) AS procedure_description

FROM bronze.sih_procedures 