-- Q18. Which products never sold or sold fewer than 20 units?
USE retail_sales;
SELECT
    p.product_name,
    p.category,
    COALESCE(SUM(f.quantity), 0)  AS units_sold,
    CASE WHEN SUM(f.quantity) IS NULL THEN 'Never sold' ELSE 'Slow mover' END AS status
FROM dim_product p
LEFT JOIN fact_sales f ON f.product_key = p.product_key
GROUP BY p.product_key, p.product_name, p.category
HAVING COALESCE(SUM(f.quantity), 0) < 20
ORDER BY units_sold, p.product_name;
