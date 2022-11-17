-- How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
SELECT week(registration_date),count(runner_id) as runners
FROM runners
GROUP BY 1

-- What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
SELECT runner_id,AVG(difference) AS avg_time_in_mins 
FROM (
	SELECT runner_id,c.order_id, TIMESTAMPDIFF(minute,order_time,pickup_time) AS difference
	FROM runner_orders r
		INNER JOIN customer_orders c ON c.order_id = r.order_id
	WHERE cancellation IS NULL
	GROUP BY runner_id,c.order_id) AS t
GROUP BY runner_id

-- Is there any relationship between the number of pizzas and how long the order takes to prepare?
SELECT no_of_pizza,AVG(time_taken) AS avg_time_taken 
FROM(
	SELECT c.order_id,COUNT(pizza_id) AS no_of_pizza,TIMESTAMPDIFF(minute,order_time,pickup_time) AS time_taken
	FROM runner_orders r
		INNER JOIN customer_orders c ON c.order_id = r.order_id
	WHERE cancellation IS NULL
	GROUP BY c.order_id) AS t
GROUP BY no_of_pizza

-- What was the average distance travelled for each customer?
SELECT customer_id,AVG(distance) 
FROM runner_orders r
	INNER JOIN customer_orders c ON c.order_id = r.order_id
WHERE cancellation IS NULL
GROUP BY  customer_id

-- What was the difference between the longest and shortest delivery times for all orders?
SELECT MAX(duration)-MIN(duration)
FROM runner_orders
WHERE cancellation IS NULL

-- What was the average speed for each runner for each delivery and do you notice any trend for these values?
SELECT order_id,
	runner_id,
	ROUND(AVG(distance/(duration/60)),2) as avg_speed
FROM runner_orders 
WHERE cancellation IS NULL
GROUP BY order_id,runner_id

-- What is the successful delivery percentage for each runner?
SELECT runner_id,
	ROUND(SUM(CASE WHEN cancellation IS NULL THEN 1 ELSE 0 END)/COUNT(order_id)*100,0) AS success_percentage
FROM runner_orders
GROUP BY runner_id