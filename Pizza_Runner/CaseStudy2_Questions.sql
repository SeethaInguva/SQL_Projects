  --------------------------------A. Pizza Metrics----------------------------------------------------------------------------------------
 -- How many pizzas were ordered?
 select count(*) as [Total No. of Pizzas ordered]
 from customer_orders;

--How many unique customer orders were made?
 select count(distinct order_id) as [Unique Customer Orders] 
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

Select * from customer_orders
--For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
select customer_id , 
sum(case when exclusions IS NULL and extras  IS NULL then 1
		 else 0
	end) as [No change],
	sum(case when (exclusions IS NOT NULL or  extras IS NOT NULL) then 1
			 else 0
		end) as [Atleast One change]
from customer_orders c left join runner_orders r on c.order_id = r.order_id 
where cancellation not like '%cancel%' 
group by customer_id 
order by customer_id

--How many pizzas were delivered that had both exclusions and extras?
SELECT  count (*)  as [Pizzas delivered with both exclusions and extras]
from customer_orders c 
left join runner_orders r 
on c.order_id = r.order_id  
where cancellation not like '%cancel%' and (exclusions IS NOT NULL and extras IS NOT NULL )

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

-------------------------------------------------B.Runner and Customer Experience--------------------------------------------------------------------

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

----------------------------------------------C. Ingredient Option---------------------------------------------------------------------------
--What are the standard ingredients for each pizza?
with pizza1 as
(
SELECT Trim(value) AS topping
FROM pizza_recipes
Cross apply string_split(toppings, ',')
WHERE pizza_id = 1
),
pizza2 as
(
SELECT Trim(value) AS topping
FROM pizza_recipes
Cross apply string_split(toppings, ',')
WHERE pizza_id = 2
)
SELECT pizza1.topping
from pizza1
inner join pizza2
on pizza1.topping = pizza2.topping;

--What was the most commonly added extra?
with extras as (
Select Trim(value) AS extra_toppings
From  customer_orders
Cross apply string_split(extras, ',') where extras IS NOT NULL
),
commonly_used_extra as
(
select  top 1 extra_toppings as most_commonly_added_extra, 
count(*) as [No. of times]  
from extras 
group by extra_toppings 
) select topping_name 
from pizza_toppings p
inner join commonly_used_extra c 
on p.topping_id = c.most_commonly_added_extra;

--What was the most common exclusion?
with exclusion as (
Select Trim(value) AS exclusion_toppings
From  customer_orders
Cross apply string_split(exclusions, ',') where exclusions IS NOT NULL
),
common_exclusion as
(
select  top 1 exclusion_toppings as most_common_exclusion, 
count(*) as [No. of times]  
from exclusion 
group by exclusion_toppings 
) select topping_name 
from pizza_toppings p
inner join common_exclusion m
on p.topping_id = m.most_common_exclusion;

select * from customer_orders;


------------------------------------------D. Pricing and Ratings-----------------------------------------------------------------------
--If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - 
--how much money has Pizza Runner made so far if there are no delivery fees?
 
select sum(case when pizza_id = 1 then 12
                    when pizza_id =2 then 10 end) as total_revenue from customer_orders;

--What if there was an additional $1 charge for any pizza extras? Add cheese is $1 extra
with extra_toppings as
(
Select Trim(value) AS toppings
From  customer_orders
Cross apply string_split(extras, ',') where extras IS NOT NULL
),
extra_charge as
( 
select  (SELECT COUNT(*) FROM extra_toppings) AS toppings_count,
sum(case when pizza_id =1 then 12 
                when pizza_id =2 then 10 end) as total_revenue
from customer_orders
)
select toppings_count+total_revenue as revenue_with_extras from extra_charge;

--The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, 
--how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data 
--for ratings for each successful customer order between 1 to 5.

INSERT INTO runner_ratings (order_id, runner_id, rating)
VALUES 
(1, 1, 5),
(3, 1, 4),
(4, 2, 5),
(5, 1, 3),
(7, 2, 4),
(9, 1, 5),
(10, 1, 3);
select * from customer_orders
select * from runner_orders
select * from runner_ratings

--Using your newly generated table - can you join all of the information together to form a table which has the following information 
--for successful deliveries?
--customer_id
--order_id
--runner_id
--rating
--order_time
--pickup_time
--Time between order and pickup
--Delivery duration
--Average speed
--Total number of pizzas
select distinct runner_ratings.order_id, customer_id, runner_id, rating, order_time,pickup_time,
DATEDIFF(minute,order_time,pickup_time) as[Time between order and pickup],
DATEADD(MINUTE,duration,pickup_time) as delivery_duration, 
ROUND(CAST(distance AS FLOAT) / (CAST(duration AS FLOAT) / 60.0), 2) AS avg_speed_kmph,
COUNT(pizza_id) over (partition by runner_ratings.order_id order by runner_ratings.order_id) AS total_pizzas
from customer_orders
inner join runner_orders on customer_orders.order_id = runner_orders.order_id
inner join runner_ratings on customer_orders.order_id =runner_ratings.order_id;
select * from pizza_names;
--If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre 
--traveled - how much money does Pizza Runner have left over after these deliveries?
with total_charges_calculated as
(
select  (distance *0.30) as runner_charge_perkm , case when pizza_id =1  then 12 
			when pizza_id =2 then 10 end as pizza_price 
			from customer_orders 
			inner join runner_orders 
			on customer_orders.order_id = runner_orders.order_id
)
select (pizza_price- runner_charge_perkm) as moneyleft_afterdeliveries from total_charges_calculated

----------------------------------------------------------E. Bonus Questions---------------------------------------------------------------
--If Danny wants to expand his range of pizzas - how would this impact the existing data design? 
--Write an INSERT statement to demonstrate what would happen if a new Supreme pizza with all the toppings was added to the Pizza Runner menu?

INSERT INTO pizza_names (pizza_id, pizza_name)
VALUES (3, 'Supreme');

INSERT INTO pizza_recipes (pizza_id, toppings)
VALUES (3, '1,2,3,4,5,6,7,8,9,10');