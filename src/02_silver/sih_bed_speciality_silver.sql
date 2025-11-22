-- Aplie some type casting for optimization,
-- english readable names
-- and lowercase
SELECT
    CAST(LEITO AS SMALLINT) AS bed_speciality_code,
    LOWER(CAST(DESCRICAO AS VARCHAR)) AS bed_speciality_description

FROM bronze.sih_bed_speciality