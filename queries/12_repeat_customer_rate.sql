-- Q12. What share of customers come back to buy again?
USE retail_sales;
WITH orders_per_customer AS (
    SELECT customer_key, COUNT(*) AS order_count
    FROM v_orders
    GROUP BY customer_key
)
SELECT
    COUNT(*)                                                         AS customers,
    SUM(CASE WHEN order_count > 1 THEN 1 ELSE 0 END)                 AS repeat_customers,
    ROUND(100 * SUM(CASE WHEN order_count > 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS repeat_rate_pct,
    ROUND(AVG(order_count), 2)                                       AS avg_orders_per_customer
FROM orders_per_customer;
