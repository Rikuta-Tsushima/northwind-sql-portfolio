-- 03_employee_ranking.sql
-- 従業員の売上ランキング（全期間 / 月別）

-- A) 全期間のランキング
WITH emp_total AS (
  SELECT
    employee_id,
    SUM(line_revenue) AS revenue
  FROM vw_order_lines
  GROUP BY employee_id
)
SELECT
  employee_id,
  revenue,
  RANK()       OVER (ORDER BY revenue DESC) AS rk,         -- 同率で飛び番
  DENSE_RANK() OVER (ORDER BY revenue DESC) AS dense_rk    -- 同率でも詰める
FROM emp_total
ORDER BY rk, employee_id;

-- B) 月別のランキング（各月内での順位）
WITH emp_month AS (
  SELECT
    order_month,
    employee_id,
    SUM(line_revenue) AS revenue
  FROM vw_order_lines
  GROUP BY order_month, employee_id
)
SELECT
  order_month,
  employee_id,
  revenue,
  DENSE_RANK() OVER (
    PARTITION BY order_month
    ORDER BY revenue DESC
  ) AS rk_in_month
FROM emp_month
ORDER BY order_month, rk_in_month, employee_id;