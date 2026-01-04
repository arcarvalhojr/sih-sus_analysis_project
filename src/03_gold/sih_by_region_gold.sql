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
    COUNT(icsap.avoidable_disease_code) AS total_icsap,
    ROUND(COUNT(icsap.avoidable_disease_code) * 100.0 / COUNT(*), 2) AS rate_icsap,

    ROUND(SUM(sih.total_cost)) AS total_cost,
    ROUND(AVG(sih.total_cost), 2) AS avg_total_cost,
    ROUND(SUM(CASE 
                  WHEN icsap.avoidable_disease_code IS NOT NULL THEN sih.total_cost
                  ELSE 0 
              END), 2) AS icsap_cost,
    ROUND(AVG(CASE
                  WHEN icsap.avoidable_disease_code IS NOT NULL THEN sih.total_cost
                  ELSE 0
              END), 2) AS avg_icsap_cost,
    ROUND(SUM(CASE 
                  WHEN icsap.avoidable_disease_code IS NOT NULL THEN sih.total_cost
                  ELSE 0 
              END) * 100.0 / SUM(sih.total_cost), 2) AS rate_icsap_cost 

FROM silver.sih_sus_eda_clean AS sih
LEFT JOIN silver.cid10_icsap AS icsap
    ON sih.disease_code = icsap.avoidable_disease_code
LEFT JOIN silver.uf_localidade AS uf
    ON sih.state_code = uf.state_code
GROUP BY sih.year, uf.big_region_name
ORDER BY sih.year, uf.big_region_name
