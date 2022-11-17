----------------------------------
-- CASE STUDY #1: DANNY'S DINER --
----------------------------------

CREATE SCHEMA dannys_diner;

CREATE TABLE sales (
   customer_id VARCHAR(1),
   order_date DATE,
   product_id INTEGER
);

INSERT INTO sales
  (customer_id, order_date, product_id)
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  product_id INTEGER,
  product_name VARCHAR(5),
  price INTEGER
);

INSERT INTO menu
  (product_id, product_name, price)
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  customer_id VARCHAR(1),
  join_date DATE
);

INSERT INTO members
  (customer_id, join_date)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');

--------------------------
-- CASE STUDY QUESTIONS --
--------------------------  

-- creating basic data table used to quickly derive insights without needing to join the underlying tables using SQL.  
WITH main_table AS
(SELECT sales.customer_id,
	order_date,
	product_name,
    price,
    CASE WHEN order_date>= join_date THEN 'Y' ELSE 'N' END AS member
FROM sales 
	INNER JOIN menu ON sales.product_id = menu.product_id
    LEFT JOIN members on sales.customer_id = members.customer_id)


-- 1. What is the total amount each customer spent at the restaurant?
SELECT customer_id,
		SUM(price) AS amount_spent
FROM main_table 
GROUP BY customer_id 


-- 2. How many days has each customer visited the restaurant?

SELECT customer_id,
 	COUNT(DISTINCT(order_date)) AS days_visited 
FROM main_table
GROUP BY customer_id


-- 3. What was the first item from the menu purchased by each customer?

SELECT customer_id,product_name 
FROM (SELECT customer_id,
			order_date,
            product_name,
            dense_rank() over(partition by customer_id order by order_date) as rank_no 
	  FROM main_table) as t
where rank_no = 1
GROUP BY customer_id,product_name


-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT product_name,
	count(*) AS count
FROM main_table
GROUP BY product_name
ORDER BY count desc
LIMIT 1


-- 5. Which item was the most popular for each customer?

SELECT customer_id,
	product_name 
FROM (SELECT customer_id,
			product_name,
            count(product_name),
            dense_rank() over(partition by customer_id order by count(product_name) DESC) AS rank_no 
            FROM main_table group by customer_id,product_name) AS t
WHERE rank_no = 1


-- 6. Which item was purchased first by the customer after they became a member?

SELECT customer_id,product_name 
FROM (SELECT customer_id,
			order_date,
            product_name,
            dense_rank() over(partition by customer_id order by order_date) as rank_no 
	  FROM main_table WHERE member = 'Y') as t
WHERE rank_no = 1


-- 7. Which item was purchased just before the customer became a member?

SELECT customer_id,product_name 
FROM (SELECT customer_id,
			order_date,
            product_name,
            dense_rank() over(partition by customer_id order by order_date desc) as rank_no 
	  FROM main_table where member ='N') as t
WHERE rank_no = 1 and customer_id in (select distinct(customer_id) from members)


-- 8. What is the total items and amount spent for each member before they became a member?

SELECT customer_id,
	COUNT(DISTINCT(product_name)) AS total_items,
	SUM(price) AS amount_spent 
FROM main_table 
WHERE member = 'N' AND customer_id IN (SELECT DISTINCT(customer_id) FROM members)
GROUP BY customer_id


-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

SELECT customer_id,
	SUM(CASE 
			WHEN product_name = 'sushi' THEN price*20 
            ELSE price*10 
		END) AS points 
FROM main_table 
GROUP BY customer_id


-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

dates_cte AS 
(
   SELECT *,
      adddate(join_date, INTERVAL 6 DAY) AS valid_date, 
      LAST_DAY('2021-01-31') AS last_date
   FROM members AS m
)
SELECT d.customer_id,
	SUM(CASE 
			WHEN order_date between join_date and valid_date THEN price*20 
            ELSE price*10 
		END) AS points 
FROM main_table m 
inner join dates_cte d on d.customer_id = m.customer_id
WHERE order_date < last_date
GROUP BY d.customer_id