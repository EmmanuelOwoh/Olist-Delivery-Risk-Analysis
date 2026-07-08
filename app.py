"""
Olist Brazilian E-Commerce: Delivery Satisfaction Risk and Revenue Exposure
Streamlit dashboard.

Business question: which customer states carry the highest satisfaction risk
from slow delivery, and how much revenue is exposed in those states.

Run locally with: streamlit run app.py
Data source: cleaned_data/state_delivery_satisfaction_revenue.csv,
produced by sql/olist_analysis.sql
"""

import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
import streamlit as st

st.set_page_config(page_title="Olist Delivery Risk Dashboard", layout="wide")

df = pd.read_csv("cleaned_data/state_delivery_satisfaction_revenue.csv")
df = df.sort_values("total_revenue", ascending=False).reset_index(drop=True)

st.title("Where slow delivery is putting Olist revenue at risk")
st.markdown(
    "Every delivered order from September 2016 to October 2018, grouped by "
    "customer state. Delivery speed, review score, and revenue together show "
    "where a fulfillment fix would protect the most money and the most reviews."
)

col1, col2, col3 = st.columns(3)
col1.metric("States analyzed", f"{len(df)}")
col2.metric("Revenue in at-risk states", f"R$ {df.loc[df['at_risk'], 'total_revenue'].sum():,.0f}",
            f"{100*df.loc[df['at_risk'],'total_revenue'].sum()/df['total_revenue'].sum():.1f}% of total")
col3.metric("Fastest vs slowest state", f"{df['avg_delivery_days'].min():.1f}d vs {df['avg_delivery_days'].max():.1f}d")

st.divider()

# Hero chart: delivery speed vs review score, bubble size = revenue
st.subheader("Delivery speed vs review score, by state")
st.caption("Bubble size is total revenue. States in the lower right ship slow and score low, "
           "the exact combination that puts revenue at risk.")

fig_hero = px.scatter(
    df, x="avg_delivery_days", y="avg_review_score", size="total_revenue",
    color="at_risk", hover_name="customer_state",
    color_discrete_map={True: "#d62728", False: "#1f77b4"},
    labels={"avg_delivery_days": "Average delivery days", "avg_review_score": "Average review score",
            "at_risk": "Above-median delay + below-median score"},
    size_max=60,
)
fig_hero.add_annotation(
    x=df.loc[df.customer_state == "RJ", "avg_delivery_days"].iloc[0],
    y=df.loc[df.customer_state == "RJ", "avg_review_score"].iloc[0],
    text="RJ: 13.3% of revenue, ships almost 2x slower than SP",
    showarrow=True, arrowhead=2, ax=40, ay=-40,
)
st.plotly_chart(fig_hero, use_container_width=True)

st.divider()

c1, c2 = st.columns(2)

with c1:
    st.subheader("Revenue concentration by state")
    st.caption("Three states, SP, RJ, and MG, hold 63% of all revenue.")
    fig_pareto = go.Figure()
    fig_pareto.add_bar(x=df["customer_state"], y=df["total_revenue"], name="Revenue")
    fig_pareto.add_scatter(x=df["customer_state"], y=df["cumulative_pct_revenue"],
                            yaxis="y2", name="Cumulative %", mode="lines+markers")
    fig_pareto.update_layout(
        yaxis=dict(title="Revenue (R$)"),
        yaxis2=dict(title="Cumulative % of revenue", overlaying="y", side="right", range=[0, 105]),
        legend=dict(orientation="h"),
    )
    st.plotly_chart(fig_pareto, use_container_width=True)

with c2:
    st.subheader("Slowest 10 states by delivery time")
    st.caption("Color shows review score, darker red is a lower score.")
    slowest = df.sort_values("avg_delivery_days", ascending=False).head(10)
    fig_slow = px.bar(
        slowest, x="avg_delivery_days", y="customer_state", orientation="h",
        color="avg_review_score", color_continuous_scale="RdYlGn",
        labels={"avg_delivery_days": "Average delivery days", "customer_state": "State",
                "avg_review_score": "Review score"},
    )
    fig_slow.update_layout(yaxis=dict(autorange="reversed"))
    st.plotly_chart(fig_slow, use_container_width=True)

st.divider()

st.subheader("States flagged at-risk: slower than median delivery and below median review score")
st.caption("These 9 states hold R$ 1.35M in revenue, 10.2% of the total, while carrying the "
           "clearest combination of slow shipping and low satisfaction.")
risk_table = df[df["at_risk"]][
    ["customer_state", "orders", "avg_delivery_days", "avg_review_score", "total_revenue"]
].sort_values("total_revenue", ascending=False).rename(columns={
    "customer_state": "State", "orders": "Orders", "avg_delivery_days": "Avg delivery days",
    "avg_review_score": "Avg review score", "total_revenue": "Revenue (R$)"
})
st.dataframe(risk_table, use_container_width=True, hide_index=True)
