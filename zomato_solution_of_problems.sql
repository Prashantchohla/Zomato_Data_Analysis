SELECT * FROM riders;
SELECT * FROM restaurants;
SELECT * FROM customers;
SELECT * FROM orders;
SELECT * FROM deliveries;

-- -------------------------
-- Analysis & Reports
-- -------------------------

-- Q.1
-- Write a query to find the top 5 most frequently ordered dishes by customer called "Arjun Mehta" in the last 1 year.
SELECT 
	customer_name,
	dishes,
	total_orders
	from
(SELECT c.customer_id,
		c.customer_name,
		o.order_item as dishes,
		count(*) as total_orders,
DENSE_RANK() OVER(ORDER BY COUNT(*) DESC) as rank
from orders as o
join customers as c
ON c.customer_id = o.customer_id
where 
c.customer_name = 'Arjun Mehta'
and 
o.order_date >= CURRENT_DATE - INTERVAL '1 YEAR'
group by 1,2,3
order by 1,4 desc) as p
where rank <=5;

-- 2. Popular Time Slots
-- Question: Identify the time slots during which the most orders are placed. based on 2-hour intervals.

SELECT
    CASE
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 0 AND 1 THEN '00:00 - 02:00'
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 2 AND 3 THEN '02:00 - 04:00'
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 4 AND 5 THEN '04:00 - 06:00'
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 6 AND 7 THEN '06:00 - 08:00'
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 8 AND 9 THEN '08:00 - 10:00'
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 10 AND 11 THEN '10:00 - 12:00'
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 12 AND 13 THEN '12:00 - 14:00'
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 14 AND 15 THEN '14:00 - 16:00'
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 16 AND 17 THEN '16:00 - 18:00'
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 18 AND 19 THEN '18:00 - 20:00'
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 20 AND 21 THEN '20:00 - 22:00'
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 22 AND 23 THEN '22:00 - 00:00'
    END AS time_slot,
    COUNT(order_id) AS order_count
FROM Orders
GROUP BY time_slot
ORDER BY order_count DESC;

-- 3. Order Value Analysis
-- Question: Find the average order value per customer who has placed more than 750 orders.
-- Return customer_name, and aov(average order value)
select c.customer_name,
avg(o.total_amount) as aov
from orders as o
join customers as c
ON c.customer_id = o.customer_id
group by 1
having count(order_id) > 750
order by 2;

-- 4. High-Value Customers
-- Question: List the customers who have spent more than 100K in total on food orders.
-- return customer_name, and customer_id!
select c.customer_name,
c.customer_id,
sum(o.total_amount) as total_amount
from orders as o
join customers as c
ON c.customer_id = o.customer_id
group by 1,2
having sum(o.total_amount) > 100000
order by 3 desc;

-- 5. Orders Without Delivery
-- Question: Write a query to find orders that were placed but not delivered. 
-- Return each restuarant name, city and number of not delivered orders 
SELECT r.restaurant_name,
	r.city,
	COUNT(o.order_id) as cnt_not_delivered_orders
FROM orders as o
 join restaurants as r
ON r.restaurant_id = o.restaurant_id
 JOIN
deliveries as d
ON d.order_id = o.order_id
where d.delivery_status = 'Not Delivered'
group by 1,2
order by cnt_not_delivered_orders;


-- Q. 6
-- Restaurant Revenue Ranking: 
-- Rank restaurants by their total revenue from the last year, including their name, 
-- total revenue, and rank within their city.
WITH ranking as
(
SELECT r.restaurant_name,
r.city,
SUM(o.total_amount) as revenue,
RANK() OVER(PARTITION BY r.city ORDER BY SUM(o.total_amount) DESC) as rank
FROM orders as o
JOIN 
restaurants as r
ON r.restaurant_id = o.restaurant_id
WHERE o.order_date >= CURRENT_DATE - INTERVAL '1 year'
GROUP BY 1,2
)
select * from ranking
where rank = 1;


-- Q. 7
-- Most Popular Dish by City: 
-- Identify the most popular dish in each city based on the number of orders.

SELECT * 
FROM
(SELECT 
	r.city,
	o.order_item as dish,
	COUNT(order_id) as total_orders,
	RANK() OVER(PARTITION BY r.city ORDER BY COUNT(order_id) DESC) as rank
FROM orders as o
JOIN 
restaurants as r
ON r.restaurant_id = o.restaurant_id
GROUP BY 1, 2
) as t1
WHERE rank = 1;



-- Q.8 Customer Churn: 
-- Find customers who haven’t placed an order in 2024 but did in 2023.

-- find cx who has done orders in 2023
-- find cx who has not done orders in 2024
-- compare 1 and 2
SELECT DISTINCT customer_id
FROM orders
WHERE EXTRACT(year FROM order_date) = 2023
AND
customer_id NOT IN
(
SELECT DISTINCT customer_id 
FROM orders
WHERE EXTRACT(year FROM order_date) = 2024
);

-- Q.9 Cancellation Rate Comparison: 
-- Calculate and compare the order cancellation rate for each restaurant between the 
-- current year and the previous year.
WITH order_counts AS
(
SELECT r.restaurant_id,
	   r.restaurant_name,
	   EXTRACT(Year FROM o.order_date) AS Year,
	   COUNT(CASE WHEN o.order_status = 'Completed' THEN 1 END) AS Complete_order,
	   COUNT(CASE WHEN o.order_status = 'Not Fulfilled' THEN 1 END) AS Not_Fulfilled_order	   
FROM orders as o
LEFT JOIN restaurants as r
ON r.restaurant_id = o.restaurant_id
LEFT JOIN deliveries as d
ON d.order_id = o.order_id
group by 1,2,3
order by 1,3
)
SELECT *, ROUND((not_fulfilled_order::numeric / NULLIF(complete_order, 0)) * 100, 2) AS Cancel_Ratio
FROM order_counts;


-- Pivot Table code
WITH order_counts AS 
(
    SELECT 
        r.restaurant_id,
        r.restaurant_name,
        EXTRACT(YEAR FROM o.order_date) AS Year,
        COUNT(CASE WHEN o.order_status = 'Completed' THEN 1 END) AS Complete_order,
        COUNT(CASE WHEN o.order_status = 'Not Fulfilled' THEN 1 END) AS Not_Fulfilled_order
    FROM orders AS o
    LEFT JOIN restaurants AS r
    ON r.restaurant_id = o.restaurant_id
    LEFT JOIN deliveries AS d
    ON d.order_id = o.order_id
    GROUP BY r.restaurant_id, r.restaurant_name, EXTRACT(YEAR FROM o.order_date)
)
SELECT 
    restaurant_id,
    restaurant_name,
    ROUND(SUM(CASE WHEN Year = 2023 THEN not_fulfilled_order::numeric / NULLIF(complete_order, 0) * 100 ELSE 0 END), 2) AS cancel_ratio_2023,
    ROUND(SUM(CASE WHEN Year = 2024 THEN not_fulfilled_order::numeric / NULLIF(complete_order, 0) * 100 ELSE 0 END), 2) AS cancel_ratio_2024
FROM order_counts
GROUP BY restaurant_id, restaurant_name
ORDER BY restaurant_id;

-- or
WITH order_counts AS (
    SELECT 
        r.restaurant_id,
        r.restaurant_name,
        EXTRACT(YEAR FROM o.order_date) AS Year,
        COUNT(CASE WHEN o.order_status = 'Completed' THEN 1 END) AS Complete_order,
        COUNT(CASE WHEN o.order_status = 'Not Fulfilled' THEN 1 END) AS Not_Fulfilled_order
    FROM orders AS o
    LEFT JOIN restaurants AS r
    ON r.restaurant_id = o.restaurant_id
    LEFT JOIN deliveries AS d
    ON d.order_id = o.order_id
    GROUP BY r.restaurant_id, r.restaurant_name, EXTRACT(YEAR FROM o.order_date)
)
SELECT 
    restaurant_id,
    restaurant_name,
    ROUND(CASE WHEN Year = 2023 THEN not_fulfilled_order::numeric / NULLIF(complete_order, 0) * 100 ELSE 0 END, 2) AS cancel_ratio_2023,
    ROUND(CASE WHEN Year = 2024 THEN not_fulfilled_order::numeric / NULLIF(complete_order, 0) * 100 ELSE 0 END, 2) AS cancel_ratio_2024
FROM order_counts
GROUP BY restaurant_id, restaurant_name,3,4
ORDER BY restaurant_id;



-- Q.10 Rider Average Delivery Time: 
SELECT 
r.rider_name,
r.rider_id,
AVG(EXTRACT(EPOCH from
					(d.delivery_time - o.order_time + 
					CASE
						WHEN d.delivery_time < o.order_time THEN INTERVAL '1 day'
						ELSE INTERVAL '0 day'
						END))/60) as AVG_delivery_time
FROM orders AS o
JOIN deliveries AS d
ON o.order_id = d.order_id
JOIN riders as r
ON d.rider_id = r.rider_id
WHERE d.delivery_status = 'Delivered'
GROUP BY 1,2;

-- Determine each order delivery time:
SELECT o.order_id,
o.order_time,
d.delivery_time,
r.rider_name,
r.rider_id,
d.delivery_time - o.order_time AS time_difference,
EXTRACT(EPOCH from
					(d.delivery_time - o.order_time + 
					CASE
						WHEN d.delivery_time < o.order_time THEN INTERVAL '1 day'
						ELSE INTERVAL '0 day'
						END))/60 as time_diff_in_min
FROM orders AS o
JOIN deliveries AS d
ON o.order_id = d.order_id
JOIN riders as r
ON d.rider_id = r.rider_id
WHERE d.delivery_status = 'Delivered';


-- Q.11 Monthly Restaurant Growth Ratio: 
-- Calculate each restaurant's growth ratio based on the total number of delivered orders since its joining

WITH res_detail AS
(
SELECT r.restaurant_id,
	   r.restaurant_name,
	EXTRACT(YEAR FROM o.order_date) as Year,
	EXTRACT(MONTH FROM o.order_date) AS Month,
	COUNT(o.order_id) as Current_month_order_count,
	LAG(count(o.order_id),1) over(PARTITION BY r.restaurant_id, r.restaurant_name ORDER BY EXTRACT(YEAR FROM o.order_date),
	EXTRACT(MONTH FROM o.order_date)) as prev_month_orders
FROM orders as o
JOIN restaurants as r
ON r.restaurant_id = o.restaurant_id
JOIN
deliveries as d
ON d.order_id = o.order_id
WHERE d.delivery_status = 'Delivered'
GROUP BY 1,2,3,4
ORDER BY 1,3,4
) 
SELECT
	restaurant_id,
	restaurant_name,
	Year,
	Month,
	prev_month_orders,
	Current_month_order_count,
	 CASE 
        WHEN prev_month_orders > 0 THEN 
            ROUND((Current_month_order_count - prev_month_orders) * 100.0 / prev_month_orders, 2)
        ELSE NULL
    END AS growth_ratio
FROM
res_detail;



-- Q.12 Customer Segmentation: 
-- Customer Segmentation: Segment customers into 'Gold' or 'Silver' groups based on their total spending 
-- compared to the average order value (AOV). If a customer's total spending exceeds the AOV, 
-- label them as 'Gold'; otherwise, label them as 'Silver'. Write an SQL query to determine each segment's 
-- total number of orders and total revenue

-- cx total spend
-- aov
-- gold
-- silver
-- each category and total orders and total rev
-- 322.81 Average Order Value(AOV)

SELECT c.customer_name,
		sum(total_amount) as Total_order_value,
		COUNT(order_id) as total_orders,
		CASE
			WHEN SUM(total_amount) > (SELECT AVG(total_amount) from orders) THEN 'GOLD'
			ELSE 'SILVER'
		END AS Customer_status
FROM orders AS o
JOIN CUSTOMERS AS c
ON o.customer_id = c.customer_id
GROUP BY 1;

-- Q.13 Rider Monthly Earnings: 
-- Calculate each rider's total monthly earnings, assuming they earn 8% of the order amount.

SELECT  r.rider_id,
	r.rider_name,
	TO_CHAR(o.order_date, 'mm-yy') as month,
	SUM(total_amount) as revenue,
	SUM(total_amount)* 0.08 as riders_earning
FROM orders as o
JOIN deliveries as d
ON o.order_id = d.order_id
JOIN riders as r
ON d.rider_id = r.rider_id
Group by 1,2,3
ORDER BY 1,3;

-- Q.14 Rider Ratings Analysis: 
-- Find the number of 5-star, 4-star, and 3-star ratings each rider has.
-- riders receive this rating based on delivery time.
-- If orders are delivered less than 15 minutes of order received time the rider get 5 star rating,
-- if they deliver 15 and 20 minute they get 4 star rating 
-- if they deliver after 20 minute they get 3 star rating.
SELECT 
	rider_id, rider_name,
	stars,
	COUNT(*) as total_stars
FROM
(SELECT *,
		CASE
			WHEN delivery_took_time < 15 THEN '5 Star'
			WHEN delivery_took_time BETWEEN 15 AND 20 THEN '4Star'
			ELSE '3 Star'
		END as Stars
FROM
(SELECT r.rider_id,
		r.rider_name,
		o.order_time,
		d.delivery_time,
		EXTRACT(EPOCH from (d.delivery_time - o.order_time + 
				CASE
				 	WHEN d.delivery_time < o.order_time THEN INTERVAL '1day'
					ELSE INTERVAL '0 day'
				END))/60 AS delivery_took_time
FROM orders as o
JOIN deliveries as d
ON o.order_id = d.order_id
JOIN riders as r
ON d.rider_id = r.rider_id
WHERE delivery_status = 'Delivered') as p) as q
GROUP BY 1, 2,3
ORDER BY 1, 4 DESC;

-- Q.15 Order Frequency by Day: 
-- Analyze order frequency per day of the week and identify the peak day for each restaurant.
SELECT *
FROM 
(SELECT r.restaurant_name,
		To_CHAR(o.order_date,'Day') as Day,
		COUNT(o.order_id) as total_orders,
		RANK() OVER(PARTITION BY r.restaurant_name ORDER BY COUNT(o.order_id) DESC) as Rank
FROM orders as o
JOIN restaurants as r
ON o.restaurant_id = r.restaurant_id
GROUP BY 1,2
ORDER BY 1, 3 DESC) AS A
WHERE rank = 1;


-- Q.16 Customer Lifetime Value (CLV): 
-- Calculate the total revenue generated by each customer over all their orders.

SELECT 
	o.customer_id,
	c.customer_name,
	SUM(o.total_amount) as CLV
FROM orders as o
JOIN customers as c
ON o.customer_id = c.customer_id
GROUP BY 1, 2;

-- Q.17 Monthly Sales Trends: 
-- Identify sales trends by comparing each month's total sales to the previous month.
SELECT 
EXTRACT(YEAR FROM order_date) as Year,
EXTRACT(MONTH FROM order_date) as Month,
sum(total_amount) as total_revenue,
LAG(sum(total_amount),1) over(order by EXTRACT(YEAR FROM order_date), EXTRACT(Month FROM order_date)) as prev_month_sale
FROM orders
GROUP BY 1,2;


-- Q.18 Rider Efficiency: 
-- Evaluate rider efficiency by determining average delivery times and identifying those with the lowest and highest averages.
WITH Rider_detail AS
(SELECT r.rider_id,
r.rider_name,
o.order_time,
d.delivery_time,
EXTRACT(EPOCH from
					(d.delivery_time - o.order_time + 
					CASE
						WHEN d.delivery_time < o.order_time THEN INTERVAL '1 day'
						ELSE INTERVAL '0 day'
						END))/60 as time_delivery
FROM orders AS o
JOIN deliveries AS d
ON o.order_id = d.order_id
JOIN riders as r
ON d.rider_id = r.rider_id
WHERE d.delivery_status = 'Delivered')
,
ride_time AS
(
SELECT rider_id,
rider_name,
AVG(time_delivery) AS Avg_time
FROM Rider_detail
GROUP BY 1,2
)
SELECT 
	MIN(avg_time),
	MAX(avg_time)
FROM ride_time;



-- Q.19 Order Item Popularity: 
-- Track the popularity of specific order items over time and identify seasonal demand spikes.

Select order_item,
	seasons,
	COUNT(order_id) as total_orders
	FROM
(SELECT *,
EXTRACT(MONTH FROM order_date) as month,
CASE
	WHEN EXTRACT(MONTH FROM order_date) BETWEEN 3 AND 6 THEN 'Summer'
	WHEN EXTRACT(MONTH FROM order_date) BETWEEN 7 AND 9 THEN 'Monsoon'
	WHEN EXTRACT(MONTH FROM order_date) BETWEEN 10 AND 11 THEN 'Autumn'
	ELSE 'winter'
END AS seasons
FROM orders) as a
GROUP BY 1, 2
ORDER BY 1, 3 DESC;

-- Q.20 Rank each city based on the total revenue for last year 2023
SELECT r.city,
		sum(o.total_amount) as total_revenue,
		RANK() OVER(ORDER BY SUM(o.total_amount) DESC) as city_rank
FROM orders as o
JOIN
restaurants as r
ON o.restaurant_id = r.restaurant_id
WHERE EXTRACT(year from o.order_date) = 2023
GROUP BY 1;


