/*
YEAR-LEVEL INSIGHTS
Calculated metrics:
- Total hospitalizations and breakdown by avoidable vs. non-avoidable diseases  
- Proportion (%) of avoidable hospitalizations relative to total  
- Total expenditures and cost segmentation by avoidable vs. non-avoidable diseases  
- Proportion (%) of avoidable hospitalization costs relative to total expenditures
*/

SELECT
    sih.year,

    COUNT(*) AS total_hospitalizations,
    COUNT(CASE
              WHEN icsap.avoidable_disease_code IS NULL THEN 1
          END) AS total_non_icsap,
    COUNT(icsap.avoidable_disease_code) AS total_icsap,
    ROUND(COUNT(icsap.avoidable_disease_code) * 100.0 / COUNT(*), 2) AS rate_icsap,
    
    ROUND(SUM(sih.total_cost), 2) AS total_cost,
    ROUND(SUM(CASE 
                  WHEN icsap.avoidable_disease_code IS NULL THEN sih.total_cost 
                  ELSE 0 
              END), 2) AS non_icsap_cost,
    ROUND(SUM(CASE 
                  WHEN icsap.avoidable_disease_code IS NOT NULL THEN sih.total_cost 
                  ELSE 0 
              END), 2) AS icsap_cost,
    ROUND(COUNT(CASE
                    WHEN icsap.avoidable_disease_code IS NOT NULL THEN sih.total_cost
                    ELSE 0
                END) * 100.0 / SUM(sih.total_cost), 2) AS rate_icsap_cost

FROM silver.sih_sus_eda_clean AS sih
LEFT JOIN silver.cid10_icsap AS icsap
    ON sih.disease_code = icsap.avoidable_disease_code
LEFT JOIN silver.uf_localidade AS uf
    ON sih.state_code = uf.state_code
GROUP BY sih.year
ORDER BY sih.year    