-- Generate a table that has 1 single row for every unique visit_id record and has the following columns:
-- user_id
-- visit_id
-- visit_start_time: the earliest event_time for each visit
-- page_views: count of page views for each visit
-- cart_adds: count of product cart add events for each visit
-- purchase: 1/0 flag if a purchase event exists for each visit
-- campaign_name: map the visit to a campaign if the visit_start_time falls between the start_date and end_date
-- impression: count of ad impressions for each visit
-- click: count of ad clicks for each visit
-- (Optional column) cart_products: a comma separated text value with products added to the cart sorted by the order they were added to the cart (hint: use the sequence_number)

SELECT user_id, 
	visit_id,
    MIN(event_time) AS visit_start_time,
    SUM(CASE WHEN e.event_type = 1 THEN 1 ELSE 0 END) AS page_views,
    SUM(CASE WHEN e.event_type = 2 THEN 1 ELSE 0 END) AS cart_adds,
   CASE WHEN e.event_type = 3 THEN 1 ELSE 0 END AS purchase,
    campaign_name,
    SUM(CASE WHEN e.event_type = 4 THEN 1 ELSE 0 END) AS impression,
    SUM(CASE WHEN e.event_type = 5 THEN 1 ELSE 0 END) AS click,
	GROUP_CONCAT(CASE WHEN p.product_id IS NOT NULL AND e.event_type = 2 THEN p.page_name ELSE NULL END ORDER BY e.sequence_number) AS cart_products
    FROM users u RIGHT JOIN events e ON u.cookie_id= e.cookie_id
			LEFT JOIN event_identifier ei ON e.event_type = ei.event_type
            LEFT JOIN page_hierarchy p ON p.page_id = e.page_id
            LEFT JOIN campaign_identifier c ON event_time BETWEEN c.start_date AND c.end_date
	GROUP BY user_id,visit_id,campaign_name
    ORDER BY user_id,visit_id