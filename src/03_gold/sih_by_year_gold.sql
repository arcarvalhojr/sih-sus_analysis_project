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
              WHEN cid.avoidable_disease_code IS NULL THEN 1
          END) AS non_avoidable_disease_hosp,
    COUNT(CASE
              WHEN cid.avoidable_disease_code IS NOT NULL THEN 1
          END) AS avoidable_disease_hosp,
    ROUND(COUNT(CASE 
                    WHEN cid.avoidable_disease_code IS NOT NULL THEN 1 
                END) * 100.0 / COUNT(*), 2) AS tx_avoidable_disease,
    
    ROUND(SUM(sih.total_paid), 2) AS total_cost,
    ROUND(SUM(CASE 
                  WHEN cid.avoidable_disease_code IS NULL THEN sih.total_paid 
                  ELSE 0 
              END), 2) AS non_avoidable_disease_cost,
    ROUND(SUM(CASE 
                  WHEN cid.avoidable_disease_code IS NOT NULL THEN sih.total_paid 
                  ELSE 0 
              END), 2) AS avoidable_disease_cost,
    ROUND(COUNT(CASE
                    WHEN cid.avoidable_disease_code IS NOT NULL THEN sih.total_paid
                    ELSE 0
                END) * 100.0 / SUM(sih.total_paid), 2) AS tx_avoidable_disease_cost

FROM silver.sih_sus AS sih
LEFT JOIN silver.cid10_icsap AS cid
    ON sih.disease_code = cid.avoidable_disease_code
LEFT JOIN silver.uf_localidade AS uf
    ON sih.state_code = uf.state_code
WHERE sih.total_paid > 0
GROUP BY sih.year
ORDER BY sih.year    