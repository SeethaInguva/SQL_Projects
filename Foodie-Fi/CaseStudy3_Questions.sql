------------------------------------------------------Customer Journey---------------------------------------------------------------------------
  /*Based off the 8 sample customers provided in the sample from the subscriptions table, write a brief description about each customer’s onboarding journey.
  Try to keep it as short as possible - you may also want to run some sort of join to make your explanations a bit easier!*/
select customer_id,plan_name, price, start_date from Subscriptions_sample ss left join plans pl on ss.plan_id =pl.plan_id
/*1. They got onto trial and took up a basic monthly plan.
2. Took a trail and then pro-annual plan.
11. Took a trial and then churn, got out of it after trial.
13. Took a trial, then experimented with basic monthly and then took shifted to pro monthly.
15. Took a trial, got into pro monthly plan and then churned.
16. Took a trial, then guot a basic monthly, shifted to pro annual.
18. Took a trial, then changed to pro monthly
19. took a trial, chnaged to pro monthly and then to pro annual.
ON the whole, the customer onboarding has a trend, everyone is once taking the trial, understanding the app and 
then proceeding according to their requirement. */


------------------------------------------------Data Analysis Questions ---------------------------------------------------------------

--How many customers has Foodie-Fi ever had?
select count(distinct(customer_id)) as [Customers of Foodie-Fi] from Subscriptions;

--What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value
SELECT month(start_date) AS months, COUNT(customer_id) AS [Num of customers]
FROM subscriptions
group by month(start_date)
order by month(start_date);
--What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name
  select plan_name, count(customer_id) as [No. Of Customers] 
  from Subscriptions ss left join plans pl on ss.plan_id =pl.plan_id 
  where start_date >= '2021-01-01' 
  group by plan_name;


--What is the customer count and percentage of customers who have churned rounded to 1 decimal place?

Select count(customer_id) as [churned_Customer_count], 
cast(100.0* count(customer_id)/(select count(distinct customer_id) from subscriptions) as decimal(5,1)) as customer_pct from  Subscriptions where plan_id =4


select * from subscriptions
--How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?
with result as (
select customer_id , count(customer_id) over(partition by customer_id order by customer_id) as [Count], 
lead(plan_id) over (partition by customer_id order by customer_id) as [Next Plan] from Subscriptions
) select count(customer_id) as [No. Of customers], abs(count(customer_id)*100/(select count(distinct(customer_id)) from Subscriptions)) as [Percentage of churn] from result where [Count] =2 and [Next Plan] = 4;

--What is the number and percentage of customer plans after their initial free trial?
with result as (
select customer_id , plan_id,
lead(plan_id) over (partition by customer_id order by customer_id) as [Next Plan] from Subscriptions
) select [Next Plan], count([Next Plan]) as [No. of customers] from result  where [Next Plan] is not null group by [Next Plan];


--What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?
with result as (
select customer_id , plan_id,
lead(plan_id) over (partition by customer_id order by customer_id) as [Next Plan] from Subscriptions where start_date <= '2020-12-31'
) select [Next Plan], count([Next Plan]) as [No. of custoemrs] from result  where [Next Plan] is not null group by [Next Plan];
--How many customers have upgraded to an annual plan in 2020?
with result as (
select customer_id , plan_id,
lead(plan_id) over (partition by customer_id order by customer_id) as [Next Plan] from Subscriptions_sample where start_date <= '2020-12-31'
) select [Next Plan], count([Next Plan]) as [No. of custoemrs] from result  where [Next Plan] =3 group by [Next Plan];
select * from plans;
--How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?
with result as 
(
SELECT customer_id, start_date, plan_name,
lead(start_date) over (partition by customer_id order by customer_id) as [Next Row Date] FROM Subscriptions SS 
LEFT JOIN PLANS PL ON SS.plan_id = pl.plan_id where ss.plan_id = 0 or ss.plan_id =3
) select avg(Datediff(day,start_date, [Next Row Date] )) as[No. Of days]from result where [Next Row Date] is not null;

--Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)
select * from plans
select * from subscriptions;

with result as 
(
SELECT customer_id, start_date, plan_name,
lead(start_date) over (partition by customer_id order by customer_id) as [Next Row Date] FROM Subscriptions ss 
LEFT JOIN PLANS PL ON ss.plan_id = pl.plan_id where ss.plan_id in (0,3)
),
difference_days as 
(
select customer_id,
start_date, 
[Next Row Date],  
Datediff(day,start_date, [Next Row Date]) as [No. Of days],
case 
    when Datediff(day,start_date, [Next Row Date]) <=30 then '0-30'
    when Datediff(day,start_date, [Next Row Date]) <=60 then '31-60'
    when Datediff(day,start_date, [Next Row Date]) <=90 then '61-90'
    when Datediff(day,start_date, [Next Row Date]) <=120 then '91-120'
    when Datediff(day,start_date, [Next Row Date]) <=150 then '121-150'
    else '150+' end as days_bucket
from result where [Next Row Date] is not null
)
select days_bucket, avg([No. Of days]) as avg_days from difference_days group by days_bucket
ORDER BY CASE days_bucket
        WHEN '0-30' THEN 1
        WHEN '31-60' THEN 2
        WHEN '61-90' THEN 3
        WHEN '91-120' THEN 4
        WHEN '121-150' THEN 5
        ELSE 6
    END;

--How many customers downgraded from a pro monthly to a basic monthly plan in 2020?
with result as (
Select customer_id, count(customer_id) over(partition by customer_id order by customer_id) as [Count], lead(start_date) over (partition by customer_id order by customer_id) as [Next Row Date], start_date, plan_name 
from Subscriptions ss left join plans pl on ss.plan_id = pl.plan_id where ss.plan_id = 1 or ss.plan_id =2 
)select count(customer_id) as[No. Of customers] from result where [Next Row Date] < start_date and [count]=2;


/*The Foodie-Fi team wants you to create a new payments table for the year 2020 that includes amounts paid by each customer 
in the subscriptions table with the following requirements:
1.monthly payments always occur on the same day of month as the original start_date of any monthly paid plan
2.upgrades from basic to monthly or pro plans are reduced by the current paid amount in that month and start immediately
3.upgrades from pro monthly to pro annual are paid at the end of the current billing period and also starts at the end of the month period
4.once a customer churns they will no longer make payments*/
CREATE TABLE payments_table (
  customer_id int not null,
  plan_id int not null,
  plan_name VARCHAR(50) not null,
  payment_date date not null,
  amount decimal(10,2) not null,
  payment_order int not null
);

--------------------------------- Query to be continued for payments table------------------------------------------------------------------

