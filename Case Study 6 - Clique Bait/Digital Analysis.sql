-- How many users are there?
select count(distinct(user_id)) as total_users 
from users

-- How many cookies does each user have on average?
with cookie_count_cte as (
select user_id,
	count(distinct cookie_id) as cookie_count 
from users 
group by user_id)
select round(avg(cookie_count),2) as avg_cookies 
from cookie_count_cte

-- What is the unique number of visits by all users per month?
select month(event_time) as month,
	count(distinct(visit_id)) as unique_visits 
from events 
group by month(event_time)

-- What is the number of events for each event type?
select ei.event_type,
	event_name,
	count(*) 
from events e inner join event_identifier ei on e.event_type = ei.event_type 
group by event_type,event_name

-- What is the percentage of visits which have a purchase event?
with visits_cte as (select event_name,
	count(distinct visit_id) as visits
from events e inner join event_identifier ei on e.event_type = ei.event_type 
group by event_name)
select round(100 * max(case when event_name = 'Purchase' then visits end)/sum(visits),2)
from visits_cte


-- What is the percentage of visits which view the checkout page but do not have a purchase event?
with visit_cte as (
select visit_id,
	page_id as checkout,
	lead(page_id) over(partition by visit_id order by sequence_number) as purchase
from events
where page_id in ('12','13') 
order by cookie_id,event_time)
select round(100 * sum(case when checkout = 12 and purchase is null then 1 else 0 end)/count(distinct(visit_id)),2) as per_visits
from visit_cte

-- What are the top 3 pages by number of views?
with pages_cte as (select event_name,
	page_name,
	count(*) as count
from events e inner join event_identifier ei on e.event_type = ei.event_type
inner join page_hierarchy p on e.page_id = p.page_id
where event_name = 'Page View' 
group by event_name,page_name
order by count desc
limit 3)
select page_name from pages_cte

-- What is the number of views and cart adds for each product category?
select product_category,
	sum(case when event_name = 'Page View' then 1 else 0 end) as page_views,
    sum(case when event_name = 'Add to Cart' then 1 else 0 end) as add_to_cart
from events e inner join event_identifier ei on e.event_type = ei.event_type
inner join page_hierarchy p on e.page_id = p.page_id
where product_category is not null
group by product_category

-- What are the top 3 products by purchases?
select page_name,count(*) as count 
from events e inner join event_identifier ei on e.event_type = ei.event_type
inner join page_hierarchy p on e.page_id = p.page_id
where event_name = 'Add to Cart' 
	and product_id is not null
    and visit_id in (select distinct visit_id from events where event_type = 3)
group by page_name
order by count desc
limit 3

