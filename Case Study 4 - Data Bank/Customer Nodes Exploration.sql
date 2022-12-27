create view main_table as
select customer_id,c.region_id,region_name,node_id,start_date,end_date 
from customer_nodes c inner join regions r on r.region_id = c.region_id

-- How many unique nodes are there on the Data Bank system?

SELECT COUNT(DISTINCT node_id) as unique_nodes from main_table

-- What is the number of nodes per region?

select region_id,region_name,count(distinct node_id) as no_of_nodes_per_region
from main_table
group by region_id

-- How many customers are allocated to each region?

select region_name,count(distinct customer_id) 
from main_table
group by region_name

-- How many days on average are customers reallocated to a different node?

select round(avg(datediff(end_date,start_date)),2) as average
from main_table
where end_date != '9999-12-31'

