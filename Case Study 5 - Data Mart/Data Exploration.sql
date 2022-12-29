-- What day of the week is used for each week_date value?
SELECT distinct(DAYOFWEEK(week_date)) 
FROM clean_weekly_sales

-- What range of week numbers are missing FROM the dataset?


-- How many total transactions were there for each year in the dataset?
SELECT calendar_year,
	SUM(transactions) AS total_transactions 
FROM clean_weekly_sales 
GROUP BY calendar_year

-- What is the total sales for each region for each month?
SELECT region,
	month_number,
	SUM(sales) AS total_sales 
FROM clean_weekly_sales 
GROUP BY region,month_number

-- What is the total count of transactions for each platform
SELECT platform,
	SUM(transactions) 
FROM clean_weekly_sales 
GROUP BY platform

-- What is the percentage of sales for Retail vs Shopify for each month?
WITH month_cte as(
SELECT calendar_year,
	month_number,
    platform,
    SUM(sales) AS monthly_sales 
FROM clean_weekly_sales 
GROUP BY calendar_year,month_number,platform)
SELECT calendar_year,
	month_number,
    ROUND(100 * MAX(CASE WHEN platform = 'Retail' THEN monthly_sales ELSE NULL END)/SUM(monthly_sales),2) AS retail_percentage,
    ROUND(100 * MAX(CASE WHEN platform = 'Shopify' THEN monthly_sales ELSE NULL END)/SUM(monthly_sales),2) AS shopify_percentage
FROM month_cte
GROUP BY calendar_year,month_number

-- What is the percentage of sales by demographic for each year in the dataset?
WITH demographic_cte AS(
SELECT calendar_year,
	demographic,
    SUM(sales) AS monthly_sales 
FROM clean_weekly_sales 
GROUP BY calendar_year,demographic)
SELECT calendar_year,
    ROUND(100 * MAX(CASE WHEN demographic = 'Couples' THEN monthly_sales ELSE NULL END)/SUM(monthly_sales),2) AS couples_percentage,
    ROUND(100 * MAX(CASE WHEN demographic = 'Families' THEN monthly_sales ELSE NULL END)/SUM(monthly_sales),2) AS family_percentage,
	ROUND(100 * MAX(CASE WHEN demographic = 'unknown' THEN monthly_sales ELSE NULL END)/SUM(monthly_sales),2) AS unknown_percentage
FROM demographic_cte
GROUP BY calendar_year


-- Which age_band and demographic values contribute the most to Retail sales?
SELECT age_band,
	demographic,
    SUM(sales) AS retail_sales 
FROM clean_weekly_sales 
WHERE platform = 'Retail' 
GROUP BY age_band,demographic 
ORDER BY retail_sales DESC 
LIMIT 1

-- Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?
SELECT 
  calendar_year, 
  platform, 
  ROUND(AVG(avg_transaction),0) AS avg_transaction_row, 
  SUM(sales) / SUM(transactions) AS avg_transaction_group
FROM clean_weekly_sales
GROUP BY calendar_year, platform
ORDER BY calendar_year, platform;