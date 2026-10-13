-- Q04. Which 10 products bring in the most revenue?
USE retail_sales;
SELECT
    RANK() OVER (ORDER BY SUM(f.net_amount) DESC) AS revenue_rank,
    p.product_name,
    p.category,
    SUM(f.quantity)                               AS units_sold,
    ROUND(SUM(f.net_amount), 2)                   AS revenue
FROM fact_sales f
JOIN dim_product p ON p.product_key = f.product_key
GROUP BY p.product_key, p.product_name, p.category
ORDER BY revenue DESC
LIMIT 10;
