-- Olist Brazilian E-Commerce: Delivery Satisfaction Risk and Revenue Exposure by State
-- Business question: which customer states carry the highest satisfaction risk from
-- slow delivery, and how much revenue is exposed in those states.
--
-- Assumption: analysis is restricted to orders with status = 'delivered'. Orders that
-- were canceled, lost, or never shipped have no delivery date and cannot be scored for
-- delivery speed. That is a separate operational issue from the one this query answers.

-- Step 1: join orders to customers to get the state each order shipped to,
-- and compute delivery days with date manipulation on the two timestamp columns.
WITH order_delivery AS (
    SELECT
        o.order_id,
        c.customer_state,
        julianday(o.order_delivered_customer_date) - julianday(o.order_purchase_timestamp) AS delivery_days,
        julianday(o.order_delivered_customer_date) - julianday(o.order_estimated_delivery_date) AS days_vs_estimate
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
),

-- Step 2: bring in review score per order. An order can have more than one review
-- row, so average the score to one row per order before joining further.
order_review AS (
    SELECT
        order_id,
        AVG(review_score) AS review_score
    FROM order_reviews
    GROUP BY order_id
),

-- Step 3: bring in item-level revenue per order. Aggregation: sum item price
-- (freight excluded, since freight is a shipping cost, not merchandise revenue).
order_revenue AS (
    SELECT
        order_id,
        SUM(price) AS order_revenue
    FROM order_items
    GROUP BY order_id
),

-- Step 4: the core multi-table join, combining delivery timing, review score,
-- and revenue for every delivered order.
order_level AS (
    SELECT
        d.order_id,
        d.customer_state,
        d.delivery_days,
        d.days_vs_estimate,
        r.review_score,
        rev.order_revenue
    FROM order_delivery d
    LEFT JOIN order_review r ON d.order_id = r.order_id
    LEFT JOIN order_revenue rev ON d.order_id = rev.order_id
    WHERE rev.order_revenue IS NOT NULL
),

-- Step 5: aggregation by state, the grain the business question is asked at.
state_summary AS (
    SELECT
        customer_state,
        COUNT(*) AS orders,
        ROUND(AVG(delivery_days), 1) AS avg_delivery_days,
        ROUND(AVG(days_vs_estimate), 1) AS avg_days_vs_estimate,
        ROUND(AVG(review_score), 2) AS avg_review_score,
        ROUND(SUM(order_revenue), 2) AS total_revenue
    FROM order_level
    GROUP BY customer_state
    HAVING COUNT(*) >= 50   -- drop states with too few orders to trust the average
)

-- Step 6: window function. Rank every state by average delivery days (slowest first)
-- and compute a running share of total revenue, so we can see how much money sits
-- behind the slowest-shipping states.
SELECT
    customer_state,
    orders,
    avg_delivery_days,
    avg_days_vs_estimate,
    avg_review_score,
    total_revenue,
    RANK() OVER (ORDER BY avg_delivery_days DESC) AS slowest_delivery_rank,
    ROUND(100.0 * total_revenue / SUM(total_revenue) OVER (), 1) AS pct_of_total_revenue,
    ROUND(100.0 * SUM(total_revenue) OVER (ORDER BY total_revenue DESC) / SUM(total_revenue) OVER (), 1) AS cumulative_pct_revenue
FROM state_summary
ORDER BY avg_delivery_days DESC;
