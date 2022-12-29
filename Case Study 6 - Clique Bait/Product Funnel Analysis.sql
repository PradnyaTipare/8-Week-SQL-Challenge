-- UsINg a sINgle SQL query - CREATE a new output TABLE which has the followINg details:
-- How many times was each product viewed?
-- How many times was each product added to cart?
-- How many times was each product added to a cart but not purchased (abANDoned)?
-- How many times was each product purchased?
CREATE TEMPORARY TABLE product_info (
WITH temp_table AS (
SELECT visit_id,
	p.page_id,
	page_name,
	event_type 
FROM events e INNER JOIN page_hierarchy p ON p.page_id = e.page_id
WHERE product_id IS NOT NULL
GROUP BY visit_id,p.page_id,page_name,event_type),
abandoned_cte AS (
SELECT page_name,
	COUNT(DISTINCT(visit_id)) AS abandoned
FROM temp_TABLE
WHERE event_type = 2 
	AND visit_id NOT IN (SELECT DISTINCT visit_id FROM events WHERE event_type = 3)
GROUP BY page_name),
purchased_cte AS (
SELECT page_name,
	COUNT(DISTINCT(visit_id)) AS purchased
FROM temp_table
WHERE event_type = 2 
	AND visit_id IN (SELECT DISTINCT visit_id FROM events WHERE event_type = 3)
GROUP BY page_name)
SELECT t.page_name,
	SUM(CASE WHEN event_type = 1 THEN 1 ELSE 0 END) AS product_viewed,
    SUM(CASE WHEN event_type = 2 THEN 1 ELSE 0 END) AS added_to_cart,
    abandoned,
    purchased
FROM temp_table t LEFT JOIN abandoned_cte a ON t.page_name = a.page_name
	LEFT JOIN purchased_cte p ON p.page_name = t.page_name
GROUP BY t.page_name)

-- Additionally, CREATE another TABLE which further aggregates the data for the above poINts but this time for each product category INstead of INdividual products.
CREATE TEMPORARY TABLE product_category_info (
WITH temp_table AS (
SELECT visit_id,
	page_name,
    product_category,
	event_type 
FROM events e INNER JOIN page_hierarchy p ON p.page_id = e.page_id
WHERE product_id IS NOT NULL
GROUP BY visit_id,page_name,product_category,event_type),
abandoned_cte AS (
SELECT product_category,
	COUNT(visit_id) AS abandoned
FROM temp_table
WHERE event_type = 2 
	AND visit_id NOT IN (SELECT DISTINCT visit_id FROM events WHERE event_type = 3)
GROUP BY product_category),
purchased_cte AS (
SELECT product_category,
	COUNT(visit_id) AS purchased
FROM temp_table
WHERE event_type = 2 
	AND visit_id IN (SELECT DISTINCT visit_id FROM events WHERE event_type = 3)
GROUP BY product_category) 
SELECT t.product_category,
	SUM(CASE WHEN event_type = 1 THEN 1 ELSE 0 END) AS product_viewed,
    SUM(CASE WHEN event_type = 2 THEN 1 ELSE 0 END) AS added_to_cart,
    abandoned,
    purchased
FROM temp_table t LEFT JOIN abandoned_cte a ON t.product_category = a.product_category
	LEFT JOIN purchased_cte p ON p.product_category = t.product_category
GROUP BY t.product_category)

-- Use your 2 new output TABLEs - answer the followINg questions:
-- Which product had the most views, cart adds AND purchases?

SELECT page_name FROM product_info ORDER BY product_viewed DESC LIMIT 1;
SELECT page_name FROM product_info ORDER BY added_to_cart DESC LIMIT 1
SELECT page_name FROM product_info ORDER BY purchased DESC LIMIT 1

-- Which product was most likely to be abANDoned?
SELECT page_name 
FROM product_info 
ORDER BY abandoned DESC 
LIMIT 1

-- Which product had the highest view to purchase percentage?
SELECT page_name,
	ROUND(100*(purchased/product_viewed),2) AS per 
FROM product_info 
ORDER BY per DESC
LIMIT 1 

-- What is the average conversion rate FROM view to cart add?
-- What is the average conversion rate FROM cart add to purchase?
SELECT 
  ROUND(100*AVG(added_to_cart/product_viewed),2) AS avg_view_to_cart_add_conversion,
  ROUND(100*AVG(purchased/added_to_cart),2) AS avg_cart_add_to_purchases_conversion_rate
FROM product_INfo

