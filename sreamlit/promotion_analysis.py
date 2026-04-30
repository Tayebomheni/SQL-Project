import streamlit as st
from snowflake.snowpark.context import get_active_session

st.title("🎯 Promotion Analysis")

session = get_active_session()

# =========================
# KPI PROMOTION
# =========================
kpi = session.sql("""
SELECT 
    COUNT(*) AS NB_PROMOTIONS,
    AVG(DISCOUNT_PERCENTAGE) AS AVG_DISCOUNT,
    MIN(DISCOUNT_PERCENTAGE) AS MIN_DISCOUNT,
    MAX(DISCOUNT_PERCENTAGE) AS MAX_DISCOUNT
FROM ANYCOMPANY_LAB.SILVER.PROMOTIONS_CLEAN
""").collect()[0]

col1, col2, col3, col4 = st.columns(4)

col1.metric("🎯 Promotions", kpi["NB_PROMOTIONS"])
col2.metric("📉 Avg Discount", kpi["AVG_DISCOUNT"])
col3.metric("⬇ Min Discount", kpi["MIN_DISCOUNT"])
col4.metric("⬆ Max Discount", kpi["MAX_DISCOUNT"])

st.divider()

# =========================
# PROMO TYPE
# =========================
st.subheader("📊 Promotions by Type")

promo_type = session.sql("""
SELECT 
    PROMOTION_TYPE,
    COUNT(*) AS CNT
FROM ANYCOMPANY_LAB.SILVER.PROMOTIONS_CLEAN
GROUP BY PROMOTION_TYPE
""").collect()

st.bar_chart(promo_type, x="PROMOTION_TYPE", y="CNT")

# =========================
# PROMO BY CATEGORY
# =========================
st.subheader("🛍️ Promotions by Category")

category = session.sql("""
SELECT 
    PRODUCT_CATEGORY,
    COUNT(*) AS CNT,
    AVG(DISCOUNT_PERCENTAGE) AS AVG_DISCOUNT
FROM ANYCOMPANY_LAB.SILVER.PROMOTIONS_CLEAN
GROUP BY PRODUCT_CATEGORY
ORDER BY CNT DESC
""").collect()

st.bar_chart(category, x="PRODUCT_CATEGORY", y="CNT")

st.dataframe(category)