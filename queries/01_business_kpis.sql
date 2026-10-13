-- Q01. What are the headline numbers for the whole period?
USE retail_sales;
SELECT
    COUNT(DISTINCT f.order_id)                                         AS total_orders,
    COUNT(DISTINCT f.customer_key)                                     AS active_customers,
    ROUND(SUM(f.net_amount), 2)                                        AS revenue,
    ROUND(SUM(f.net_amount - f.cost_amount), 2)                        AS profit,
    ROUND(100 * SUM(f.net_amount - f.cost_amount) / SUM(f.net_amount), 2) AS margin_pct,
    ROUND(SUM(f.net_amount) / COUNT(DISTINCT f.order_id), 2)           AS avg_order_value
FROM fact_sales f;
