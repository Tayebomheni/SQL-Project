import streamlit as st
from snowflake.snowpark.context import get_active_session

st.title("📣 Marketing ROI")

session = get_active_session()

# =========================
# KPI MARKETING
# =========================
kpi = session.sql("""
SELECT 
    COUNT(*) AS NB_CAMPAIGNS,
    SUM(BUDGET) AS TOTAL_BUDGET,
    AVG(CONVERSION_RATE) AS AVG_CONVERSION,
    SUM(REACH) AS TOTAL_REACH
FROM ANYCOMPANY_LAB.SILVER.MARKETING_CAMPAIGNS_CLEAN
""").collect()[0]

col1, col2, col3, col4 = st.columns(4)

col1.metric("📊 Campaigns", kpi["NB_CAMPAIGNS"])
col2.metric("💰 Budget", kpi["TOTAL_BUDGET"])
col3.metric("📈 Conversion", kpi["AVG_CONVERSION"])
col4.metric("👥 Reach", kpi["TOTAL_REACH"])

st.divider()

# =========================
# CAMPAIGN PERFORMANCE
# =========================
st.subheader("🏆 Campaign Performance")

campaign = session.sql("""
SELECT 
    CAMPAIGN_NAME,
    CONVERSION_RATE,
    BUDGET,
    REACH
FROM ANYCOMPANY_LAB.SILVER.MARKETING_CAMPAIGNS_CLEAN
ORDER BY CONVERSION_RATE DESC
""").collect()

st.bar_chart(campaign, x="CAMPAIGN_NAME", y="CONVERSION_RATE")

# =========================
# CAMPAIGN TYPE
# =========================
st.subheader("📌 Campaign Type")

type_perf = session.sql("""
SELECT 
    CAMPAIGN_TYPE,
    COUNT(*) AS NB,
    AVG(CONVERSION_RATE) AS AVG_CONV
FROM ANYCOMPANY_LAB.SILVER.MARKETING_CAMPAIGNS_CLEAN
GROUP BY CAMPAIGN_TYPE
""").collect()

st.bar_chart(type_perf, x="CAMPAIGN_TYPE", y="NB")

st.dataframe(type_perf)