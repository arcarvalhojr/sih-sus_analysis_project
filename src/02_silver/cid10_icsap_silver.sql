-- Aplie some type casting for optimization
-- and english readable names
SELECT
    CAST(Categoria AS VARCHAR) AS disease_category,
    CAST(Diagnostico AS VARCHAR) AS diagnostic,
    CAST(CID10 AS VARCHAR) AS avoidable_disease_code

FROM bronze.cid10_icsap