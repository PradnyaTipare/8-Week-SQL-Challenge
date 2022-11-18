CREATE VIEW split AS 
SELECT pizza_id,substring_index(toppings,',',1) AS topping1,
		substring_index(substring_index(toppings,',',2),',',-1) AS topping2,
        substring_index(substring_index(toppings,',',3),',',-1) AS topping3,
        substring_index(substring_index(toppings,',',4),',',-1) AS topping4,
        substring_index(substring_index(toppings,',',5),',',-1) AS topping5,
        substring_index(substring_index(toppings,',',6),',',-1) AS topping6,
        substring_index(substring_index(toppings,',',7),',',-1) AS topping7,
        substring_index(toppings,',',-1) AS topping8
FROM pizza_recipes;
    
 CREATE VIEW toppings_table AS
	SELECT pizza_id,topping1 FROM split
	UNION SELECT pizza_id,topping2 FROM split
	UNION SELECT pizza_id,topping3 FROM split
	UNION SELECT pizza_id,topping4 FROM split
	UNION SELECT pizza_id,topping5 FROM split
	UNION SELECT pizza_id,topping6 FROM split
	UNION SELECT pizza_id,topping7 FROM split
	UNION SELECT pizza_id,topping8 FROM split;

CREATE VIEW toppings AS
SELECT pizza_id,topping1,topping_name 
FROM toppings_table t 
	INNER JOIN pizza_toppings p ON p.topping_id = t.topping1   
    
-- What are the standard ingredients for each pizza?
  
  SELECT pizza_id,
	pizza_name,
    group_concat(topping_name SEPARATOR ', ') 
  FROM toppings t 
	INNER JOIN pizza_names n ON n.pizza_id = t.pizza_id 
  GROUP BY pizza_id
  
  
-- What was the most commonly added extra?

CREATE VIEW extras_split AS
SELECT order_id,
	substring_index(extras,',',1) AS extras1,
    substring_index(extras,',',-1) AS extras2 
FROM customer_orders 
WHERE extras IS NOT NULL

CREATE VIEW extras_merge AS
SELECT order_id,extras1 FROM extras_split
UNION SELECT order_id,extras2 FROM extras_split

CREATE VIEW extras AS
SELECT order_id,extras1,
		topping_name
FROM pizza_toppings t 
		INNER JOIN extras_merge c ON c.extras1 = t.topping_id
        
SELECT topping_name 
FROM (SELECT topping_name,count(*) AS count FROM extras GROUP BY topping_name ORDER BY count DESC) AS t
limit 1


-- What was the most common exclusiON?

CREATE VIEW exclusions_split AS
SELECT order_id,
	substring_index(exclusions,',',1) AS exclusions1,
    substring_index(exclusions,',',-1) AS exclusions2 
FROM customer_orders 
-- WHERE exclusions IS NOT NULL;

CREATE VIEW exclusions_merge AS
SELECT order_id,exclusions1 FROM exclusions_split
UNION ALL SELECT order_id,exclusions2 FROM exclusions_split;

CREATE VIEW exclusions AS
SELECT order_id,exclusions1,
		topping_name
FROM pizza_toppings t 
		INNER JOIN exclusions_merge c ON c.exclusions1 = t.topping_id
        
SELECT topping_name 
FROM (SELECT topping_name,count(*) AS count FROM exclusions GROUP BY topping_name ORDER BY count DESC) AS t
limit 1


-- Generate an order item for each record in the customers_orders table in the format of one of the following:
-- Meat Lovers
-- Meat Lovers - Exclude Beef
-- Meat Lovers - Extra Bacon
-- Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers

SELECT order_id,
	customer_id,
    CASE WHEN excluded_topping IS NULL AND extra_toppings IS NULL THEN pizza_name 
		WHEN excluded_topping IS NULL AND extra_toppings IS NOT NULL THEN CONCAT(pizza_name,' - Extra ',extra_toppings)
        WHEN excluded_topping IS NOT NULL AND extra_toppings IS NULL THEN CONCAT(pizza_name,' - Exclude ',excluded_topping)
        ELSE CONCAT(pizza_name,' - Exclude ',excluded_topping,' - Extra ',extra_toppings)
    END as order_item
FROM 
(SELECT c.order_id,customer_id,c.pizza_id,pizza_name,group_concat(distinct e.topping_name) as excluded_topping,group_concat(distinct ex.topping_name) as extra_toppings
from customer_orders c
		INNER JOIN pizza_names p ON p.pizza_id = c.pizza_id
		left join exclusions e ON e.order_id = c.order_id
        left JOIN extras ex ON ex.order_id = c.order_id
group by c.order_id,customer_id,c.pizza_id,pizza_name
order by order_id) as t


-- Generate an alphabetically ordered comma separated ingredient list for each pizza order FROM the customer_orders table and add a 2x in front of any relevant ingredients
-- For example: "Meat Lovers: 2xBacON, Beef, ... , Salami"
  SELECT pizza_id,group_concat(concat('2x',topping_name) ORDER BY topping_name SEPARATOR ', ') FROM toppings GROUP BY pizza_id


-- What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?
SELECT topping_name,count(*) AS count
FROM (SELECT r.order_id,c.pizza_id,topping1,topping_name 
        FROM runner_orders r
		INNER JOIN customer_orders c ON c.order_id = r.order_id
        INNER JOIN toppings t ON t.pizza_id = c.pizza_id
	WHERE cancellatiON IS NULL
    ORDER BY order_id,pizza_id,topping1) AS t
GROUP BY topping_name
ORDER BY count DESC