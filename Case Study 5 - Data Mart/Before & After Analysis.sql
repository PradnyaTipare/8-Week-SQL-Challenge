select distinct week_number from clean_weekly_sales where week_date = '2020-06-15' and calendar_year = 2020

-- What is the total sales for the 4 weeks before and after 2020-06-15? What is the growth or reduction rate in actual values and percentage of sales?
drop view week_cte;
create view week_cte as
select calendar_year,
	week_number,
    sum(sales) as total_sales
from clean_weekly_sales 
group by calendar_year,week_number

with total_sales_cte as (
select sum(case when week_number between 21 and 24 then total_sales end) as before_sales, 
	sum(case when week_number between 25 and 28 then total_sales end) as after_sales 
from week_cte
where calendar_year = 2020)
select before_sales,
	after_sales,
    after_sales - before_sales AS variance, 
	ROUND(100 * (after_sales - before_sales) / before_sales,2) AS percentage 
from total_sales_cte


-- What about the entire 12 weeks before and after?
with total_sales12_cte as (
select sum(case when week_number between 13 and 24 then total_sales end) as before_sales, 
	sum(case when week_number between 25 and 36 then total_sales end) as after_sales 
from week_cte where calendar_year = 2020)
select before_sales,
	after_sales,
    after_sales - before_sales AS variance, 
	ROUND(100 * (after_sales - before_sales) / before_sales,2) AS percentage 
from total_sales12_cte


-- How do the sale metrics for these 2 periods before and after compare with the previous years in 2018 and 2019?
with total_sales_cte as (
select calendar_year,sum(case when week_number between 21 and 24 then total_sales end) as before_sales, 
	sum(case when week_number between 25 and 28 then total_sales end) as after_sales 
from week_cte
where calendar_year in ('2018','2019')
group by calendar_year)
select calendar_year,
	before_sales,
	after_sales,
    after_sales - before_sales AS variance, 
	ROUND(100 * (after_sales - before_sales) / before_sales,2) AS percentage 
from total_sales_cte

with total_sales12_cte as (
select calendar_year,sum(case when week_number between 13 and 24 then total_sales end) as before_sales, 
	sum(case when week_number between 25 and 36 then total_sales end) as after_sales 
from week_cte 
where calendar_year in ('2018','2019')
group by calendar_year)
select calendar_year,
	before_sales,
	after_sales,
    after_sales - before_sales AS variance, 
	ROUND(100 * (after_sales - before_sales) / before_sales,2) AS percentage 
from total_sales12_cte