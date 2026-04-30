-- PROMOTION IMPACT
SELECT
    p.promotion_type,
    SUM(f.amount) AS revenue
FROM SILVER.financial_transactions_clean f
LEFT JOIN SILVER.promotions_clean p
    ON f.region = p.region
GROUP BY p.promotion_type
ORDER BY revenue DESC;