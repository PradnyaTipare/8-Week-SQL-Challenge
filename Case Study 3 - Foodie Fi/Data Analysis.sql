CREATE VIEW main_table AS
SELECT customer_id,
	s.plan_id,
    plan_name,
    start_date,
    price
FROM subscriptions s 
	INNER JOIN plans p ON p.plan_id = s.plan_id

-- --------------------------
--    Customer Analysis    --
-- --------------------------  

SELECT * FROM main_table 
WHERE customer_id IN ('1','2','11','13','15','16','18','19')

-- FROM the sample dataset most of the customers first tried the trail version AND then decided to update to one of the paid plan. 
-- Most of them choose the MONTHly plan after trail version AND few then updated to annual plan. 
-- Also 2 customers among them churned their plan i.e they didn't the service. 


-- How many customers has Foodie-Fi ever had?

SELECT COUNT(DISTINCT customer_id) 
FROM main_table


-- What is the MONTHly distribution of trial plan start_date values for our dataset - use the start of the MONTH as the GROUP BY value

SELECT MONTH(start_date),
	COUNT(*) 
FROM main_table 
WHERE plan_name = 'trial' 
GROUP BY 1 
ORDER BY 1


-- What plan start_date values occur after the YEAR 2020 for our dataset? Show the breakdown by COUNT of events for each plan_name

SELECT plan_name,
	COUNT(*) as COUNT 
FROM main_table 
WHERE YEAR(start_date) > 2020 
GROUP BY plan_name


-- What is the customer COUNT AND percentage of customers who have churned ROUNDed to 1 decimal place?

SELECT COUNT(DISTINCT customer_id) AS churn_customer,
	ROUND((COUNT(DISTINCT customer_id)/(SELECT COUNT(DISTINCT customer_id) FROM main_table)*100),1) AS percentage 
FROM main_table
WHERE plan_name = 'churn'      


-- How many customers have churned straight after their initial free trial - what percentage is this ROUNDed to the nearest whole number?

SELECT COUNT(*) AS customer_COUNT,
	ROUND(COUNT(*)/(SELECT COUNT(DISTINCT customer_id) FROM main_table)*100) AS percentage
FROM subscriptions m1,
		subscriptions m2
WHERE m1.customer_id = m2.customer_id 
		AND m1.plan_id = '0' 
        AND m2.plan_id = '4' 
        AND DATEDIFF(m2.start_date,m1.start_date) = 7


-- What is the number AND percentage of customer plans after their initial free trial?

SELECT LEAD_plan AS plan,
	COUNT(*) AS customer_COUNT,
    ROUND(COUNT(*)/(SELECT COUNT(DISTINCT customer_id) FROM main_table)*100,1) AS percentage
FROM (
	SELECT customer_id,
		plan_id,
		LEAD(plan_id,1) OVER(ORDER BY customer_id) AS LEAD_plan 
    FROM main_table) temp
WHERE plan_id = '0'
GROUP BY 1


-- What is the customer COUNT AND percentage breakdown of all 5 plan_name values at 2020-12-31?

SELECT plan_name,
	COUNT(DISTINCT customer_id) AS customers,
    ROUND(COUNT(DISTINCT customer_id)/(SELECT COUNT(DISTINCT customer_id) FROM main_table)*100,1) AS percentage
FROM (SELECT customer_id,
				plan_name,
                start_date,
                LEAD(start_date,1) OVER(partition by customer_id ORDER BY start_date) AS next_date
	  FROM main_table) temp
WHERE (next_date IS NULL AND start_date <= '2020-12-31') 
	OR (next_date IS NOT NULL AND next_date >= '2020-12-31' AND start_date <= '2020-12-31')
GROUP BY plan_name


-- How many customers have upgraded to an annual plan in 2020?

SELECT COUNT(*) AS customers
FROM (
	SELECT customer_id,
		plan_id,
        LEAD(plan_id,1) OVER(ORDER BY customer_id) AS next_plan,
        LEAD(start_date,1) OVER(ORDER BY customer_id) AS next_date 
	FROM main_table) temp
WHERE plan_id IN ('0','1','2') 
	AND LEAD_plan = '3' 
    AND YEAR(date) = '2020'


-- How many days on average does it take for a customer to an annual plan FROM the day they join Foodie-Fi?

SELECT ROUND(AVG(DATEDIFF(last,first))) AS AVG_days FROM (
SELECT m1.customer_id,m1.start_date AS first,m2.start_date AS last
FROM subscriptions m1,
		subscriptions m2
WHERE m1.customer_id = m2.customer_id 
		AND m1.plan_id = '0'
        AND m2.plan_id = '3') temp


-- Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)

SELECT concat(floor(diff/30)*30, '-', floor(diff/30)*30+30) AS bucket,
	COUNT(*) AS customers
FROM (
	SELECT m1.customer_id,m1.start_date AS first,m2.start_date AS last,DATEDIFF(m2.start_date,m1.start_date) AS diff
	FROM subscriptions m1,
			subscriptions m2
	WHERE m1.customer_id = m2.customer_id 
			AND m1.plan_id = '0'
			AND m2.plan_id = '3') temp
GROUP BY 1
ORDER BY 1


-- How many customers downgraded FROM a pro MONTHly to a basic MONTHly plan in 2020?

SELECT COUNT(*)
FROM subscriptions m1,
		subscriptions m2
WHERE m1.customer_id = m2.customer_id 
		AND m1.plan_id = '2' 
        AND m2.plan_id = '1' 
        AND m1.start_date < m2.start_date
	
