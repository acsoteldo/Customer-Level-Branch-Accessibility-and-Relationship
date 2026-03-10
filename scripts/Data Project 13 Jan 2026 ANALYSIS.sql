-- Average deposit, transaction count, and tenure by coverage tier
SELECT
    c.branch_coverage_tier,
    COUNT(DISTINCT c.cust_id) AS client_count,
    ROUND(AVG(c.tenure_days), 0) AS avg_tenure_days,
    ROUND(AVG(c.avg_daily_txn_count), 2) AS avg_daily_txn,
    ROUND(AVG(f.total_deposit_balance), 0) AS avg_deposit,
    ROUND(SUM(f.total_deposit_balance), 0) AS total_deposit
FROM clients c
JOIN fact_cust_product f ON c.cust_id = f.cust_id
WHERE f.active_flag = 'Y'
GROUP BY c.branch_coverage_tier
ORDER BY avg_deposit DESC;

-- Top 20% of clients by deposit balance and their share of total deposits
WITH ranked AS (
    SELECT
        c.cust_id,
        c.cust_name,
        c.cust_neighbourhood,
        f.total_deposit_balance,
        NTILE(5) OVER (ORDER BY f.total_deposit_balance DESC) AS deposit_quintile
    FROM clients c
    JOIN fact_cust_product f ON c.cust_id = f.cust_id
    WHERE f.active_flag = 'Y'
)
SELECT
    deposit_quintile,
    COUNT(cust_id) AS client_count,
    ROUND(SUM(total_deposit_balance), 0) AS total_deposit,
    ROUND(SUM(total_deposit_balance) * 100.0
          / SUM(SUM(total_deposit_balance)) OVER (), 2) AS pct_of_total
FROM ranked
GROUP BY deposit_quintile
ORDER BY deposit_quintile;

-- IBB vs NIDDA share by bank
SELECT
    c.primary_bank_name,
    ROUND(SUM(f.ibb_balance), 0) AS ibb_total,
    ROUND(SUM(f.nidda_balance), 0) AS nidda_total,
    ROUND(SUM(f.ibb_balance) * 100.0
          / NULLIF(SUM(f.total_deposit_balance), 0), 2) AS ibb_pct,
    ROUND(SUM(f.nidda_balance) * 100.0
          / NULLIF(SUM(f.total_deposit_balance), 0), 2) AS nidda_pct
FROM clients c
JOIN fact_cust_product f ON c.cust_id = f.cust_id
WHERE f.active_flag = 'Y'
GROUP BY c.primary_bank_name
ORDER BY ibb_pct DESC;

-- Primary branch in top 3 vs bypass clients: behavioural comparison
SELECT
    c.primary_branch_in_top3,
    COUNT(DISTINCT c.cust_id) AS client_count,
    ROUND(AVG(c.primary_branch_km), 2) AS avg_km_to_branch,
    ROUND(AVG(c.avg_daily_txn_count), 2) AS avg_daily_txn,
    ROUND(AVG(f.total_deposit_balance), 0) AS avg_deposit,
    ROUND(AVG(f.total_products), 2) AS avg_products
FROM clients c
JOIN fact_cust_product f ON c.cust_id = f.cust_id
WHERE f.active_flag = 'Y'
GROUP BY c.primary_branch_in_top3
ORDER BY avg_deposit DESC;

-- Segmentation Analysis ------------------------------
-- Client segments by coverage tier and digital adoption
SELECT
    c.branch_coverage_tier,
    c.uses_mobile_banking,
    COUNT(DISTINCT c.cust_id) AS client_count,
    ROUND(AVG(f.total_deposit_balance), 0) AS avg_deposit,
    ROUND(AVG(f.total_products), 2) AS avg_products,
    ROUND(AVG(c.avg_daily_txn_count), 2) AS avg_daily_txn,
    ROUND(AVG(c.tenure_days), 0) AS avg_tenure_days
FROM clients c
JOIN fact_cust_product f ON c.cust_id = f.cust_id
WHERE f.active_flag = 'Y'
GROUP BY c.branch_coverage_tier, c.uses_mobile_banking
ORDER BY c.branch_coverage_tier, avg_deposit DESC;

-- Product holding segments: credit card holders vs non-holders
SELECT
    f.has_credit_card,
    COUNT(DISTINCT c.cust_id) AS client_count,
    ROUND(AVG(f.total_deposit_balance), 0) AS avg_deposit,
    ROUND(AVG(f.total_products), 2) AS avg_products,
    ROUND(AVG(c.avg_daily_txn_count), 2) AS avg_daily_txn,
    ROUND(AVG(c.tenure_days), 0) AS avg_tenure_days
FROM clients c
JOIN fact_cust_product f ON c.cust_id = f.cust_id
WHERE f.active_flag = 'Y'
GROUP BY f.has_credit_card
ORDER BY avg_deposit DESC;

-- Correlation Exploration ------------------------------
-- Proxy correlation: distance to branch vs deposit balance and transaction volume
SELECT
    CASE
        WHEN c.primary_branch_km < 0.5  THEN '< 0.5 km'
        WHEN c.primary_branch_km < 1.0  THEN '0.5–1.0 km'
        WHEN c.primary_branch_km < 2.0  THEN '1.0–2.0 km'
        WHEN c.primary_branch_km < 5.0  THEN '2.0–5.0 km'
        ELSE '5.0+ km'
    END AS distance_band,
    COUNT(DISTINCT c.cust_id) AS client_count,
    ROUND(AVG(f.total_deposit_balance), 0) AS avg_deposit,
    ROUND(AVG(c.avg_daily_txn_count), 2) AS avg_daily_txn,
    ROUND(AVG(CAST(c.uses_mobile_banking AS INT))
          * 100, 2) AS mobile_adoption_pct
FROM clients c
JOIN fact_cust_product f ON c.cust_id = f.cust_id
WHERE f.active_flag = 'Y'
GROUP BY distance_band
ORDER BY MIN(c.primary_branch_km);

-- Tenure vs deposit and product depth: lifecycle correlation proxy
SELECT
    CASE
        WHEN c.tenure_days < 365           THEN '< 1 yr'
        WHEN c.tenure_days < 365 * 3       THEN '1–3 yrs'
        WHEN c.tenure_days < 365 * 7       THEN '3–7 yrs'
        WHEN c.tenure_days < 365 * 12      THEN '7–12 yrs'
        ELSE '12+ yrs'
    END AS tenure_band,
    COUNT(DISTINCT c.cust_id) AS client_count,
    ROUND(AVG(f.total_deposit_balance), 0) AS avg_deposit,
    ROUND(AVG(f.total_products), 2) AS avg_products,
    ROUND(AVG(c.avg_daily_txn_count), 2) AS avg_daily_txn
FROM clients c
JOIN fact_cust_product f ON c.cust_id = f.cust_id
WHERE f.active_flag = 'Y'
GROUP BY tenure_band
ORDER BY MIN(c.tenure_days);

-- Geospatial / Spatial Analysis ------------------------------
-- Neighbourhood-level accessibility and deposit summary
SELECT
    c.cust_neighbourhood,
    c.cust_city,
    COUNT(DISTINCT c.cust_id) AS client_count,
    ROUND(AVG(c.branches_within_1km), 2) AS avg_branches_1km,
    ROUND(AVG(c.primary_branch_km), 2) AS avg_km_to_branch,
    ROUND(AVG(f.total_deposit_balance), 0) AS avg_deposit,
    ROUND(AVG(CAST(c.uses_mobile_banking AS INT))
          * 100, 2) AS mobile_adoption_pct
FROM clients c
JOIN fact_cust_product f ON c.cust_id = f.cust_id
WHERE f.active_flag = 'Y'
GROUP BY c.cust_neighbourhood, c.cust_city
HAVING COUNT(DISTINCT c.cust_id) >= 10
ORDER BY avg_branches_1km DESC;

-- Outside Toronto vs Toronto: full behavioural and financial comparison
SELECT
    c.cust_city,
    COUNT(DISTINCT c.cust_id) AS client_count,
    ROUND(AVG(c.branches_within_1km), 2) AS avg_branches_1km,
    ROUND(AVG(c.primary_branch_km), 2) AS avg_km_to_branch,
    ROUND(AVG(CAST(c.uses_mobile_banking AS INT))
          * 100, 2) AS mobile_adoption_pct,
    ROUND(AVG(c.avg_daily_txn_count), 2) AS avg_daily_txn,
    ROUND(AVG(f.total_deposit_balance), 0) AS avg_deposit,
    ROUND(AVG(f.total_products), 2) AS avg_products
FROM clients c
JOIN fact_cust_product f ON c.cust_id = f.cust_id
WHERE f.active_flag = 'Y'
GROUP BY c.cust_city
ORDER BY avg_deposit DESC;

-- Regression Analysis ------------------------------
-- Deposit balance decile distribution by coverage tier
-- Use output as input features for external regression modelling
WITH deciled AS (
    SELECT
        c.cust_id,
        c.branch_coverage_tier,
        c.branches_within_1km,
        c.primary_branch_km,
        c.tenure_days,
        CAST(c.uses_mobile_banking AS INT) AS mobile_flag,
        c.avg_daily_txn_count,
        f.total_deposit_balance,
        f.total_products,
        f.has_credit_card,
        NTILE(10) OVER (ORDER BY f.total_deposit_balance) AS deposit_decile
    FROM clients c
    JOIN fact_cust_product f ON c.cust_id = f.cust_id
    WHERE f.active_flag = 'Y'
)
SELECT
    deposit_decile,
    COUNT(cust_id) AS client_count,
    ROUND(AVG(total_deposit_balance), 0) AS avg_deposit,
    ROUND(AVG(branches_within_1km), 2) AS avg_coverage,
    ROUND(AVG(primary_branch_km), 2) AS avg_km,
    ROUND(AVG(tenure_days), 0) AS avg_tenure,
    ROUND(AVG(mobile_flag) * 100, 2) AS mobile_pct,
    ROUND(AVG(avg_daily_txn_count), 2) AS avg_txn,
    ROUND(AVG(total_products), 2) AS avg_products,
    ROUND(AVG(has_credit_card) * 100, 2) AS cc_hold_pct
FROM deciled
GROUP BY deposit_decile
ORDER BY deposit_decile;
