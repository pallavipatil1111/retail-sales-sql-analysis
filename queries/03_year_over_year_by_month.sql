-- Q03. How does each month of 2025 compare with the same month in 2024?
USE retail_sales;
SELECT
    month,
    ROUND(SUM(CASE WHEN year = 2024 THEN revenue ELSE 0 END), 2) AS revenue_2024,
    ROUND(SUM(CASE WHEN year = 2025 THEN revenue ELSE 0 END), 2) AS revenue_2025,
    ROUND(100 * (SUM(CASE WHEN year = 2025 THEN revenue ELSE 0 END)
               - SUM(CASE WHEN year = 2024 THEN revenue ELSE 0 END))
          / SUM(CASE WHEN year = 2024 THEN revenue ELSE 0 END), 2) AS yoy_growth_pct
FROM v_monthly_revenue
GROUP BY month
ORDER BY month;
