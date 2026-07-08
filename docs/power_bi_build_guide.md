# Power BI Build Guide, Olist Delivery Risk Dashboard

Power BI Desktop is a Windows application, so it can't be run or exported to a
.pbix file from this environment. This guide gives you the exact steps and the
one data file you need to build it yourself in 10 to 15 minutes.

## Data to import

File: cleaned_data/state_delivery_satisfaction_revenue.csv
26 rows, one per Brazilian state. Columns: customer_state, orders,
avg_delivery_days, avg_days_vs_estimate, avg_review_score, total_revenue,
slowest_delivery_rank, pct_of_total_revenue, cumulative_pct_revenue, at_risk.

Steps: Home, Get Data, Text/CSV, select the file, Load.

## Report layout, 1 hero visual + 3 supporting visuals

### Hero visual: Delivery speed vs review score
- Visual type: Scatter chart
- X axis: avg_delivery_days
- Y axis: avg_review_score
- Size: total_revenue
- Legend: at_risk (this gives you the red/blue split used in the Streamlit version)
- Add a text box annotation near RJ's point: "RJ: 13.3% of revenue, ships almost
  2x slower than SP"

### Supporting visual 1: Revenue concentration, Pareto chart
- Visual type: Line and stacked column chart
- Shared axis: customer_state, sorted by total_revenue descending
- Columns: total_revenue
- Line: cumulative_pct_revenue

### Supporting visual 2: Slowest 10 states by delivery time
- Visual type: Bar chart
- Axis: customer_state
- Value: avg_delivery_days
- Filter this visual to the Top 10 by avg_delivery_days
- Color: avg_review_score (conditional formatting, red to green scale)

### Supporting visual 3: At-risk states table
- Visual type: Table
- Filter: at_risk = TRUE
- Columns: customer_state, orders, avg_delivery_days, avg_review_score, total_revenue
- Sort by total_revenue descending

## Publishing

File, Publish, Publish to Power BI. Once published, use File, Embed report,
Publish to web to generate a direct public link, the same kind of link the
14-day plan calls for when the deliverable is a published visualization rather
than a hosted app.
