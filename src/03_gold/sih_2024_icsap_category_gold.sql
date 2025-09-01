/*
2024 DISEASE CATEGORY PROFILE
Calculated metrics:
- Total hospitalizations and associated costs per avoidable disease category  
- Average cost and average length of stay per avoidable disease category
*/

SELECT
      sih.year,
      cid.disease_category,

      COUNT(*) AS total_hospitalizations,
      ROUND(SUM(sih.total_paid), 2) AS total_cost,

      ROUND(AVG(sih.total_paid), 2) AS avg_cost,
      ROUND(AVG(sih.length_stay), 2) AS avg_length_stay

FROM silver.sih_sus AS sih
LEFT JOIN silver.cid10_icsap AS cid
      ON sih.disease_code = cid.avoidable_disease_code
WHERE sih.year IN (2014, 2024)
      AND cid.avoidable_disease_code IS NOT NULL
      AND sih.total_paid > 0
GROUP BY sih.year, cid.disease_category

