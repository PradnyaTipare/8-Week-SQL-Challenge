-- What day of the week is used for each week_date value?
select distinct(dayofweek(week_date)) 
from clean_weekly_sales

-- What range of week numbers are missing from the dataset?


-- How many total transactions were there for each year in the dataset?
select calendar_year,
	sum(transactions) as total_transactions 
from clean_weekly_sales 
group by calendar_year

-- What is the total sales for each region for each month?
select region,
	month_number,
	sum(sales) as total_sales 
from clean_weekly_sales 
group by region,month_number

-- What is the total count of transactions for each platform
select platform,
	sum(transactions) 
from clean_weekly_sales 
group by platform

-- What is the percentage of sales for Retail vs Shopify for each month?
with month_cte as(
select calendar_year,
	month_number,
    platform,
    sum(sales) as monthly_sales 
from clean_weekly_sales 
group by calendar_year,month_number,platform)
select calendar_year,
	month_number,
    round(100 * max(case when platform = 'Retail' then monthly_sales else null end)/sum(monthly_sales),2) as retail_percentage,
    round(100 * max(case when platform = 'Shopify' then monthly_sales else null end)/sum(monthly_sales),2) as shopify_percentage
from month_cte
group by calendar_year,month_number

-- What is the percentage of sales by demographic for each year in the dataset?
with demographic_cte as(
select calendar_year,
	demographic,
    sum(sales) as monthly_sales 
from clean_weekly_sales 
group by calendar_year,demographic)
select calendar_year,
    round(100 * max(case when demographic = 'Couples' then monthly_sales else null end)/sum(monthly_sales),2) as couples_percentage,
    round(100 * max(case when demographic = 'Families' then monthly_sales else null end)/sum(monthly_sales),2) as family_percentage,
	round(100 * max(case when demographic = 'unknown' then monthly_sales else null end)/sum(monthly_sales),2) as unknown_percentage
from demographic_cte
group by calendar_year


-- Which age_band and demographic values contribute the most to Retail sales?
select age_band,
	demographic,
    sum(sales) as retail_sales 
from clean_weekly_sales 
where platform = 'Retail' 
group by age_band,demographic 
order by retail_sales desc 
limit 1

-- Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?
SELECT 
  calendar_year, 
  platform, 
  ROUND(AVG(avg_transaction),0) AS avg_transaction_row, 
  SUM(sales) / sum(transactions) AS avg_transaction_group
FROM clean_weekly_sales
GROUP BY calendar_year, platform
ORDER BY calendar_year, platform;