
-- Reads raw data from parquet files, filters out childbirth records,
-- and apllies initial type casting for optimization
SELECT
    CAST(ANO_CMPT AS SMALLINT) AS year,
-- Keep only the two first digits which correspond to brazilian UF code form IBGE
    CAST(LEFT(UF_ZI, 2) AS SMALLINT) AS state_code,
    CAST(DIAS_PERM AS SMALLINT) AS length_stay,
-- Change for more readeble names    
    CASE
        WHEN SEXO = '1' THEN 'male'
        WHEN SEXO = '3' THEN 'female'
        ELSE 'unknown'
    END AS gender,
    CAST(IDADE AS SMALLINT) AS age,
    CAST(DIAG_PRINC AS VARCHAR) AS disease_code,
    VAL_SH AS amount_paid,
    VAL_TOT AS total_paid,
    US_TOT AS us_total_paid
FROM read_parquet('{{data_path}}', union_by_name = True)
WHERE NOT (
    DIAG_PRINC BETWEEN '080' AND '084' OR
    DIAG_PRINC BETWEEN '0800' AND '0809' OR
    DIAG_PRINC BETWEEN '0810' AND '0815' OR
    DIAG_PRINC BETWEEN '0820' AND '0829' OR
    DIAG_PRINC BETWEEN '0830' AND '0839' OR
    DIAG_PRINC BETWEEN '0840' AND '0849'
)
