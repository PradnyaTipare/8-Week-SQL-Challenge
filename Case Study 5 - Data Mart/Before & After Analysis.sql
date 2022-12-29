SELECT DISTINCT week_number FROM clean_weekly_sales WHERE week_date = '2020-06-15' AND calENDar_year = 2020

-- What is the total sales for the 4 weeks before AND after 2020-06-15? What is the growth or reduction rate in actual values AND percentage of sales?
DROP VIEW week_cte;
create VIEW week_cte AS
SELECT calENDar_year,
	week_number,
    SUM(sales) AS total_sales
FROM clean_weekly_sales 
GROUP BY calENDar_year,week_number

WITH total_sales_cte AS (
SELECT SUM(CASE WHEN week_number BETWEEN 21 AND 24 THEN total_sales END) AS before_sales, 
	SUM(CASE WHEN week_number BETWEEN 25 AND 28 THEN total_sales END) AS after_sales 
FROM week_cte
WHERE calENDar_year = 2020)
SELECT before_sales,
	after_sales,
    after_sales - before_sales AS variance, 
	ROUND(100 * (after_sales - before_sales) / before_sales,2) AS percentage 
FROM total_sales_cte


-- What about the entire 12 weeks before AND after?
WITH total_sales12_cte AS (
SELECT SUM(CASE WHEN week_number BETWEEN 13 AND 24 THEN total_sales END) AS before_sales, 
	SUM(CASE WHEN week_number BETWEEN 25 AND 36 THEN total_sales END) AS after_sales 
FROM week_cte WHERE calENDar_year = 2020)
SELECT before_sales,
	after_sales,
    after_sales - before_sales AS variance, 
	ROUND(100 * (after_sales - before_sales) / before_sales,2) AS percentage 
FROM total_sales12_cte


-- How do the sale metrics for these 2 periods before AND after compare WITH the previous years in 2018 AND 2019?
WITH total_sales_cte AS (
SELECT calENDar_year,SUM(CASE WHEN week_number BETWEEN 21 AND 24 THEN total_sales END) AS before_sales, 
	SUM(CASE WHEN week_number BETWEEN 25 AND 28 THEN total_sales END) AS after_sales 
FROM week_cte
WHERE calENDar_year IN ('2018','2019')
GROUP BY calENDar_year)
SELECT calENDar_year,
	before_sales,
	after_sales,
    after_sales - before_sales AS variance, 
	ROUND(100 * (after_sales - before_sales) / before_sales,2) AS percentage 
FROM total_sales_cte

WITH total_sales12_cte as (
SELECT calENDar_year,SUM(CASE WHEN week_number BETWEEN 13 AND 24 THEN total_sales END) AS before_sales, 
	SUM(CASE WHEN week_number BETWEEN 25 AND 36 THEN total_sales END) AS after_sales 
FROM week_cte 
WHERE calENDar_year IN ('2018','2019')
GROUP BY calENDar_year)
SELECT calENDar_year,
	before_sales,
	after_sales,
    after_sales - before_sales AS variance, 
	ROUND(100 * (after_sales - before_sales) / before_sales,2) AS percentage 
FROM total_sales12_cte