-- Q19. Which pairs of categories are most often bought together in the same order?
USE retail_sales;
SELECT
    pa.category AS category_a,
    pb.category AS category_b,
    COUNT(DISTINCT a.order_id) AS orders_together
FROM fact_sales a
JOIN fact_sales b   ON b.order_id = a.order_id AND b.sales_id > a.sales_id
JOIN dim_product pa ON pa.product_key = a.product_key
JOIN dim_product pb ON pb.product_key = b.product_key
WHERE pa.category < pb.category
GROUP BY pa.category, pb.category
ORDER BY orders_together DESC
LIMIT 10;
