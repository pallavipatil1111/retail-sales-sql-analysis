-- Q16. How is the payment mix shifting between years?
USE retail_sales;
SELECT
    d.year,
    o.payment_method,
    COUNT(*)                                                             AS orders,
    ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY d.year), 2)  AS share_pct
FROM v_orders o
JOIN dim_date d ON d.date_key = o.date_key
GROUP BY d.year, o.payment_method
ORDER BY d.year, orders DESC;
