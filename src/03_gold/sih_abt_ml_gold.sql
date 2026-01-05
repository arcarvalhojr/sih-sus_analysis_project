/*
ANALYTICAL BASE TABLE
- Prepare data for ML
- Remove duplicated values in each month
- Consolidate hospitalizations
- Join with auxiliary tables
*/

WITH base_tbl AS (
    SELECT
        sih.id_hospitalization,
        sih.year,
        sih.month,
        MAKE_DATE(sih.year, sih.month, 1) AS date_competence,
        sih.state_code,
        sih.gender,
        sih.age,
        icsap.disease_category,
        sih.complexity_code,
        CASE
            WHEN sih.bed_speciality_code = 'Leito Dia / Geriatria' THEN '72'
            WHEN sih.bed_speciality_code = 'Leito Dia / Intercorrência Pós-Transplante' THEN '71'
            WHEN sih.bed_speciality_code = 'Leito Dia / Aids' THEN '69'
            ELSE sih.bed_speciality_code 
        END AS bed_speciality_code,
        sih.requested_procedure_code,
        sih.length_stay,
        CAST(sih.death_flag AS SMALLINT) AS death_flag
    FROM silver.sih_sus AS sih
    INNER JOIN silver.cid10_icsap AS icsap
        ON sih.disease_code = icsap.avoidable_disease_code
    WHERE sih.year IN (2022, 2023, 2024)
        AND sih.total_cost > 0
),
unique_month AS (
    SELECT
        base.id_hospitalization,
        base.date_competence,
        ANY_VALUE(base.year) AS year,
        ANY_VALUE(base.month) AS month,
        MIN(base.age) AS age,
        ANY_VALUE(base.gender) AS gender,
        ANY_VALUE(base.state_code) AS state_code,
        ANY_VALUE(base.disease_category) AS disease_category,
        ANY_VALUE(base.requested_procedure_code) AS requested_procedure_code,
        ANY_VALUE(base.complexity_code) AS complexity_code,
        ANY_VALUE(base.bed_speciality_code) AS bed_speciality_code,
        MAX(base.length_stay) AS total_hosp_days,
        MAX(base.death_flag) AS death_flag
    FROM base_tbl AS base
    GROUP BY base.id_hospitalization, base.date_competence 
),
aggregated AS (
    SELECT
        um.id_hospitalization,
        ARG_MIN(um.year, um.date_competence) AS year,
        ARG_MIN(um.month, um.date_competence) AS month,
        ARG_MIN(um.state_code, um.date_competence) AS state_code,
        ARG_MIN(um.gender, um.date_competence) AS gender,
        ARG_MIN(um.age, um.date_competence) AS age,
        ARG_MIN(um.disease_category, um.date_competence) AS disease_category,
        ARG_MIN(um.complexity_code, um.date_competence) AS complexity_code,
        ARG_MIN(um.bed_speciality_code, um.date_competence) AS bed_speciality_code,
        ARG_MIN(um.requested_procedure_code, um.date_competence) AS requested_procedure_code,
        MAX(um.total_hosp_days) AS total_hosp_days,
        MAX(um.death_flag) AS death_flag
    FROM unique_month AS um
    GROUP BY um.id_hospitalization
)
SELECT
    agg.id_hospitalization,
    agg.year,
    agg.month,
    uf.big_region_name,
    agg.gender,
    agg.age, 
    agg.disease_category,
    sbs.bed_speciality_description AS bed_speciality,
    shc.complexity_description AS complexity,
    shp.procedure_description AS procedure,
    agg.total_hosp_days,
    agg.death_flag
FROM aggregated AS agg
LEFT JOIN silver.uf_localidade AS uf
    ON agg.state_code = uf.state_code
LEFT JOIN silver.sih_bed_speciality AS sbs
    ON agg.bed_speciality_code = sbs.bed_speciality_code
LEFT JOIN silver.sih_complexity AS shc
    ON agg.complexity_code = shc.complexity_code
LEFT JOIN silver.sih_procedures AS shp
    ON agg.requested_procedure_code = shp.procedure_code