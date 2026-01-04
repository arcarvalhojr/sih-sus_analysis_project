/*
2024 REGIONAL DISEASE PROFILE
Calculated metrics:
- Total avoidable hospitalizations and associated costs by state, macroregion, and disease category  
- Average cost per hospitalization across geographic and clinical dimensions
*/

SELECT
      sih.year,
      uf.big_region_name,
      uf.state_name,
      icsap.disease_category,

      COUNT(*) AS total_hospitalizations,
      SUM(sih.total_cost) AS total_cost,
      ROUND(AVG(sih.total_cost), 2) AS avg_total_cost

FROM silver.sih_sus_eda_clean AS sih
LEFT JOIN silver.cid10_icsap AS icsap
      ON sih.disease_code = icsap.avoidable_disease_code
LEFT JOIN silver.uf_localidade AS uf
      ON sih.state_code = uf.state_code
WHERE sih.year IN (2014, 2024)
      AND icsap.avoidable_disease_code IS NOT NULL
GROUP BY sih.year, uf.big_region_name, uf.state_name, icsap.disease_category