-- Olist Brazilian E-Commerce: Revenue Concentration ("80% of revenue" cuts)
-- Supplementary to sql/olist_analysis.sql, same delivered-orders scope,
-- same revenue definition (item price, freight excluded).

-- ============================================================
-- Cut 1: by customer city
-- ============================================================
WITH order_revenue AS (
    SELECT order_id, SUM(price) AS order_revenue
    FROM order_items
    GROUP BY order_id
),
city_revenue AS (
    SELECT
        c.customer_city,
        c.customer_state,
        SUM(r.order_revenue) AS total_revenue,
        COUNT(DISTINCT o.order_id) AS orders
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    JOIN order_revenue r ON o.order_id = r.order_id
    GROUP BY c.customer_city, c.customer_state
)
SELECT
    customer_city,
    customer_state,
    orders,
    total_revenue,
    ROUND(100.0 * total_revenue / SUM(total_revenue) OVER (), 2) AS pct_of_total_revenue,
    ROUND(100.0 * SUM(total_revenue) OVER (ORDER BY total_revenue DESC)
          / SUM(total_revenue) OVER (), 2) AS cumulative_pct_revenue,
    RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank
FROM city_revenue
ORDER BY total_revenue DESC;


-- ============================================================
-- Cut 2: by product category
-- ============================================================
WITH order_item_revenue AS (
    SELECT oi.order_id, oi.product_id, oi.price
    FROM order_items oi
    JOIN orders o ON oi.order_id = o.order_id
),
category_revenue AS (
    SELECT
        COALESCE(p.product_category_name, 'unknown') AS category,
        SUM(oir.price) AS total_revenue,
        COUNT(DISTINCT oir.order_id) AS orders
    FROM order_item_revenue oir
    JOIN products p ON oir.product_id = p.product_id
    GROUP BY COALESCE(p.product_category_name, 'unknown')
)
SELECT
    category,
    orders,
    total_revenue,
    ROUND(100.0 * total_revenue / SUM(total_revenue) OVER (), 2) AS pct_of_total_revenue,
    ROUND(100.0 * SUM(total_revenue) OVER (ORDER BY total_revenue DESC)
          / SUM(total_revenue) OVER (), 2) AS cumulative_pct_revenue,
    RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank
FROM category_revenue
ORDER BY total_revenue DESC;


-- ============================================================
-- Cut 3: by customer type, new (1 order) vs repeat (2+ orders)
-- Uses customer_unique_id, the real customer identifier, not customer_id
-- which is a one-per-order surrogate key.
-- ============================================================
WITH order_revenue AS (
    SELECT order_id, SUM(price) AS order_revenue
    FROM order_items
    GROUP BY order_id
),
customer_orders AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS order_count,
        SUM(r.order_revenue) AS customer_revenue
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    JOIN order_revenue r ON o.order_id = r.order_id
    GROUP BY c.customer_unique_id
),
customer_type AS (
    SELECT
        CASE WHEN order_count > 1 THEN 'repeat' ELSE 'new' END AS customer_type,
        customer_revenue
    FROM customer_orders
)
SELECT
    customer_type,
    COUNT(*) AS customers,
    ROUND(SUM(customer_revenue), 2) AS total_revenue,
    ROUND(100.0 * SUM(customer_revenue) / SUM(SUM(customer_revenue)) OVER (), 2) AS pct_of_total_revenue,
    ROUND(AVG(customer_revenue), 2) AS avg_revenue_per_customer
FROM customer_type
GROUP BY customer_type;
