-- サプライヤごとに商品売上TOP3を出す

WITH prod_sales AS (
  SELECT
    supplier_id,
    product_id,
    SUM(line_revenue) AS revenue
  FROM vw_order_lines
  GROUP BY supplier_id, product_id
),
ranked AS (
  SELECT
    supplier_id,
    product_id,
    revenue,
    DENSE_RANK() OVER (
      PARTITION BY supplier_id
      ORDER BY revenue DESC
    ) AS rk_in_supplier
  FROM prod_sales
)
SELECT
  s.company_name AS supplier,
  p.product_name AS product,
  r.revenue,
  r.rk_in_supplier
FROM ranked r
JOIN suppliers s   ON r.supplier_id = s.supplier_id
JOIN products  p   ON r.product_id  = p.product_id
WHERE rk_in_supplier <= 3
ORDER BY supplier, rk_in_supplier;