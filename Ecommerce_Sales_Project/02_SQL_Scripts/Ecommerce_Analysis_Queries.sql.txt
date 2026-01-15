/* PROJECT: TheLook E-commerce Sales & Customer Analytics AUTHOR: Jonathan Parada TOOLS: Google BigQuery (SQL) OBJECTIVE: Analyze revenue growth, product performance, and customer loyalty. */

— STEP 1: MONTHLY REVENUE & GROWTH -- Goal: Track monthly financial performance to identify growth trends. -- Business Logic: We exclude 'Cancelled' and 'Returned' orders to see Net Revenue.
SELECT
  -- Grouping the date by the first of each month
  DATE_TRUNC(created_at, MONTH) AS sales_month,
  -- Summing the total sales
  ROUND(SUM(sale_price), 2) AS total_revenue,
  -- Counting how many orders were made
  COUNT(DISTINCT order_id) AS total_orders,
  -- Calculating the Average Order Value (AOV)
  ROUND(SUM(sale_price) / COUNT(DISTINCT order_id), 2) AS avg_order_value
FROM `bigquery-public-data.thelook_ecommerce.order_items`
WHERE status NOT IN ('Cancelled', 'Returned') -- Net Revenue only
GROUP BY 1
ORDER BY 1 DESC;

-- STEP 2: PRODUCT CATEGORY PERFORMANCE -- Goal: Identify which product lines drive the most revenue. -- Business Logic: Joins 'order_items' with 'products' to get the category names.
SELECT 
  p.category,
  COUNT(oi.id) AS units_sold,
  ROUND(SUM(oi.sale_price), 2) AS total_revenue
FROM `bigquery-public-data.thelook_ecommerce.order_items` AS oi
JOIN `bigquery-public-data.thelook_ecommerce.products` AS p
  ON oi.product_id = p.id
WHERE oi.status NOT IN ('Cancelled', 'Returned')
GROUP BY 1
ORDER BY total_revenue DESC
LIMIT 10;

-- STEP 3: VIP CUSTOMER ANALYSIS -- Goal: Identify top 10 customers by total spend to inform loyalty programs.
SELECT 
    user_id,
    COUNT(order_id) AS total_orders,
    ROUND(SUM(sale_price), 2) AS total_spent,
    -- This calculates the average they spend per order
    ROUND(SUM(sale_price) / COUNT(order_id), 2) AS avg_per_order
FROM `bigquery-public-data.thelook_ecommerce.order_items`
WHERE status NOT IN ('Cancelled', 'Returned')
GROUP BY 1
ORDER BY total_spent DESC
LIMIT 10;

-- STEP 4: GLOBAL REVENUE BY COUNTRY -- Goal: Identify top-performing international markets for expansion.
SELECT 
    u.country,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    ROUND(SUM(oi.sale_price), 2) AS total_revenue
FROM `bigquery-public-data.thelook_ecommerce.order_items` AS oi
JOIN `bigquery-public-data.thelook_ecommerce.users` AS u
    ON oi.user_id = u.id
WHERE oi.status NOT IN ('Cancelled', 'Returned')
GROUP BY 1
ORDER BY total_revenue DESC;
