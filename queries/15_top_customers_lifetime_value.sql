-- Q15. Who are the 10 most valuable customers, and which loyalty tier are they in?
USE retail_sales;
SELECT
    c.customer_code,
    c.loyalty_tier,
    c.city,
    COUNT(DISTINCT f.order_id)    AS orders,
    ROUND(SUM(f.net_amount), 2)   AS lifetime_value,
    DATE_FORMAT(MIN(d.full_date), '%Y-%m-%d') AS first_purchase,
    DATE_FORMAT(MAX(d.full_date), '%Y-%m-%d') AS last_purchase
FROM fact_sales f
JOIN dim_customer c ON c.customer_key = f.customer_key
JOIN dim_date d     ON d.date_key     = f.date_key
GROUP BY c.customer_key, c.customer_code, c.loyalty_tier, c.city
ORDER BY lifetime_value DESC
LIMIT 10;
