-- How many pizzas were ordered?
SELECT COUNT(order_id) AS pizzas_ordered 
FROM customer_orders

-- How many unique customer orders were made?
SELECT COUNT(DISTINCT(order_id))
FROM customer_orders

-- How many successful orders were delivered by each runner?
SELECT runner_id,
	COUNT(DISTINCT(order_id))
FROM runner_orders
WHERE cancellation is null
GROUP BY runner_id 

-- How many of each type of pizza was delivered?
SELECT pizza_name,
	COUNT(c.pizza_id)
FROM customer_orders c 
	INNER JOIN pizza_names p ON c.pizza_id = p.pizza_id
    INNER JOIN runner_orders r ON r.order_id = c.order_id
WHERE cancellation is null	
GROUP BY pizza_name

-- How many Vegetarian and Meatlovers were ordered by each customer?
SELECT customer_id,pizza_name,
	COUNT(c.pizza_id)
FROM customer_orders c 
	INNER JOIN pizza_names p ON c.pizza_id = p.pizza_id
GROUP BY customer_id,pizza_name
ORDER BY customer_id

-- What was the maximum number of pizzas delivered in a single order?
SELECT COUNT(pizza_id) as max_no_of_pizzas
FROM customer_orders c 
    INNER JOIN runner_orders r ON r.order_id = c.order_id
WHERE cancellation is null	
GROUP BY c.order_id
ORDER BY max_no_of_pizzas desc
LIMIT 1

-- For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
SELECT customer_id,
	sum(case when exclusions is null and extras is null then 1 else 0 end) as no_change_pizza,
    sum(case when exclusions is not null or extras is not null then 1 else 0 end) as change_in_pizzas
FROM customer_orders c 
    INNER JOIN runner_orders r ON r.order_id = c.order_id
WHERE cancellation is null	
GROUP BY customer_id

-- How many pizzas were delivered that had both exclusions and extras?
SELECT count(*) as count
FROM customer_orders c 
    INNER JOIN runner_orders r ON r.order_id = c.order_id
WHERE cancellation is null	and exclusions is not null and extras is not null

-- What was the total volume of pizzas ordered for each hour of the day?
SELECT HOUR(order_time) AS hour, COUNT(pizza_id) AS count
FROM customer_orders
GROUP BY 1
ORDER BY 1

-- What was the volume of orders for each day of the week?
SELECT DAYNAME(order_time) AS day_of_week,
	COUNT(DISTINCT(order_id)) AS count
FROM customer_orders
GROUP BY 1
ORDER BY 1