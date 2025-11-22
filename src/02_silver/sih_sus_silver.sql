
-- Reads raw data from parquet files, filters out childbirth records,
-- and apllies initial type casting for optimization
SELECT
    CAST(N_AIH AS VARCHAR) AS id_hospitalization,
    CAST(ANO_CMPT AS SMALLINT) AS year,
    CAST(MES_CMPT AS SMALLINT) AS month,
-- Keep only the two first digits which correspond to brazilian UF code form IBGE
    CAST(LEFT(UF_ZI, 2) AS SMALLINT) AS state_code,
    CAST(IDADE AS SMALLINT) AS age,
-- Change for more readeble names    
    CASE
        WHEN SEXO IN ('1', 'Masculino') THEN 'Male'
        WHEN SEXO IN ('3', 'Feminino') THEN 'Female'
        ELSE 'unknown'
    END AS gender,
    CAST(RACA_COR AS SMALLINT) AS race_color_code,   
    CAST(DIAG_PRINC AS VARCHAR) AS disease_code,
    CAST(CAR_INT AS SMALLINT) AS hospitalization_type_code,
    CAST(COMPLEX AS SMALLINT) AS complexity_code,
    CAST(ESPEC AS VARCHAR) AS bed_speciality_code,
    CAST(PROC_SOLIC AS VARCHAR) AS requested_procedure_code,
    CAST(DIAS_PERM AS SMALLINT) AS length_stay,
    CAST(VAL_TOT AS DECIMAL(14, 2)) AS total_cost,
    CASE
        WHEN CAST(MORTE AS VARCHAR) IN ('1', 'Sim') THEN 1
        ELSE 0
    END AS death_flag

FROM read_parquet('{{data_path}}', union_by_name = True)
WHERE LEFT(DIAG_PRINC, 3) NOT BETWEEN 'O80' AND 'O84'
