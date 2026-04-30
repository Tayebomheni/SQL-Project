import streamlit as st
from snowflake.snowpark.context import get_active_session

st.title("📊 Sales Dashboard")

session = get_active_session()

# =========================
# KPI GLOBAL
# =========================
kpi = session.sql("""
SELECT 
    SUM(AMOUNT) AS TOTAL_REVENUE,
    AVG(AMOUNT) AS AVG_ORDER,
    COUNT(*) AS NB_TRANSACTIONS,
    MIN(AMOUNT) AS MIN_ORDER,
    MAX(AMOUNT) AS MAX_ORDER
FROM ANYCOMPANY_LAB.ANALYTICS.SALES_ENRICHED
""").collect()[0]

col1, col2, col3, col4, col5 = st.columns(5)

col1.metric("💰 Revenue", kpi["TOTAL_REVENUE"])
col2.metric("📦 Avg Order", kpi["AVG_ORDER"])
col3.metric("🧾 Transactions", kpi["NB_TRANSACTIONS"])
col4.metric("⬇ Min", kpi["MIN_ORDER"])
col5.metric("⬆ Max", kpi["MAX_ORDER"])

st.divider()

# =========================
# SALES TREND
# =========================
st.subheader("📈 Monthly Sales")

trend = session.sql("""
SELECT 
    DATE_TRUNC('month', TRANSACTION_DATE) AS MONTH,
    SUM(AMOUNT) AS SALES,
    COUNT(*) AS NB_ORDERS
FROM ANYCOMPANY_LAB.ANALYTICS.SALES_ENRICHED
GROUP BY MONTH
ORDER BY MONTH
""").collect()

st.line_chart(trend, x="MONTH", y="SALES")

# =========================
# REGION PERFORMANCE
# =========================
st.subheader("🌍 Revenue by Region")

region = session.sql("""
SELECT 
    REGION,
    SUM(AMOUNT) AS REVENUE,
    COUNT(*) AS NB_ORDERS,
    AVG(AMOUNT) AS AVG_ORDER
FROM ANYCOMPANY_LAB.ANALYTICS.SALES_ENRICHED
GROUP BY REGION
ORDER BY REVENUE DESC
""").collect()

st.bar_chart(region, x="REGION", y="REVENUE")

# =========================
# TOP REGIONS TABLE
# =========================
st.subheader("🏆 Top Regions")

st.dataframe(region)