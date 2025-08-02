/*
LAST YEAR REGION-LEVEL PROFILE
Calculated metrics:
- Total hospitalization and associated costs per region and avoidable disease classification
- Average cost and lenght of stay per region and avoidable disease classification
*/

WITH base AS (
      SELECT
          uf.big_region_name,
          cid.disease_category,

          COUNT(*) AS total_hospitalizations,
          ROUND(SUM(sih.total_paid), 2) AS total_cost,

          ROUND(AVG(sih.total_paid), 2) AS avg_cost,
          ROUND(AVG(sih.length_stay), 2) AS avg_length_stay,

      FROM silver.sih_sus AS sih
      LEFT JOIN silver.cid10_icsap AS cid
            ON sih.disease_code = cid.avoidable_disease_code
      LEFT JOIN silver.uf_localidade AS uf
            ON sih.state_code = uf.state_code
      WHERE sih.year = 2024
            AND cid.avoidable_disease_code IS NOT NULL
      GROUP BY uf.big_region_name, cid.disease_category

)
SELECT *
FROM base
ORDER BY big_region_name, total_hospitalizations
