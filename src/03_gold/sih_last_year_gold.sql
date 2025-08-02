/*
LAST YEAR POPULATION-LEVEL PROFILE
Calculated metrics:
- Avoidable hospitalizations segmented by age group, state and disease category
- Cost patterns based on clinical and demographic characteristics
*/

SELECT 
      uf.big_region_name,
      uf.state_name,
      CASE
        WHEN sih.age < 5 THEN '0-4'
        WHEN sih.age BETWEEN 5 AND 14 THEN '5-14'
        WHEN sih.age BETWEEN 15 AND 24 THEN '15-24'
        WHEN sih.age BETWEEN 25 AND 44 THEN '25-44'
        WHEN sih.age BETWEEN 45 AND 64 THEN '45-64'
        ELSE '65+'
      END AS age_group,
      cid.disease_category,

      COUNT(*) AS total_hospitalizations,
      SUM(sih.total_paid) AS total_cost,
      ROUND(AVG(sih.total_paid), 2) AS avg_total_cost,
      ROUND(AVG(sih.length_stay), 2) AS avg_length_stay

FROM silver.sih_sus AS sih
LEFT JOIN silver.cid10_icsap AS cid
      ON sih.disease_code = cid.avoidable_disease_code
LEFT JOIN silver.uf_localidade AS uf
      ON sih.state_code = uf.state_code
WHERE sih.year = 2024
      AND cid.avoidable_disease_code IS NOT NULL
GROUP BY ALL