/*
REGION-LEVEL INSIGHTS
Calculated metrics:
- Total hospitalization and spending by region
- Avoidable hospitalizations by region
- Share of regional healthcare spending attributable to avoidable cases
*/

SELECT
    sih.year,
    uf.big_region_name,

    COUNT(*) AS total_hospitalizations,
    COUNT(CASE 
              WHEN cid.avoidable_disease_code IS NOT NULL THEN 1 
          END) AS avoidable_disease_hosp,
    ROUND(COUNT(CASE 
                    WHEN cid.avoidable_disease_code IS NOT NULL THEN 1 
                END) * 100.0 / COUNT(*), 2) AS tx_avoidable_disease,

    ROUND(SUM(sih.total_paid)) AS total_cost,
    ROUND(AVG(sih.total_paid), 2) AS avg_total_cost,
    ROUND(SUM(CASE 
                  WHEN cid.avoidable_disease_code IS NOT NULL THEN sih.total_paid
                  ELSE 0 
              END), 2) AS avoidable_disease_cost,
    ROUND(AVG(CASE
                  WHEN cid.avoidable_disease_code IS NOT NULL THEN sih.total_paid
                  ELSE 0
              END), 2) AS avg_avoidable_disease_cost,
    ROUND(SUM(CASE 
                  WHEN cid.avoidable_disease_code IS NOT NULL THEN sih.total_paid
                  ELSE 0 
              END) * 100.0 / SUM(sih.total_paid), 2) AS tx_avoidable_disease_cost 

FROM silver.sih_sus AS sih
LEFT JOIN silver.cid10_icsap AS cid
    ON sih.disease_code = cid.avoidable_disease_code
LEFT JOIN silver.uf_localidade AS uf
    ON sih.state_code = uf.state_code
GROUP BY sih.year, uf.big_region_name
ORDER BY sih.year, uf.big_region_name
