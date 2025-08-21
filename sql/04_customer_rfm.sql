-- 顧客ごとの RFM（Recency / Frequency / Monetary）
-- Recencyは「最近買ったほど良い」ので分位をあとで反転します（5が最優良）

WITH tx AS (
  SELECT
    customer_id,
    MAX(order_date)                  AS last_order_date,
    COUNT(DISTINCT order_id)         AS freq_orders,
    SUM(line_revenue)                AS monetary
  FROM vw_order_lines
  GROUP BY customer_id
),
base AS (
  SELECT
    customer_id,
    (CURRENT_DATE - last_order_date)::int AS recency_days,  -- 小さいほど良い
    freq_orders,
    monetary
  FROM tx
),
binned AS (
  SELECT
    customer_id,
    NTILE(5) OVER (ORDER BY recency_days ASC) AS r_raw,     -- 近い=良い → 昇順でビン
    NTILE(5) OVER (ORDER BY freq_orders DESC) AS f,         -- 多いほど良い
    NTILE(5) OVER (ORDER BY monetary   DESC) AS m           -- 高いほど良い
  FROM base
)
SELECT
  customer_id,
  (6 - r_raw) AS r,               -- 1..5に反転（5が最良）
  f, m,
  (6 - r_raw) + f + m AS rfm_score
FROM binned
ORDER BY rfm_score DESC, customer_id
LIMIT 50;  -- まずは上位だけ確認