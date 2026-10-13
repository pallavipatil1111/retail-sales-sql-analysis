-- Q11. How much bigger are sales during the October–November festive season?
USE retail_sales;
SELECT
    CASE WHEN d.is_festive_season = 1 THEN 'Festive (Oct–Nov)' ELSE 'Rest of year' END AS season,
    COUNT(DISTINCT d.date_key)                                   AS days,
    ROUND(SUM(f.net_amount) / COUNT(DISTINCT d.date_key), 2)     AS revenue_per_day,
    ROUND(AVG(f.discount_pct), 2)                                AS avg_discount_pct,
    ROUND(100 * SUM(f.net_amount - f.cost_amount) / SUM(f.net_amount), 2) AS margin_pct
FROM fact_sales f
JOIN dim_date d ON d.date_key = f.date_key
GROUP BY season;
