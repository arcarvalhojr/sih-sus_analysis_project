/*
YEAR-LEVEL INSIGHTS
Calculated metrics:
- Counts and rates of avoidable vs. non-avoidable disease hospitalizations
- Total expenditures
- Sex-specific rates within avoidable hospitalizations
- Regional distribution of avoidable hospitalization rates and associated costs 
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

    ROUND(COUNT(CASE
                    WHEN cid.avoidable_disease_code IS NOT NULL
                        AND sih.gender = 'Male' THEN 1 
                END) * 100.0 / COUNT(CASE
                                         WHEN cid.avoidable_disease_code IS NOT NULL THEN 1 
                                     END), 2) AS tx_avoidable_disease_male,
    ROUND(COUNT(CASE
                    WHEN cid.avoidable_disease_code IS NOT NULL 
                        AND sih.gender = 'Female' THEN 1 
                END) * 100.0 / COUNT(CASE
                                         WHEN cid.avoidable_disease_code IS NOT NULL THEN 1 
                                     END), 2) AS tx_avoidable_disease_female,
    
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
                    WHEN cid.avoidable_disease_code IS NOT NULL 
                        AND uf.big_region_name = 'Norte' THEN 1 
                END) * 100.0 / COUNT(*), 2) AS tx_avoidable_disease_north,
    ROUND(COUNT(CASE
                    WHEN cid.avoidable_disease_code IS NOT NULL
                        AND uf.big_region_name = 'Nordeste' THEN 1
                END) * 100.0 / COUNT(*), 2) AS tx_avoidable_disease_northeast,
    ROUND(COUNT(CASE
                    WHEN cid.avoidable_disease_code IS NOT NULL
                        AND uf.big_region_name = 'Sul' THEN 1 
                END) * 100.0 / COUNT(*), 2) AS tx_avoidable_disease_south,
    ROUND(COUNT(CASE
                    WHEN cid.avoidable_disease_code IS NOT NULL
                        AND uf.big_region_name = 'Sudeste' THEN 1 
                END) * 100.0 / COUNT(*), 2) AS tx_avoidable_disease_southeast,
    ROUND(COUNT(CASE
                    WHEN cid.avoidable_disease_code IS NOT NULL
                        AND uf.big_region_name = 'Centro-Oeste' THEN 1 
                END) * 100.0 / COUNT(*), 2) AS tx_avoidable_disease_centralWest,
    
    ROUND(SUM(CASE
                  WHEN cid.avoidable_disease_code IS NOT NULL 
                        AND uf.big_region_name = 'Norte' THEN sih.total_paid 
                  ELSE 0 
              END), 2) AS avoidable_disease_cost_north,
    ROUND(SUM(CASE
                  WHEN cid.avoidable_disease_code IS NOT NULL 
                        AND uf.big_region_name = 'Nordeste' THEN sih.total_paid 
                  ELSE 0 
              END), 2) AS avoidable_disease_cost_northeast,
    ROUND(SUM(CASE
                  WHEN cid.avoidable_disease_code IS NOT NULL 
                        AND uf.big_region_name = 'Sul' THEN sih.total_paid 
                  ELSE 0 
              END), 2) AS avoidable_disease_cost_south,
    ROUND(SUM(CASE
                  WHEN cid.avoidable_disease_code IS NOT NULL 
                        AND uf.big_region_name = 'Sudeste' THEN sih.total_paid 
                  ELSE 0 
              END), 2) AS avoidable_disease_cost_southeast,
    ROUND(SUM(CASE
                  WHEN cid.avoidable_disease_code IS NOT NULL 
                        AND uf.big_region_name = 'Centro-Oeste' THEN sih.total_paid 
                  ELSE 0 
              END), 2) AS avoidable_disease_cost_centralWest

FROM silver.sih_sus AS sih
LEFT JOIN silver.cid10_icsap AS cid
    ON sih.disease_code = cid.avoidable_disease_code
LEFT JOIN silver.uf_localidade AS uf
    ON sih.state_code = uf.state_code
GROUP BY sih.year
ORDER BY sih.year    