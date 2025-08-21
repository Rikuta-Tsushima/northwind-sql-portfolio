-- 02_monthly_sales_ma.sql
-- 月次売上と3ヶ月移動平均（当月＋直近2ヶ月の平均）

WITH monthly AS (
  SELECT
    order_month,
    SUM(line_revenue) AS monthly_revenue
  FROM vw_order_lines
  GROUP BY order_month
)
SELECT
  order_month,
  monthly_revenue,
  AVG(monthly_revenue) OVER (
    ORDER BY order_month
    ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
  ) AS ma_3m
FROM monthly
ORDER BY order_month;
