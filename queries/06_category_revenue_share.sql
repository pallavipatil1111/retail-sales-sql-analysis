-- Q06. What share of revenue and profit does each category contribute?
USE retail_sales;
SELECT
    p.category,
    ROUND(SUM(f.net_amount), 2)                                             AS revenue,
    ROUND(100 * SUM(f.net_amount) / SUM(SUM(f.net_amount)) OVER (), 2)      AS revenue_share_pct,
    ROUND(SUM(f.net_amount - f.cost_amount), 2)                             AS profit,
    ROUND(100 * SUM(f.net_amount - f.cost_amount) / SUM(f.net_amount), 2)   AS margin_pct
FROM fact_sales f
JOIN dim_product p ON p.product_key = f.product_key
GROUP BY p.category
ORDER BY revenue DESC;
