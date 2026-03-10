WITH deposit_agg AS (
    SELECT
        cust_id,
        SUM(CASE WHEN product_group = 'Deposit' THEN balance ELSE 0 END) AS total_deposit_balance,
        SUM(CASE WHEN deposit_category = 'IBB'   THEN balance ELSE 0 END) AS ibb_balance,
        SUM(CASE WHEN deposit_category = 'NIDDA' THEN balance ELSE 0 END) AS nidda_balance,
        COUNT(DISTINCT CASE WHEN active_flag = 'Y' THEN product_type END) AS total_products,
        MAX(has_credit_card) AS has_credit_card
    FROM fact_cust_product
    GROUP BY cust_id
),

client_base AS (
    SELECT
        c.cust_id,
        c.cust_name,
        c.cust_city,
        c.cust_neighbourhood,
        c.tenure_days,
        c.branches_within_1km,
        c.uses_mobile_banking,
        c.avg_daily_txn_count,
        c.primary_bank_name,
        c.primary_branch_id,
        c.primary_branch_in_top3,
        c.primary_branch_km,
        c.primary_branch_minutes,
        c.top1_bank_name,
        c.top1_km,
        c.top2_bank_name,
        c.top2_km,
        c.top3_bank_name,
        c.top3_km,
        d.total_deposit_balance,
        d.ibb_balance,
        d.nidda_balance,
        d.total_products,
        d.has_credit_card,
        CASE
            WHEN c.branches_within_1km = 0  THEN 'No Nearby Branch'
            WHEN c.branches_within_1km <= 2 THEN 'Low Coverage (1-2)'
            WHEN c.branches_within_1km <= 5 THEN 'Moderate Coverage (3-5)'
            WHEN c.branches_within_1km <= 10 THEN 'High Coverage (6-10)'
            ELSE 'Very High Coverage (10+)'
        END AS branch_coverage_tier
    FROM clients c
    LEFT JOIN deposit_agg d ON c.cust_id = d.cust_id
)

-- Descriptive Analysis ------------------------------
-- Average deposit, transaction count, and tenure by coverage tier
SELECT
    branch_coverage_tier,
    COUNT(DISTINCT cust_id) AS client_count,
    ROUND(AVG(tenure_days), 0) AS avg_tenure_days,
    ROUND(AVG(avg_daily_txn_count), 2) AS avg_daily_txn,
    ROUND(AVG(total_deposit_balance), 0) AS avg_deposit,
    ROUND(SUM(total_deposit_balance), 0) AS total_deposit
FROM client_base
GROUP BY branch_coverage_tier
ORDER BY avg_deposit DESC;

-- Top 20% of clients by deposit balance and their share of total deposits
WITH deposit_agg AS (
    SELECT cust_id,
        SUM(CASE WHEN product_group = 'Deposit' THEN balance ELSE 0 END) AS total_deposit_balance,
        SUM(CASE WHEN deposit_category = 'IBB'  THEN balance ELSE 0 END) AS ibb_balance,
        SUM(CASE WHEN deposit_category = 'NIDDA'THEN balance ELSE 0 END) AS nidda_balance,
        COUNT(DISTINCT CASE WHEN active_flag = 'Y' THEN product_type END) AS total_products,
        MAX(has_credit_card) AS has_credit_card
    FROM fact_cust_product GROUP BY cust_id
),
client_base AS (
    SELECT c.*, d.total_deposit_balance, d.ibb_balance, d.nidda_balance,
           d.total_products, d.has_credit_card,
        CASE WHEN c.branches_within_1km = 0   THEN 'No Nearby Branch'
             WHEN c.branches_within_1km <= 2  THEN 'Low Coverage (1-2)'
             WHEN c.branches_within_1km <= 5  THEN 'Moderate Coverage (3-5)'
             WHEN c.branches_within_1km <= 10 THEN 'High Coverage (6-10)'
             ELSE 'Very High Coverage (10+)' END AS branch_coverage_tier
    FROM clients c LEFT JOIN deposit_agg d ON c.cust_id = d.cust_id
),
ranked AS (
    SELECT
        cust_id,
        total_deposit_balance,
        NTILE(5) OVER (ORDER BY total_deposit_balance DESC) AS deposit_quintile
    FROM client_base
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
WITH deposit_agg AS (
    SELECT cust_id,
        SUM(CASE WHEN product_group = 'Deposit' THEN balance ELSE 0 END) AS total_deposit_balance,
        SUM(CASE WHEN deposit_category = 'IBB'  THEN balance ELSE 0 END) AS ibb_balance,
        SUM(CASE WHEN deposit_category = 'NIDDA'THEN balance ELSE 0 END) AS nidda_balance
    FROM fact_cust_product GROUP BY cust_id
),
client_base AS (
    SELECT c.primary_bank_name, d.total_deposit_balance, d.ibb_balance, d.nidda_balance
    FROM clients c LEFT JOIN deposit_agg d ON c.cust_id = d.cust_id
)
SELECT
    primary_bank_name,
    ROUND(SUM(ibb_balance), 0) AS ibb_total,
    ROUND(SUM(nidda_balance), 0) AS nidda_total,
    ROUND(SUM(ibb_balance)   * 100.0 / NULLIF(SUM(total_deposit_balance), 0), 2) AS ibb_pct,
    ROUND(SUM(nidda_balance) * 100.0 / NULLIF(SUM(total_deposit_balance), 0), 2) AS nidda_pct
FROM client_base
GROUP BY primary_bank_name
ORDER BY ibb_pct DESC;

-- Bypass vs non-bypass clients
WITH deposit_agg AS (
    SELECT cust_id,
        SUM(CASE WHEN product_group = 'Deposit' THEN balance ELSE 0 END) AS total_deposit_balance,
        COUNT(DISTINCT CASE WHEN active_flag = 'Y' THEN product_type END) AS total_products
    FROM fact_cust_product GROUP BY cust_id
),
client_base AS (
    SELECT c.cust_id, c.primary_branch_in_top3, c.primary_branch_km,
           c.avg_daily_txn_count, d.total_deposit_balance, d.total_products
    FROM clients c LEFT JOIN deposit_agg d ON c.cust_id = d.cust_id
)
SELECT
    primary_branch_in_top3,
    COUNT(DISTINCT cust_id) AS client_count,
    ROUND(AVG(primary_branch_km), 2) AS avg_km_to_branch,
    ROUND(AVG(avg_daily_txn_count), 2) AS avg_daily_txn,
    ROUND(AVG(total_deposit_balance), 0) AS avg_deposit,
    ROUND(AVG(total_products), 2) AS avg_products
FROM client_base
GROUP BY primary_branch_in_top3
ORDER BY avg_deposit DESC;


-- Segmentation Analysis ------------------------------
-- Client segments by coverage tier and digital adoption
WITH deposit_agg AS (
    SELECT cust_id,
        SUM(CASE WHEN product_group = 'Deposit' THEN balance ELSE 0 END) AS total_deposit_balance,
        COUNT(DISTINCT CASE WHEN active_flag = 'Y' THEN product_type END) AS total_products
    FROM fact_cust_product GROUP BY cust_id
),
client_base AS (
    SELECT c.cust_id, c.uses_mobile_banking, c.avg_daily_txn_count, c.tenure_days,
           d.total_deposit_balance, d.total_products,
        CASE WHEN c.branches_within_1km = 0   THEN 'No Nearby Branch'
             WHEN c.branches_within_1km <= 2  THEN 'Low Coverage (1-2)'
             WHEN c.branches_within_1km <= 5  THEN 'Moderate Coverage (3-5)'
             WHEN c.branches_within_1km <= 10 THEN 'High Coverage (6-10)'
             ELSE 'Very High Coverage (10+)' END AS branch_coverage_tier
    FROM clients c LEFT JOIN deposit_agg d ON c.cust_id = d.cust_id
)
SELECT
    branch_coverage_tier,
    uses_mobile_banking,
    COUNT(DISTINCT cust_id) AS client_count,
    ROUND(AVG(total_deposit_balance), 0) AS avg_deposit,
    ROUND(AVG(total_products), 2) AS avg_products,
    ROUND(AVG(avg_daily_txn_count), 2) AS avg_daily_txn,
    ROUND(AVG(tenure_days), 0) AS avg_tenure_days
FROM client_base
GROUP BY branch_coverage_tier, uses_mobile_banking
ORDER BY branch_coverage_tier, avg_deposit DESC;

-- Product holding segments: credit card holders vs non-holders
WITH deposit_agg AS (
    SELECT cust_id,
        SUM(CASE WHEN product_group = 'Deposit' THEN balance ELSE 0 END) AS total_deposit_balance,
        COUNT(DISTINCT CASE WHEN active_flag = 'Y' THEN product_type END) AS total_products,
        MAX(has_credit_card) AS has_credit_card
    FROM fact_cust_product GROUP BY cust_id
),
client_base AS (
    SELECT c.cust_id, c.avg_daily_txn_count, c.tenure_days,
           d.total_deposit_balance, d.total_products, d.has_credit_card
    FROM clients c LEFT JOIN deposit_agg d ON c.cust_id = d.cust_id
)
SELECT
    has_credit_card,
    COUNT(DISTINCT cust_id) AS client_count,
    ROUND(AVG(total_deposit_balance), 0) AS avg_deposit,
    ROUND(AVG(total_products), 2) AS avg_products,
    ROUND(AVG(avg_daily_txn_count), 2) AS avg_daily_txn,
    ROUND(AVG(tenure_days), 0) AS avg_tenure_days
FROM client_base
GROUP BY has_credit_card
ORDER BY avg_deposit DESC;


-- Correlation Exploration ------------------------------
-- Proxy correlation: distance to branch vs deposit balance and transaction volume
WITH deposit_agg AS (
    SELECT cust_id,
        SUM(CASE WHEN product_group = 'Deposit' THEN balance ELSE 0 END) AS total_deposit_balance
    FROM fact_cust_product GROUP BY cust_id
),
client_base AS (
    SELECT c.cust_id, c.primary_branch_km, c.avg_daily_txn_count, c.uses_mobile_banking,
           d.total_deposit_balance,
        CASE WHEN c.primary_branch_km < 0.5  THEN '< 0.5 km'
             WHEN c.primary_branch_km < 1.0  THEN '0.5-1.0 km'
             WHEN c.primary_branch_km < 2.0  THEN '1.0-2.0 km'
             WHEN c.primary_branch_km < 5.0  THEN '2.0-5.0 km'
             ELSE '5.0+ km' END AS distance_band
    FROM clients c LEFT JOIN deposit_agg d ON c.cust_id = d.cust_id
)
SELECT
    distance_band,
    COUNT(DISTINCT cust_id) AS client_count,
    ROUND(AVG(total_deposit_balance), 0) AS avg_deposit,
    ROUND(AVG(avg_daily_txn_count), 2) AS avg_daily_txn,
    ROUND(AVG(CAST(uses_mobile_banking AS FLOAT)) * 100, 2) AS mobile_adoption_pct
FROM client_base
GROUP BY distance_band
ORDER BY MIN(primary_branch_km);

-- Tenure vs deposit and product depth: lifecycle correlation proxy
WITH deposit_agg AS (
    SELECT cust_id,
        SUM(CASE WHEN product_group = 'Deposit' THEN balance ELSE 0 END) AS total_deposit_balance,
        COUNT(DISTINCT CASE WHEN active_flag = 'Y' THEN product_type END) AS total_products
    FROM fact_cust_product GROUP BY cust_id
),
client_base AS (
    SELECT c.cust_id, c.tenure_days, c.avg_daily_txn_count,
           d.total_deposit_balance, d.total_products,
        CASE WHEN c.tenure_days < 365        THEN '< 1 yr'
             WHEN c.tenure_days < 365*3      THEN '1-3 yrs'
             WHEN c.tenure_days < 365*7      THEN '3-7 yrs'
             WHEN c.tenure_days < 365*12     THEN '7-12 yrs'
             ELSE '12+ yrs' END AS tenure_band
    FROM clients c LEFT JOIN deposit_agg d ON c.cust_id = d.cust_id
)
SELECT
    tenure_band,
    COUNT(DISTINCT cust_id) AS client_count,
    ROUND(AVG(total_deposit_balance), 0) AS avg_deposit,
    ROUND(AVG(total_products), 2) AS avg_products,
    ROUND(AVG(avg_daily_txn_count), 2) AS avg_daily_txn
FROM client_base
GROUP BY tenure_band
ORDER BY MIN(tenure_days);


-- Geospatial / Spatial Analysis ------------------------------
-- Neighbourhood-level accessibility and deposit summary
WITH deposit_agg AS (
    SELECT cust_id,
        SUM(CASE WHEN product_group = 'Deposit' THEN balance ELSE 0 END) AS total_deposit_balance
    FROM fact_cust_product GROUP BY cust_id
),
client_base AS (
    SELECT c.cust_id, c.cust_neighbourhood, c.cust_city, c.branches_within_1km,
           c.primary_branch_km, c.uses_mobile_banking, d.total_deposit_balance
    FROM clients c LEFT JOIN deposit_agg d ON c.cust_id = d.cust_id
)
SELECT
    cust_neighbourhood,
    cust_city,
    COUNT(DISTINCT cust_id) AS client_count,
    ROUND(AVG(branches_within_1km), 2) AS avg_branches_1km,
    ROUND(AVG(primary_branch_km), 2) AS avg_km_to_branch,
    ROUND(AVG(total_deposit_balance), 0) AS avg_deposit,
    ROUND(AVG(CAST(uses_mobile_banking AS FLOAT)) * 100, 2) AS mobile_adoption_pct
FROM client_base
GROUP BY cust_neighbourhood, cust_city
HAVING COUNT(DISTINCT cust_id) >= 10
ORDER BY avg_branches_1km DESC;

-- Outside Toronto vs Toronto: full behavioural and financial comparison
WITH deposit_agg AS (
    SELECT cust_id,
        SUM(CASE WHEN product_group = 'Deposit' THEN balance ELSE 0 END) AS total_deposit_balance,
        COUNT(DISTINCT CASE WHEN active_flag = 'Y' THEN product_type END) AS total_products
    FROM fact_cust_product GROUP BY cust_id
),
client_base AS (
    SELECT c.cust_id, c.cust_city, c.branches_within_1km, c.primary_branch_km,
           c.uses_mobile_banking, c.avg_daily_txn_count,
           d.total_deposit_balance, d.total_products
    FROM clients c LEFT JOIN deposit_agg d ON c.cust_id = d.cust_id
)
SELECT
    cust_city,
    COUNT(DISTINCT cust_id) AS client_count,
    ROUND(AVG(branches_within_1km), 2) AS avg_branches_1km,
    ROUND(AVG(primary_branch_km), 2) AS avg_km_to_branch,
    ROUND(AVG(CAST(uses_mobile_banking AS FLOAT)) * 100, 2) AS mobile_adoption_pct,
    ROUND(AVG(avg_daily_txn_count), 2) AS avg_daily_txn,
    ROUND(AVG(total_deposit_balance), 0) AS avg_deposit,
    ROUND(AVG(total_products), 2) AS avg_products
FROM client_base
GROUP BY cust_city
ORDER BY avg_deposit DESC;


-- Regression Analysis ------------------------------
-- Deposit balance decile distribution by coverage tier
WITH deposit_agg AS (
    SELECT cust_id,
        SUM(CASE WHEN product_group = 'Deposit' THEN balance ELSE 0 END) AS total_deposit_balance,
        COUNT(DISTINCT CASE WHEN active_flag = 'Y' THEN product_type END) AS total_products,
        MAX(has_credit_card) AS has_credit_card
    FROM fact_cust_product GROUP BY cust_id
),
client_base AS (
    SELECT c.cust_id, c.branches_within_1km, c.primary_branch_km, c.tenure_days,
           c.uses_mobile_banking, c.avg_daily_txn_count,
           d.total_deposit_balance, d.total_products, d.has_credit_card
    FROM clients c LEFT JOIN deposit_agg d ON c.cust_id = d.cust_id
),
deciled AS (
    SELECT *,
        NTILE(10) OVER (ORDER BY total_deposit_balance) AS deposit_decile
    FROM client_base
)
SELECT
    deposit_decile,
    COUNT(cust_id) AS client_count,
    ROUND(AVG(total_deposit_balance), 0) AS avg_deposit,
    ROUND(AVG(branches_within_1km), 2) AS avg_coverage,
    ROUND(AVG(primary_branch_km), 2) AS avg_km,
    ROUND(AVG(tenure_days), 0) AS avg_tenure,
    ROUND(AVG(CAST(uses_mobile_banking AS FLOAT)) * 100, 2) AS mobile_pct,
    ROUND(AVG(avg_daily_txn_count), 2) AS avg_txn,
    ROUND(AVG(total_products), 2) AS avg_products,
    ROUND(AVG(CAST(has_credit_card AS FLOAT)) * 100, 2)  AS cc_hold_pct
FROM deciled
GROUP BY deposit_decile
ORDER BY deposit_decile;
