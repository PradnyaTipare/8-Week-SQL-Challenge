-- What was the total quantity sold for all products?
SELECT SUM(qty) AS total_quantity 
FROM sales

-- What is the total generated revenue for all products before discounts?
SELECT SUM(qty*price) AS total_generated_revenue 
FROM sales

-- What was the total discount amount for all products?
SELECT SUM(discount) AS total_discount_amount 
FROM sales

-- How many unique transactions were there?
SELECT COUNT(DISTINCT(txn_id)) AS transactions 
FROM sales

-- What is the average unique products purchased in each transaction?
SELECT SUM(qty)/COUNT(DISTINCT(txn_id)) as avg_unique_products 
FROM sales

-- What are the 25th, 50th and 75th percentile values for the revenue per transaction?

-- What is the average discount value per transaction?
SELECT SUM(discount)/COUNT(DISTINCT(txn_id)) AS avg_discount FROM sales

-- What is the percentage split of all transactions for members vs non-members?
select 100*count(distinct(case when member = TRUE THEN txn_id else null end))/count(distinct(txn_id)) as members, 
	100*count(distinct(case when member = FALSE THEN txn_id else null end))/count(distinct(txn_id)) as non_members
from sales

-- What is the average revenue for member transactions and non-member transactions?
with revenue_cte as (
select member,
	txn_id,
    sum(qty*price) as revenue
from sales
group by member,txn_id)
select member,
	avg(revenue) as avg_revenue 
from revenue_cte
group by member