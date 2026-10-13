-- Q17. Which discount levels still make money, by category?
USE retail_sales;
SELECT
    p.category,
    f.discount_pct,
    COUNT(*)                                                              AS order_lines,
    ROUND(SUM(f.net_amount), 2)                                           AS revenue,
    ROUND(100 * SUM(f.net_amount - f.cost_amount) / SUM(f.net_amount), 2) AS margin_pct
FROM fact_sales f
JOIN dim_product p ON p.product_key = f.product_key
GROUP BY p.category, f.discount_pct
ORDER BY p.category, f.discount_pct;
