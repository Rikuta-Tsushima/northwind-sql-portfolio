
)
SELECT
  a.cohort_month::date,
  a.months_since,
  a.active_customers,
  c.customers_in_cohort,
  ROUND(100.0 * a.active_customers / c.customers_in_cohort, 1) AS active_rate_pct
FROM active_counts a
JOIN cohort_size c USING (cohort_month)
WHERE a.months_since BETWEEN 0 AND 6     -- まずは+6ヶ月ま-- A) 全体のリピート率（初回購入以降にもう一度買った人の割合）
WITH first_tx AS (
  SELECT
    customer_id,
    MIN(order_date) AS first_date
  FROM vw_order_lines
  GROUP BY customer_id
),
repeats AS (
  SELECT
    f.customer_id,
    -- 初回以降の注文が1件でもあればリピート
    COUNT(*) FILTER (WHERE v.order_date > f.first_date) AS repeat_orders
  FROM first_tx f
  LEFT JOIN vw_order_lines v
    ON v.customer_id = f.customer_id
  GROUP BY f.customer_id
)
SELECT
  ROUND(
    100.0 * COUNT(*) FILTER (WHERE repeat_orders > 0)
    / COUNT(*)
  , 1) AS repeat_rate_pct,
  COUNT(*) FILTER (WHERE repeat_orders > 0) AS repeat_customers,
  COUNT(*) AS total_customers
FROM repeats;
