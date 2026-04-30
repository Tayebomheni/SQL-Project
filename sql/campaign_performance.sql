-- MARKETING PERFORMANCE
SELECT
    c.campaign_name,
    c.campaign_type,
    SUM(f.amount) AS revenue,
    c.conversion_rate
FROM SILVER.marketing_campaigns_clean c
LEFT JOIN SILVER.financial_transactions_clean f
    ON c.region = f.region
GROUP BY c.campaign_name, c.campaign_type, c.conversion_rate
ORDER BY revenue DESC;

-- CUSTOMER SEGMENTATION
SELECT
    gender,
    region,
    COUNT(*) AS nb_customers,
    AVG(annual_income) AS avg_income
FROM SILVER.customer_demographics_clean
GROUP BY gender, region;

-- REVIEWS IMPACT
SELECT
    product_category,
    AVG(rating) AS avg_rating,
    COUNT(*) AS nb_reviews
FROM SILVER.product_reviews_clean
GROUP BY product_category
ORDER BY avg_rating DESC;

-- LOGISTICS PERFORMANCE
SELECT
    status,
    AVG(DATEDIFF('day', ship_date, estimated_delivery)) AS avg_delay
FROM SILVER.logistics_clean
GROUP BY status;