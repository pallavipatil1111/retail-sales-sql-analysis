-- Q13. Of customers who first bought in a given quarter, what share bought again 1, 2 and 3 quarters later?
-- Quarters that fall after the end of the data are shown as NULL rather than 0.
USE retail_sales;
WITH customer_quarters AS (
    SELECT DISTINCT o.customer_key, d.year * 4 + (d.quarter - 1) AS q_index
    FROM v_orders o
    JOIN dim_date d ON d.date_key = o.date_key
),
first_purchase AS (
    SELECT customer_key, MIN(q_index) AS cohort_index
    FROM customer_quarters
    GROUP BY customer_key
),
activity AS (
    SELECT fp.cohort_index, cq.customer_key, cq.q_index - fp.cohort_index AS quarters_later
    FROM customer_quarters cq
    JOIN first_purchase fp ON fp.customer_key = cq.customer_key
),
last_quarter AS (
    SELECT MAX(q_index) AS max_index FROM customer_quarters
)
SELECT
    CONCAT(FLOOR(a.cohort_index / 4), '-Q', MOD(a.cohort_index, 4) + 1)   AS cohort,
    SUM(a.quarters_later = 0)                                            AS new_customers,
    CASE WHEN a.cohort_index + 1 > lq.max_index THEN NULL
         ELSE ROUND(100 * SUM(a.quarters_later = 1) / SUM(a.quarters_later = 0), 1) END AS retained_next_q_pct,
    CASE WHEN a.cohort_index + 2 > lq.max_index THEN NULL
         ELSE ROUND(100 * SUM(a.quarters_later = 2) / SUM(a.quarters_later = 0), 1) END AS retained_q_plus_2_pct,
    CASE WHEN a.cohort_index + 3 > lq.max_index THEN NULL
         ELSE ROUND(100 * SUM(a.quarters_later = 3) / SUM(a.quarters_later = 0), 1) END AS retained_q_plus_3_pct
FROM activity a
CROSS JOIN last_quarter lq
GROUP BY a.cohort_index, lq.max_index
ORDER BY a.cohort_index;
