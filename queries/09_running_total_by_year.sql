-- Q09. How does cumulative revenue build up through each year?
USE retail_sales;
SELECT
    year,
    month_label,
    ROUND(revenue, 2)                                                     AS revenue,
    ROUND(SUM(revenue) OVER (PARTITION BY year ORDER BY month
                             ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW), 2) AS running_total
FROM v_monthly_revenue
ORDER BY year, month;
