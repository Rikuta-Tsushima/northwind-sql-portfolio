-- 利益率の代理指標として「割引後売上 ÷ 割引前売上」をカテゴリごとに比較
-- 値が高いほど「割引が少なく、利幅が大きい」カテゴリと解釈できる

WITH cat_sales AS (
  SELECT
    p.category_id,
    -- 割引前売上と割引後売上を numeric に寄せる
    SUM(od.quantity * od.unit_price)::numeric(14,2)                             AS gross_sales,
    SUM(od.quantity * od.unit_price * (1 - od.discount))::numeric(14,2)         AS net_sales
  FROM order_details od
  JOIN products p ON p.product_id = od.product_id
  GROUP BY p.category_id
)
SELECT
  c.category_name,
  -- 0除算を避けるため NULLIF。numeric にキャストしてから ROUND( , digits )
  ROUND( (net_sales / NULLIF(gross_sales, 0))::numeric, 3 )         AS margin_ratio,
  ROUND( (100 * (1 - net_sales / NULLIF(gross_sales, 0)))::numeric, 1 ) AS avg_discount_pct,
  net_sales
FROM cat_sales cs
JOIN categories c ON c.category_id = cs.category_id
ORDER BY margin_ratio DESC;