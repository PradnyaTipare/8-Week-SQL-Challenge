-- If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?

SELECT SUM(CASE WHEN pizza_id = '1' THEN 12 ELSE 10 END) AS money_made
FROM runner_orders r
		INNER JOIN customer_orders c ON c.order_id = r.order_id
WHERE cancellation IS NULL


-- What if there was an additional $1 charge for any pizza extras?

-- Add cheese is $1 extra

-- The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.
   
   DROP TABLE IF EXISTS runners_ratings;
	CREATE TABLE runner_ratings (
	  order_id INTEGER,
      runner_id INTEGER,
      rating INTEGER
	);
	INSERT INTO runner_ratings
	  (order_id,runner_id, rating)
	VALUES
	  (1, 1, 3),
	  (2, 1, 4),
	  (3, 1, 5),
      (4, 2, 4),
      (5, 3, 5),
      (7, 2, 4),
      (8, 2, 3),
	  (10, 1,5);
      
      
-- Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
-- customer_id
-- order_id
-- runner_id
-- rating
-- order_time
-- pickup_time
-- Time between order and pickup
-- Delivery duration
-- Average speed
-- Total number of pizzas

SELECT customer_id, 
	rr.order_id, 
    r.runner_id, 
    rating, 
    order_time, 
    pickup_time, 
    TIMESTAMPDIFF(minute,order_time,pickup_time) AS time_taken, 
    duration, 
    ROUND(AVG((distance/(duration/60))),2) AS avg_speed,
    COUNT(pizza_id) AS no_of_pizzas
FROM runner_orders r 
	INNER JOIN customer_orders c ON c.order_id = r.order_id
    INNER JOIN runner_ratings rr ON rr.order_id = r.order_id
GROUP BY customer_id, rr.order_id, r.runner_id, rating, order_time, pickup_time
  
  
-- If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?

WITH money_made AS 
(SELECT SUM(CASE WHEN pizza_id = '1' THEN 12 ELSE 10 END) AS earned
FROM runner_orders r
		INNER JOIN customer_orders c ON c.order_id = r.order_id
WHERE cancellation IS NULL),
money_spent AS (SELECT SUM(0.30*distance) AS spent 
			FROM runner_orders)
SELECT earned-spent AS money_left from money_made,money_spent

