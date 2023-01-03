-- What are the top 3 products by total revenue before discount?
SELECT product_name,
	SUM(qty*s.price) AS total_price 
FROM sales s INNER JOIN product_details p ON p.product_id = s.prod_id 
GROUP BY product_name
ORDER BY total_price DESC
LIMIT 3

-- What is the total quantity, revenue and discount for each segment?
SELECT segment_name,
	SUM(qty) AS total_quantity,
    SUM(qty*s.price) AS revenue,
    ROUND(SUM((discount* qty*s.price)/100),2) AS discount
FROM sales s INNER JOIN product_details p ON p.product_id = s.prod_id
GROUP BY segment_name

-- What is the top selling product for each segment?
SELECT segment_name,
	product_name 
FROM (SELECT segment_name,
		product_name,
        SUM(qty) AS quantity,
        DENSE_RANK() OVER(PARTITION BY segment_name ORDER BY SUM(qty) DESC) AS rno
FROM sales s INNER JOIN product_details p ON p.product_id = s.prod_id
GROUP BY segment_name,product_name) AS rank_no
WHERE rno = 1


-- What is the total quantity, revenue and discount for each category?
SELECT category_name,
	SUM(qty) AS total_quantity,
    SUM(qty*s.price) AS revenue,
    ROUND(SUM((discount* qty*s.price)/100),2) AS discount
FROM sales s INNER JOIN product_details p ON p.product_id = s.prod_id
GROUP BY category_name

-- What is the top selling product for each category?
SELECT category_name,
	product_name 
FROM (SELECT category_name,
			product_name,
            SUM(qty) AS quantity,
            DENSE_RANK() OVER(PARTITION BY category_name ORDER BY SUM(qty) DESC) AS rno
FROM sales s INNER JOIN product_details p ON p.product_id = s.prod_id
GROUP BY category_name,product_name) AS rank_no
WHERE rno = 1

-- What is the percentage split of revenue by product for each segment?
WITH revenue_cte AS (
SELECT segment_name,
	product_name,
    SUM(qty*s.price) AS total_revenue
FROM sales s INNER JOIN product_details p ON p.product_id = s.prod_id
GROUP BY segment_name,product_name)
SELECT segment_name,
	product_name,
    ROUND((100 * total_revenue/SUM(total_revenue) OVER(PARTITION BY segment_name)),2) AS seg_product_per
FROM revenue_cte

-- What is the percentage split of revenue by segment for each category?
WITH revenue_cte1 AS (
SELECT category_name,
	segment_name,
    SUM(qty*s.price) AS total_revenue
FROM sales s INNER JOIN product_details p ON p.product_id = s.prod_id
GROUP BY category_name,segment_name)
SELECT category_name,
	segment_name,
    ROUND((100 * total_revenue/SUM(total_revenue) OVER(PARTITION BY category_name)),2) AS category_seg_per
FROM revenue_cte1

-- What is the percentage split of total revenue by category?
WITH revenue_cte2 AS (
SELECT category_name,
    SUM(qty*s.price) AS total_revenue
FROM sales s INNER JOIN product_details p ON p.product_id = s.prod_id
GROUP BY category_name)
SELECT category_name,
    ROUND((100 * total_revenue/SUM(total_revenue) OVER()),2) AS category_per
FROM revenue_cte2

-- What is the total transaction “penetration” for each product? (hint: penetration = number of transactions WHERE at least 1 quantity of a product was purchased divided by total number of transactions)
SELECT prod_id,
	ROUND((100*COUNT(CASE WHEN qty>=1 THEN txn_id ELSE NULL END)/(SELECT COUNT(DISTINCT(txn_id)) FROM sales)),2) 
FROM sales 
GROUP BY prod_id
