-- Q10. Do weekend orders differ from weekday orders?
USE retail_sales;
SELECT
    CASE WHEN d.is_weekend = 1 THEN 'Weekend' ELSE 'Weekday' END AS day_type,
    COUNT(DISTINCT d.date_key)                                     AS days,
    COUNT(*)                                                       AS orders,
    ROUND(COUNT(*) / COUNT(DISTINCT d.date_key), 1)                AS orders_per_day,
    ROUND(AVG(o.order_value), 2)                                   AS avg_order_value
FROM v_orders o
JOIN dim_date d ON d.date_key = o.date_key
GROUP BY day_type;
