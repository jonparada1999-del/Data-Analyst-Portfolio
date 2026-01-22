/* PROJECT: Logistics & Supply Chain Efficiency Analysis AUTHOR: Jonathan Parada TOOLS: Google BigQuery (SQL), Looker Studio OBJECTIVE: Calculating lead times and identifying warehouse bottlenecks. */ -- -- CODE #1: INITIAL DIRECT JOIN (Baseline Lead Time) -- 
-- PURPOSE: To quickly calculate the Average Lead Time by connecting -- order_items directly to distribution_centers. -- 
-- THE LOGIC: It used inventory_item_id as the primary key to find -- which warehouse shipped which order. -- 
-- OUTCOME: Successfully calculated the company-wide average of 2.66 days, -- but resulted in "null" values for the Warehouse Names in Looker Studio -- due to inconsistent ID mapping in the raw dataset.
SELECT 
  items.order_id,
  dist.name AS center_name,
  items.created_at AS order_date,
  items.shipped_at,
  items.delivered_at,
  -- This calculates days from order to shipment
  DATE_DIFF(items.shipped_at, items.created_at, DAY) AS days_to_ship,
  -- This calculates total days from order to front door
  DATE_DIFF(items.delivered_at, items.created_at, DAY) AS total_lead_time
FROM `bigquery-public-data.thelook_ecommerce.order_items` AS items
LEFT JOIN `bigquery-public-data.thelook_ecommerce.distribution_centers` AS dist
  ON items.inventory_item_id = dist.id
WHERE items.status = 'Complete'

-- CODE #2: THE "BRIDGE" QUERY (Final Data Integrity Solution) -- 
-- PURPOSE: To resolve the "null" data gap and successfully map -- performance metrics to specific geographic locations. -- 
-- THE LOGIC: Instead of a direct jump, I engineered a multi-table JOIN -- using the products table as a "bridge". -- Logic Flow: Order Items -> Products -> Distribution Centers. --
-- WHY I SWITCHED: The initial inventory_item_id link was inconsistent -- in the dataset. By switching to a Product-to-Warehouse mapping, -- I ensured 100% data integrity, allowing names like Chicago IL and -- Memphis TN to appear in the final executive report.
SELECT 
  oi.order_id,
  dc.name AS center_name,
  oi.created_at AS order_date,
  DATE_DIFF(oi.delivered_at, oi.created_at, DAY) AS total_lead_time
FROM `bigquery-public-data.thelook_ecommerce.order_items` AS oi
-- This connects the order to the product
JOIN `bigquery-public-data.thelook_ecommerce.products` AS p 
  ON oi.product_id = p.id
-- This connects the product to the specific warehouse
JOIN `bigquery-public-data.thelook_ecommerce.distribution_centers` AS dc 
  ON p.distribution_center_id = dc.id
WHERE oi.status = 'Complete'
