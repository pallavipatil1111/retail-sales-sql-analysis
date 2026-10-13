-- Q08. How is revenue split across regions and quarters?
USE retail_sales;
SELECT
    s.region,
    d.year,
    ROUND(SUM(CASE WHEN d.quarter = 1 THEN f.net_amount ELSE 0 END), 2) AS q1,
    ROUND(SUM(CASE WHEN d.quarter = 2 THEN f.net_amount ELSE 0 END), 2) AS q2,
    ROUND(SUM(CASE WHEN d.quarter = 3 THEN f.net_amount ELSE 0 END), 2) AS q3,
    ROUND(SUM(CASE WHEN d.quarter = 4 THEN f.net_amount ELSE 0 END), 2) AS q4
FROM fact_sales f
JOIN dim_store s ON s.store_key = f.store_key
JOIN dim_date d  ON d.date_key  = f.date_key
GROUP BY s.region, d.year
ORDER BY s.region, d.year;
