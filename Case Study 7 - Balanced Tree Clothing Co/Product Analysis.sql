-- What are the top 3 products by total revenue before discount?
select product_name,
	sum(qty*s.price) as total_price 
from sales s inner join product_details p on p.product_id = s.prod_id 
group by product_name
order by total_price desc
limit 3

-- What is the total quantity, revenue and discount for each segment?
select segment_name,
	sum(qty) as total_quantity,
    sum(qty*s.price) as revenue,
    round(sum((discount* qty*s.price)/100),2) as discount
from sales s inner join product_details p on p.product_id = s.prod_id
group by segment_name

-- What is the top selling product for each segment?
select segment_name,
	product_name 
from (select segment_name,
		product_name,
        sum(qty) as quantity,
        dense_rank() over(partition by segment_name order by sum(qty) desc) as rno
from sales s inner join product_details p on p.product_id = s.prod_id
group by segment_name,product_name) as rank_no
where rno = 1


-- What is the total quantity, revenue and discount for each category?
select category_name,
	sum(qty) as total_quantity,
    sum(qty*s.price) as revenue,
    round(sum((discount* qty*s.price)/100),2) as discount
from sales s inner join product_details p on p.product_id = s.prod_id
group by category_name

-- What is the top selling product for each category?
select category_name,
	product_name 
from (select category_name,
			product_name,
            sum(qty) as quantity,
            dense_rank() over(partition by category_name order by sum(qty) desc) as rno
from sales s inner join product_details p on p.product_id = s.prod_id
group by category_name,product_name) as rank_no
where rno = 1

-- What is the percentage split of revenue by product for each segment?
with revenue_cte as (
select segment_name,
	product_name,
    sum(qty*s.price) as total_revenue
from sales s inner join product_details p on p.product_id = s.prod_id
group by segment_name,product_name)
select segment_name,
	product_name,
    round((100 * total_revenue/sum(total_revenue) over(partition by segment_name)),2) as seg_product_per
from revenue_cte

-- What is the percentage split of revenue by segment for each category?
with revenue_cte1 as (
select category_name,
	segment_name,
    sum(qty*s.price) as total_revenue
from sales s inner join product_details p on p.product_id = s.prod_id
group by category_name,segment_name)
select category_name,
	segment_name,
    round((100 * total_revenue/sum(total_revenue) over(partition by category_name)),2) as category_seg_per
from revenue_cte1

-- What is the percentage split of total revenue by category?
with revenue_cte2 as (
select category_name,
    sum(qty*s.price) as total_revenue
from sales s inner join product_details p on p.product_id = s.prod_id
group by category_name)
select category_name,
    round((100 * total_revenue/sum(total_revenue) over()),2) as category_per
from revenue_cte2

-- What is the total transaction “penetration” for each product? (hint: penetration = number of transactions where at least 1 quantity of a product was purchased divided by total number of transactions)
select prod_id,
	round((100*count(case when qty>=1 then txn_id else null end)/(select count(distinct(txn_id)) from sales)),2) 
from sales 
group by prod_id

-- What is the most common combination of at least 1 quantity of any 3 products in a 1 single transaction?