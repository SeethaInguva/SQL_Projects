
------------------------------------------------------Creation Queries---------------------------------------------------------------------------------------------
CREATE TABLE runners (
  runner_id int,
  registration_date DATE
);
INSERT INTO runners
  (runner_id, registration_date)
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');
  select * from customer_orders

  CREATE TABLE customer_orders (
  order_id int,
  customer_id int,
  pizza_id int,
  exclusions VARCHAR(4),
  extras VARCHAR(4),
  order_time datetime
);

INSERT INTO customer_orders
  (order_id, customer_id, pizza_id, exclusions, extras, order_time)
VALUES
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
  ('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
  ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
  ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
  ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');
  -------------------------------------------------------------Data Cleaning----------------------------------------------------------------------------------------------- 
  ALTER TABLE customer_orders
  ALTER COLUMN exclusions varchar(20);

 Update customer_orders
 set exclusions = 'No Exclusions'
 where exclusions is NULL or exclusions = '' or exclusions = 'null'

 ALTER TABLE customer_orders
  ALTER COLUMN extras varchar(20);

 Update customer_orders
 set extras = 'No extras'---- try using case as well; can be done togetherv. come back
 where extras is NULL or extras = '' or extras = 'null'

 SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'customer_orders'

  drop table if exists runner_orders;
  drop table if exists customer_orders;

  CREATE TABLE runner_orders (
  order_id INT,
  runner_id INT,
  pickup_time VARCHAR(19),
  distance VARCHAR(7),
  duration VARCHAR(10),
  cancellation VARCHAR(23)
);

 INSERT INTO runner_orders
  (order_id, runner_id, pickup_time, distance, duration, cancellation)
VALUES
  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');

SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'runner_orders'

UPDATE runner_orders
SET distance = 
    CASE 
        WHEN TRY_CAST(LEFT(distance, PATINDEX('%[^0-9]%', distance + ' ') - 1) AS INT) IS NOT NULL 
        THEN LEFT(distance, PATINDEX('%[^0-9]%', distance + ' ') - 1) 
        ELSE NULL 
    END;

UPDATE runner_orders
SET duration = 
    CASE 
        WHEN TRY_CAST(LEFT(duration, PATINDEX('%[^0-9]%', duration + ' ') - 1) AS INT) IS NOT NULL 
        THEN LEFT(duration, PATINDEX('%[^0-9]%', duration + ' ') - 1) 
        ELSE NULL 
    END;

ALTER TABLE runner_orders
ALTER COLUMN distance INT;

ALTER TABLE runner_orders
ALTER COLUMN duration INT;

UPDATE runner_orders
SET pickup_time = NULL
WHERE TRY_CONVERT(DATETIME, pickup_time, 120) IS NULL 
AND pickup_time IS NOT NULL;

ALTER TABLE runner_orders 
ALTER COLUMN pickup_time DATETIME;

Update runner_orders
set cancellation = 'No'
where cancellation ='' or cancellation = 'null' or cancellation is NULL

  CREATE TABLE pizza_names (
  pizza_id INT,
  pizza_name TEXT
);

INSERT INTO pizza_names
  (pizza_id, pizza_name)
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');

  select * from pizza_names

  ALTER table pizza_names 
  alter column pizza_name varchar(10)

  CREATE TABLE pizza_recipes (
  pizza_id INTEGER,
  toppings TEXT
);
INSERT INTO pizza_recipes
  (pizza_id, toppings)
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');

  ALTER table pizza_recipes 
  alter column toppings varchar(30)

  CREATE TABLE pizza_toppings (
  topping_id INT,
  topping_name TEXT
);
INSERT INTO pizza_toppings
  (topping_id, topping_name)
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');

  ALTER table pizza_recipes 
  alter column toppings varchar(30);

  --------------------------------Questions ----------------------------------------------------------------------------------------
 -- How many pizzas were ordered?
 select count(*) as [Total No. of Pizzas ordered]
 from customer_orders;

--How many unique customer orders were made?
 select count(distinct(order_id)) as [Unique Customer Orders] 
 from customer_orders;

--How many successful orders were delivered by each runner?
select runner_id, count(*) as [Successful Orders]  from customer_orders c 
left join runner_orders r 
on c.order_id = r.order_id 
where cancellation not like '%cancel%'  
group by runner_id

--How many of each type of pizza was delivered?
select pizza_id, count(*) as [No. Of Pizzas]  
from customer_orders c 
left join runner_orders r 
on c.order_id = r.order_id 
where cancellation not like '%cancel%'  
group by pizza_id

--How many Vegetarian and Meatlovers were ordered by each customer?
Select customer_id,  pizza_name, count(*) as [No. Of pizzas ordered] 
from customer_orders c 
left join pizza_names pn 
on c.pizza_id = pn.pizza_id 
group by customer_id, pizza_name 

--What was the maximum number of pizzas delivered in a single order?
Select top 1 count(*)  as [Maximum no. of pizzas delivered in a single order]
from customer_orders c 
left join runner_orders r 
on c.order_id = r.order_id 
where cancellation not like '%cancel%' 
group by c.order_id 
order by count(*) desc

--For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
select customer_id , 
sum(case when exclusions = 'No Exclusions' and extras  = 'No extras' then 1
		 else 0
	end) as [No change],
	sum(case when (exclusions != 'No Exclusions' or  extras != 'No extras') then 1
			 else 0
		end) as [Atleast One change]
from customer_orders c left join runner_orders r on c.order_id = r.order_id 
where cancellation not like '%cancel%' 
group by customer_id 
order by customer_id

--How many pizzas were delivered that had both exclusions and extras?
SELECT  count (*)  as [Pizzas delivered with both exclusionss and extras]
from customer_orders c 
left join runner_orders r 
on c.order_id = r.order_id  
where cancellation not like '%cancel%' and (exclusions <> 'No Exclusions' and extras <>'No extras' )

--What was the total volume of pizzas ordered for each hour of the day?
with result as
(
Select datepart (hour, order_time) as [Hour Of the day] from Customer_orders
) select [Hour Of the day] , count([Hour Of the day]) as [Volume of pizzas] from result group by [Hour Of the day] ;

--What was the volume of orders for each day of the week?
with result as
(
Select datepart (weekday, order_time) as [Day Of week] from Customer_orders
) select [Day Of week] , count([Day Of week]) as [Volume of pizzas] from result group by [Day Of week] ;
-------------------------------------------------Runner and Customer Experience--------------------------------------------------------------------

--How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
Select datepart (week, registration_date) as [Week Number], count(datepart (week, registration_date)) as [Runners signed up] 
from runners 
group by datepart (week, registration_date);
With Result as 
(
Select datepart (week, registration_date) as [Week Number] from runners 
)select [Week Number], count([Week Number]) as [Runners signed up] from Result group by [Week Number];

--What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
select runner_id, abs(avg(datediff(minute, pickup_time, order_time)))as [Average time in minutes] 
from customer_orders c 
left join runner_orders r 
on c.order_id = r.order_id 
group by runner_id;

--Is there any relationship between the number of pizzas and how long the order takes to prepare?
with result as
(
select c.order_id, count(pizza_id) as [No of pizzas per order],abs(avg(datediff(minute, pickup_time, order_time)))as [Average time in minutes] 
from customer_orders c 
left join runner_orders r 
on c.order_id = r.order_id 
where pickup_time is not null
group by c.order_id
)select [No of pizzas per order], [Average time in minutes]/[No of pizzas per order] as [Time consumed per pizza]  from result;

--What was the average distance travelled for each customer?
Select avg(distance) as [Average distance travelled for each customer] from runner_orders where distance <> 0;

--What was the difference between the longest and shortest delivery times for all orders?
Select max(duration) -min(duration) [difference between the longest and shortest delivery times in minutes]from runner_orders where duration  <>0;

--What was the average speed for each runner for each delivery and do you notice any trend for these values?
select * from runner_orders
select runner_id, order_id ,round(avg (distance *60 /duration),2) 
from runner_orders where cancellation not like '%cancel%' and distance <>0 and duration <>0 group by runner_id, order_id order by runner_id;

--What is the successful delivery percentage for each runner?
with result as (
Select runner_id,
convert(float,sum(case 
		when cancellation like '%cancel%' then 1 
		else 0
	end)) as [Cancelled Orders],
convert(float, sum(case when cancellation not like '%cancel%' then 1 
else 0
end)) as [Successful Orders], count(*) as[Count]
from runner_orders group by runner_id
) select runner_id, convert( float, ([Successful Orders] *100/[Count]))as [Successful Delivery percentage] from result;

----------------------------------------------Ingredient Option-------------------------------------------
--What are the standard ingredients for each pizza?
select pizza_id, value from pizza_recipes CROSS APPLY STRING_SPLIT(toppings, ',');

alter table runner_orders
alter column distance float;

alter table runner_orders
alter column duration float;
