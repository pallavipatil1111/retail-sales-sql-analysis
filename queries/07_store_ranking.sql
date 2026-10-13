-- Q07. How do stores rank on revenue and margin, overall and within their region?
USE retail_sales;
SELECT
    store_name,
    region,
    store_type,
    orders,
    ROUND(revenue, 2)                                                 AS revenue,
    margin_pct,
    RANK() OVER (ORDER BY revenue DESC)                               AS overall_rank,
    RANK() OVER (PARTITION BY region ORDER BY revenue DESC)           AS rank_in_region
FROM v_store_performance
ORDER BY revenue DESC;
