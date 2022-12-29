-- Convert the week_date to a DATE format
-- Add a week_number as the second column for each week_date value, for example any value from the 1st of January to 7th of January will be 1, 8th to 14th will be 2 etc
-- Add a month_number with the calendar month for each week_date value as the 3rd column
-- Add a calendar_year column as the 4th column containing either 2018, 2019 or 2020 values
-- Add a new column called age_band after the original segment column using the following mapping on the number inside the segment value
-- Add a new demographic column using the following mapping for the first letter in the segment values:
-- Ensure all null string values with an "unknown" string value in the original segment column as well as the new age_band and demographic columns
-- Generate a new avg_transaction column as the sales value divided by transactions rounded to 2 decimal places for each record

drop table clean_weekly_sales;
create table clean_weekly_sales as (
select str_to_date(week_date, '%d/%m/%Y') AS week_date,
weekofyear(str_to_date(week_date, '%d/%m/%Y')) as week_number,
month(str_to_date(week_date, '%d/%m/%Y')) as month_number,
year(str_to_date(week_date, '%d/%m/%Y')) as calendar_year,
region,platform,segment,
case when right(segment,1) = '1' then 'Young Adults'
when right(segment,1) = '2' then 'Middle Aged'
when right(segment,1) in ('3','4') then 'Retirees'
else 'unknown' end as age_band,
case when left(segment,1) = 'C' then 'Couples'
when left(segment,1) = 'F' then 'Families'
else 'unknown' end as demographic,
transactions,
sales,
round((sales/transactions),2) as avg_transaction 
from weekly_sales)