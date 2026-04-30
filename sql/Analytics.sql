
-- =====================================================
-- PHASE 3 - DATA PRODUCT (ANALYTICS LAYER)
-- =====================================================

CREATE SCHEMA IF NOT EXISTS ANYCOMPANY_LAB.ANALYTICS;
USE DATABASE ANYCOMPANY_LAB;
USE SCHEMA ANALYTICS;

-- 9. SALES ENRICHED DATA PRODUCT
CREATE OR REPLACE TABLE ANALYTICS.sales_enriched AS
SELECT
    f.transaction_id,
    f.transaction_date,
    f.amount,
    f.region,
    f.entity,
    c.gender,
    c.annual_income,
    c.country
FROM SILVER.financial_transactions_clean f
LEFT JOIN SILVER.customer_demographics_clean c
    ON f.account_code = c.customer_id;


-- 10. ACTIVE PROMOTIONS TABLE
CREATE OR REPLACE TABLE ANALYTICS.active_promotions AS
SELECT *
FROM SILVER.promotions_clean
WHERE CURRENT_DATE BETWEEN start_date AND end_date;


-- 11. CUSTOMERS ENRICHED TABLE
CREATE OR REPLACE TABLE ANALYTICS.customers_enriched AS
SELECT
    c.customer_id,
    c.gender,
    c.region,
    c.country,
    c.annual_income,
    COUNT(f.transaction_id) AS nb_transactions,
    AVG(f.amount) AS avg_spent
FROM SILVER.customer_demographics_clean c
LEFT JOIN SILVER.financial_transactions_clean f
    ON c.customer_id = f.account_code
GROUP BY
    c.customer_id,
    c.gender,
    c.region,
    c.country,
    c.annual_income;



-- =====================================================
-- FEATURE ENGINEERING (ML READY)
-- =====================================================

-- 12. CUSTOMER FEATURES (RFM MODEL)
CREATE OR REPLACE TABLE ANALYTICS.customer_features AS
SELECT
    account_code,
    COUNT(*) AS frequency,
    AVG(amount) AS avg_basket,
    MAX(transaction_date) AS last_purchase,
    DATEDIFF('day', MAX(transaction_date), CURRENT_DATE) AS recency
FROM SILVER.financial_transactions_clean
GROUP BY account_code;


-- 13. PROMOTION EXPOSURE PER CUSTOMER
SELECT
    f.account_code,
    COUNT(p.promotion_id) AS nb_promotions
FROM SILVER.financial_transactions_clean f
LEFT JOIN SILVER.promotions_clean p
    ON f.region = p.region
GROUP BY f.account_code;