-- Q02. How did revenue change month on month?
USE retail_sales;
SELECT
    month_label,
    ROUND(revenue, 2)                                               AS revenue,
    ROUND(LAG(revenue) OVER (ORDER BY year, month), 2)              AS prev_month_revenue,
    ROUND(100 * (revenue - LAG(revenue) OVER (ORDER BY year, month))
          / LAG(revenue) OVER (ORDER BY year, month), 2)            AS mom_growth_pct
FROM v_monthly_revenue
ORDER BY year, month;
