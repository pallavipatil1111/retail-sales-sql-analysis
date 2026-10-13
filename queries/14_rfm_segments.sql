-- Q14. Which customers are champions, loyal, at risk or lost (RFM segmentation)?
USE retail_sales;
WITH scored AS (
    SELECT
        customer_key,
        recency_days,
        frequency,
        monetary,
        6 - NTILE(5) OVER (ORDER BY recency_days) AS r_score,   -- recent buyers score high
        NTILE(5) OVER (ORDER BY frequency)        AS f_score,
        NTILE(5) OVER (ORDER BY monetary)         AS m_score
    FROM v_customer_rfm
),
segmented AS (
    SELECT *,
        CASE
            WHEN r_score >= 4 AND f_score >= 4                 THEN 'Champions'
            WHEN r_score >= 3 AND f_score >= 3                 THEN 'Loyal'
            WHEN r_score >= 4 AND f_score <= 2                 THEN 'New / promising'
            WHEN r_score <= 2 AND f_score >= 3                 THEN 'At risk'
            ELSE 'Lost / low value'
        END AS segment
    FROM scored
)
SELECT
    segment,
    COUNT(*)                         AS customers,
    ROUND(AVG(recency_days), 0)      AS avg_recency_days,
    ROUND(AVG(frequency), 1)         AS avg_orders,
    ROUND(SUM(monetary), 2)          AS total_revenue,
    ROUND(100 * SUM(monetary) / SUM(SUM(monetary)) OVER (), 2) AS revenue_share_pct
FROM segmented
GROUP BY segment
ORDER BY total_revenue DESC;
