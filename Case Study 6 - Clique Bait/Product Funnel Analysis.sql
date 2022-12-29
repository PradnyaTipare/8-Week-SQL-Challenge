-- Using a single SQL query - create a new output table which has the following details:
-- How many times was each product viewed?
-- How many times was each product added to cart?
-- How many times was each product added to a cart but not purchased (abandoned)?
-- How many times was each product purchased?
create TEMPORARY table product_info (
with temp_table as (
select visit_id,
	p.page_id,
	page_name,
	event_type 
from events e inner join page_hierarchy p on p.page_id = e.page_id
WHERE product_id IS NOT NULL
group by visit_id,p.page_id,page_name,event_type),
abandoned_cte as (
select page_name,
	count(distinct(visit_id)) as abandoned
from temp_table
where event_type = 2 
	and visit_id not in (select distinct visit_id from events where event_type = 3)
group by page_name),
purchased_cte as (
select page_name,
	count(distinct(visit_id)) as purchased
from temp_table
where event_type = 2 
	and visit_id in (select distinct visit_id from events where event_type = 3)
group by page_name)
select t.page_name,
	sum(case when event_type = 1 then 1 else 0 end) as product_viewed,
    sum(case when event_type = 2 then 1 else 0 end) as added_to_cart,
    abandoned,
    purchased
from temp_table t left join abandoned_cte a on t.page_name = a.page_name
	left join purchased_cte p on p.page_name = t.page_name
group by t.page_name)

-- Additionally, create another table which further aggregates the data for the above points but this time for each product category instead of individual products.
create temporary table product_category_info (
with temp_table as (
select visit_id,
	page_name,
    product_category,
	event_type 
from events e inner join page_hierarchy p on p.page_id = e.page_id
WHERE product_id IS NOT NULL
group by visit_id,page_name,product_category,event_type),
abandoned_cte as (
select product_category,
	count(visit_id) as abandoned
from temp_table
where event_type = 2 
	and visit_id not in (select distinct visit_id from events where event_type = 3)
group by product_category),
purchased_cte as (
select product_category,
	count(visit_id) as purchased
from temp_table
where event_type = 2 
	and visit_id in (select distinct visit_id from events where event_type = 3)
group by product_category) 
select t.product_category,
	sum(case when event_type = 1 then 1 else 0 end) as product_viewed,
    sum(case when event_type = 2 then 1 else 0 end) as added_to_cart,
    abandoned,
    purchased
from temp_table t left join abandoned_cte a on t.product_category = a.product_category
	left join purchased_cte p on p.product_category = t.product_category
group by t.product_category)

-- Use your 2 new output tables - answer the following questions:
-- Which product had the most views, cart adds and purchases?

select page_name from product_info order by product_viewed desc limit 1;
select page_name from product_info order by added_to_cart desc limit 1
select page_name from product_info order by purchased desc limit 1

-- Which product was most likely to be abandoned?
select page_name 
from product_info 
order by abandoned desc 
limit 1

-- Which product had the highest view to purchase percentage?
select page_name,
	round(100*(purchased/product_viewed),2) as per 
from product_info 
order by per desc 
limit 1 

-- What is the average conversion rate from view to cart add?
-- What is the average conversion rate from cart add to purchase?
SELECT 
  ROUND(100*AVG(added_to_cart/product_viewed),2) AS avg_view_to_cart_add_conversion,
  ROUND(100*AVG(purchased/added_to_cart),2) AS avg_cart_add_to_purchases_conversion_rate
FROM product_info

