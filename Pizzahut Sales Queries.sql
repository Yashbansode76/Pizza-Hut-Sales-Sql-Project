create database pizzahut
use pizzahut
select * from pizzas
select * from pizza_types
select * from orders
select * from order_details

-- Retrieve the total number of orders placed
SELECT COUNT(order_id) AS total_orders
FROM orders;

-- Calculate the total revenue generated from pizza sales
SELECT SUM(od.quantity * p.price) AS total_revenue
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id;

-- Identify the highest-priced pizza
SELECT pizza_id, price
FROM pizzas
ORDER BY price DESC
LIMIT 1;

-- Identify the most common pizza size ordered
SELECT p.size, SUM(od.quantity) AS total_ordered
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
GROUP BY p.size
ORDER BY total_ordered DESC
LIMIT 1;

-- List the top 5 most ordered pizza types along with their quantities
SELECT pt.name, SUM(od.quantity) AS total_ordered
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY total_ordered DESC
LIMIT 5;

-- Join the necessary tables to find the total quantity of each pizza category ordered
SELECT pt.category, SUM(od.quantity) AS total_quantity
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.category
ORDER BY total_quantity DESC;

-- Determine the distribution of orders by hour of the day
SELECT HOUR(o.time) AS order_hour, COUNT(o.order_id) AS total_orders
FROM orders o
GROUP BY HOUR(o.time)
ORDER BY order_hour;

-- Join relevant tables to find the category-wise distribution of pizzas
SELECT pt.category, COUNT(p.pizza_id) AS total_pizzas
FROM pizzas p
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.category;

-- Group the orders by date and calculate the average number of pizzas ordered per day
SELECT o.date, AVG(daily.total_quantity) AS avg_pizzas_per_day
FROM orders o
JOIN (
    SELECT order_id, SUM(quantity) AS total_quantity
    FROM order_details
    GROUP BY order_id
) daily ON o.order_id = daily.order_id
GROUP BY o.date;

-- Determine the top 3 most ordered pizza types based on revenue
SELECT pt.name, SUM(od.quantity * p.price) AS total_revenue
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY total_revenue DESC
LIMIT 3;

-- Calculate the percentage contribution of each pizza type to total revenue
SELECT pt.name,
       ROUND((SUM(od.quantity * p.price) /
              (SELECT SUM(od2.quantity * p2.price)
               FROM order_details od2
               JOIN pizzas p2 ON od2.pizza_id = p2.pizza_id) * 100), 2) AS revenue_percentage
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY revenue_percentage DESC;

-- Analyze the cumulative revenue generated over time
SELECT o.date,
       SUM(od.quantity * p.price) AS daily_revenue,
       SUM(SUM(od.quantity * p.price)) OVER (ORDER BY o.date) AS cumulative_revenue
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
JOIN pizzas p ON od.pizza_id = p.pizza_id
GROUP BY o.date
ORDER BY o.date;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category
SELECT category, name, total_revenue
FROM (
    SELECT pt.category, pt.name,
           SUM(od.quantity * p.price) AS total_revenue,
           RANK() OVER (PARTITION BY pt.category ORDER BY SUM(od.quantity * p.price) DESC) AS rank_in_category
    FROM order_details od
    JOIN pizzas p ON od.pizza_id = p.pizza_id
    JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
    GROUP BY pt.category, pt.name
) ranked
WHERE rank_in_category <= 3
ORDER BY category, total_revenue DESC;

