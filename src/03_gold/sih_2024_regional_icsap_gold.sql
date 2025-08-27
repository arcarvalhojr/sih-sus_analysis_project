/*
2024 REGIONAL DISEASE PROFILE
Calculated metrics:
- Total avoidable hospitalizations and associated costs by state, macroregion, and disease category  
- Average cost per hospitalization across geographic and clinical dimensions
*/

SELECT 
      uf.big_region_name,
      uf.state_name,
      cid.disease_category,

      COUNT(*) AS total_hospitalizations,
      SUM(sih.total_paid) AS total_cost,
      ROUND(AVG(sih.total_paid), 2) AS avg_total_cost,

FROM silver.sih_sus AS sih
LEFT JOIN silver.cid10_icsap AS cid
      ON sih.disease_code = cid.avoidable_disease_code
LEFT JOIN silver.uf_localidade AS uf
      ON sih.state_code = uf.state_code
WHERE sih.year = 2024
      AND cid.avoidable_disease_code IS NOT NULL
      AND sih.total_paid > 0
GROUP BY ALL