SELECT
    DATE_TRUNC('month', transaction_date) AS month,
    SUM(amount) AS total_sales
FROM ANYCOMPANY_LAB.SILVER.financial_transactions_clean
GROUP BY 1
ORDER BY 1;

SELECT
    region,
    SUM(amount) AS revenue
FROM ANYCOMPANY_LAB.SILVER.financial_transactions_clean
GROUP BY region
ORDER BY revenue DESC;