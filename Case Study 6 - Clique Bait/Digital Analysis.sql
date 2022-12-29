-- How many users are there?
SELECT COUNT(DISTINCT(user_id)) AS total_users 
FROM users

-- How many cookies does each user have on average?
WITH cookie_COUNT_cte AS (
SELECT user_id,
	COUNT(DISTINCT cookie_id) AS cookie_COUNT 
FROM users 
GROUP BY user_id)
SELECT ROUND(AVG(cookie_COUNT),2) AS AVG_cookies 
FROM cookie_COUNT_cte

-- What is the unique number of visits by all users per MONTH?
SELECT MONTH(event_time) AS MONTH,
	COUNT(DISTINCT(visit_id)) AS unique_visits 
FROM events 
GROUP BY MONTH(event_time)

-- What is the number of events for each event type?
SELECT ei.event_type,
	event_name,
	COUNT(*) 
FROM events e INNER JOIN event_identifier ei ON e.event_type = ei.event_type 
GROUP BY event_type,event_name

-- What is the percentage of visits which have a purchase event?
WITH visits_cte AS (SELECT event_name,
	COUNT(DISTINCT visit_id) AS visits
FROM events e INNER JOIN event_identifier ei ON e.event_type = ei.event_type 
GROUP BY event_name)
SELECT ROUND(100 * MAX(CASE WHEN event_name = 'Purchase' THEN visits END)/SUM(visits),2)
FROM visits_cte


-- What is the percentage of visits which view the checkout page but do not have a purchase event?
WITH visit_cte AS (
SELECT visit_id,
	page_id AS checkout,
	LEAD(page_id) OVER(PARTITION BY visit_id ORDER BY sequence_number) AS purchase
FROM events
WHERE page_id IN ('12','13') 
ORDER BY cookie_id,event_time)
SELECT ROUND(100 * SUM(CASE WHEN checkout = 12 AND purchase IS NULL THEN 1 ELSE 0 END)/COUNT(DISTINCT(visit_id)),2) AS per_visits
FROM visit_cte

-- What are the top 3 pages by number of views?
WITH pages_cte AS (SELECT event_name,
	page_name,
	COUNT(*) AS COUNT
FROM events e INNER JOIN event_identifier ei ON e.event_type = ei.event_type
INNER JOIN page_hierarchy p ON e.page_id = p.page_id
WHERE event_name = 'Page View' 
GROUP BY event_name,page_name
ORDER BY COUNT DESC
LIMIT 3)
SELECT page_name FROM pages_cte

-- What is the number of views and cart adds for each product category?
SELECT product_category,
	sum(CASE WHEN event_name = 'Page View' THEN 1 else 0 END) AS page_views,
    sum(CASE WHEN event_name = 'Add to Cart' THEN 1 else 0 END) AS add_to_cart
FROM events e INNER JOIN event_identifier ei ON e.event_type = ei.event_type
INNER JOIN page_hierarchy p ON e.page_id = p.page_id
WHERE product_category IS NOT NULL
GROUP BY product_category

-- What are the top 3 products by purchases?
SELECT page_name,COUNT(*) AS COUNT 
FROM events e INNER JOIN event_identifier ei ON e.event_type = ei.event_type
INNER JOIN page_hierarchy p ON e.page_id = p.page_id
WHERE event_name = 'Add to Cart' 
	AND product_id IS NOT NULL
    AND visit_id IN (SELECT DISTINCT visit_id FROM events WHERE event_type = 3)
GROUP BY page_name
ORDER BY COUNT DESC
LIMIT 3

