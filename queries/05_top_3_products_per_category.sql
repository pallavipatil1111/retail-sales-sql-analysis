-- Q05. What are the top 3 products in each category?
USE retail_sales;
WITH product_revenue AS (
    SELECT
        p.category,
        p.product_name,
        SUM(f.net_amount) AS revenue,
        ROW_NUMBER() OVER (PARTITION BY p.category ORDER BY SUM(f.net_amount) DESC) AS rank_in_category
    FROM fact_sales f
    JOIN dim_product p ON p.product_key = f.product_key
    GROUP BY p.category, p.product_key, p.product_name
)
SELECT category, rank_in_category, product_name, ROUND(revenue, 2) AS revenue
FROM product_revenue
WHERE rank_in_category <= 3
ORDER BY category, rank_in_category;
