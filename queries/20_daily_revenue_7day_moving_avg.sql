-- Q20. What is the 7-day moving average of daily revenue during the 2025 festive season?
USE retail_sales;
WITH daily AS (
    SELECT d.full_date, SUM(f.net_amount) AS revenue
    FROM fact_sales f
    JOIN dim_date d ON d.date_key = f.date_key
    GROUP BY d.full_date
)
SELECT
    full_date,
    ROUND(revenue, 2) AS revenue,
    ROUND(AVG(revenue) OVER (ORDER BY full_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW), 2) AS moving_avg_7d
FROM daily
WHERE full_date BETWEEN '2025-09-15' AND '2025-12-15'
ORDER BY full_date;
