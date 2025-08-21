--  配送先の国（ship_country）ごとに集計してランキング
WITH by_ship AS (
  SELECT
    o.ship_country                           AS country,
    COUNT(DISTINCT v.customer_id)            AS customers,
    COUNT(DISTINCT v.order_id)               AS orders,
    SUM(v.line_revenue)                      AS revenue
  FROM vw_order_lines v
  JOIN orders o ON o.order_id = v.order_id
  GROUP BY o.ship_country
)
SELECT
  country,
  customers,
  orders,
  ROUND(revenue, 2)                                         AS revenue,
  ROUND(revenue / NULLIF(orders, 0), 2)                     AS avg_order_value
FROM by_ship
ORDER BY revenue DESC;
