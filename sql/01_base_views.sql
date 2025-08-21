-- Northwindの注文明細を「分析で使いやすい形」にまとめた行ビュー
-- 以降の全クエリはこのビューを土台に

CREATE OR REPLACE VIEW public.vw_order_lines AS
SELECT
  od.order_id,
  o.order_date::date                                 AS order_date,
  date_trunc('month', o.order_date)::date            AS order_month,
  od.product_id,
  p.category_id,
  p.supplier_id,
  o.customer_id,
  o.employee_id,
  od.quantity                                        AS qty,
  od.unit_price,
  od.discount,
  (od.quantity * od.unit_price * (1 - od.discount))::numeric(12,2) AS line_revenue
FROM public.order_details od
JOIN public.orders   o ON o.order_id = od.order_id
JOIN public.products p ON p.product_id = od.product_id;
