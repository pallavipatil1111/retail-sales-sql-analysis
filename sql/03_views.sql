-- =====================================================================
-- Reusable views that the analysis queries and charts build on.
-- =====================================================================
USE retail_sales;

-- Revenue, cost, profit and orders per calendar month
CREATE OR REPLACE VIEW v_monthly_revenue AS
SELECT
    d.year,
    d.month,
    DATE_FORMAT(d.full_date, '%Y-%m')      AS month_label,
    COUNT(DISTINCT f.order_id)             AS orders,
    SUM(f.net_amount)                      AS revenue,
    SUM(f.cost_amount)                     AS cost,
    SUM(f.net_amount - f.cost_amount)      AS profit
FROM fact_sales f
JOIN dim_date d ON d.date_key = f.date_key
GROUP BY d.year, d.month, DATE_FORMAT(d.full_date, '%Y-%m');

-- One row per order with its total value (used for basket and AOV questions)
CREATE OR REPLACE VIEW v_orders AS
SELECT
    f.order_id,
    MIN(f.date_key)      AS date_key,
    MIN(f.store_key)     AS store_key,
    MIN(f.customer_key)  AS customer_key,
    MIN(f.payment_method) AS payment_method,
    COUNT(*)             AS line_count,
    SUM(f.quantity)      AS items,
    SUM(f.net_amount)    AS order_value
FROM fact_sales f
GROUP BY f.order_id;

-- Store scorecard
CREATE OR REPLACE VIEW v_store_performance AS
SELECT
    s.store_key,
    s.store_name,
    s.city,
    s.region,
    s.store_type,
    COUNT(DISTINCT f.order_id)                                       AS orders,
    SUM(f.net_amount)                                                AS revenue,
    SUM(f.net_amount - f.cost_amount)                                AS profit,
    ROUND(100 * SUM(f.net_amount - f.cost_amount) / SUM(f.net_amount), 2) AS margin_pct
FROM fact_sales f
JOIN dim_store s ON s.store_key = f.store_key
GROUP BY s.store_key, s.store_name, s.city, s.region, s.store_type;

-- Recency, frequency and monetary value per customer (input for RFM scoring)
CREATE OR REPLACE VIEW v_customer_rfm AS
SELECT
    o.customer_key,
    DATEDIFF('2025-12-31', MAX(d.full_date)) AS recency_days,
    COUNT(*)                                  AS frequency,
    SUM(o.order_value)                        AS monetary
FROM v_orders o
JOIN dim_date d ON d.date_key = o.date_key
GROUP BY o.customer_key;
