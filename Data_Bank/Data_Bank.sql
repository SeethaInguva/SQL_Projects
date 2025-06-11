-----------------------------------------------A. Customer Nodes Exploration-----------------------------------------------------------------------
--How many unique nodes are there on the Data Bank system?
select count(distinct(node_id)) as unique_nodes 
from customer_nodes;
--What is the number of nodes per region?
SELECT region_id, COUNT(DISTINCT node_id) AS num_nodes
FROM customer_nodes
GROUP BY region_id
ORDER BY region_id;
--How many customers are allocated to each region?
select region_id, count(distinct customer_id) as [No of customers] 
from customer_nodes 
group by region_id 
order by region_id;

--How many days on average are customers reallocated to a different node?
with result as 
(
select customer_id, 
node_id,
start_date,
lead(start_date) over (partition by customer_id order by start_date) as end_date_lead,
lead(node_id) over (partition by customer_id order by start_date) as next_node 
from customer_nodes
) 
select avg(DATEDIFF(day, start_date, end_date_lead)) as [Avg number of days] 
from result 
where node_id<>next_node and end_date_lead is not NULL;
--What is the median, 80th and 95th percentile for this same reallocation days metric for each region?
--Median
with result as 
(
select customer_id, 
node_id,
lead(start_date) over (partition by customer_id order by start_date) as end_date_lead,
lead(node_id) over (partition by customer_id order by start_date) as next_node 
from customer_nodes
) 
select customer_id, node_id, DATEDIFF(day, start_date, end_date_lead) as [Avg number of days] 
from result 
where node_id<>next_node and end_date_lead is not NULL;


--------------------------------------B. Customer Transactions-----------------------------------------------------
--What is the unique count and total amount for each transaction type?
select txn_type, count(distinct customer_id) as [No. of Customers] , SUM(txn_amount) as [Total Amount] from customer_transactions group by txn_type;
--What is the average total historical deposit counts and amounts for all customers?
with cte as(
Select customer_id, 
count(txn_type) as [Deposits count], 
sum(txn_amount)as [Total Amount]
from customer_transactions 
where txn_type= 'deposit' 
group by customer_id 
)
select avg([Deposits count]) as [Average Total deposit count], 
AVG([Total Amount])as [Average total Amount] 
from cte;
--For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?
with cte as 
(
select customer_id, MONTH(txn_date) as [Month_number],
sum(case when txn_type = 'deposit' then 1 else 0 end) as deposit_count,
sum(case when txn_type = 'purchase' then 1 else 0 end) as purchase_count,
sum(case when txn_type = 'withdrawal' then 1 else 0 end) as withdrawl_count
from customer_transactions group by MONTH(txn_date), customer_id 
)
select [Month_number], count(customer_id) as [Total No. of Customers]
 from cte 
where deposit_count >1 and (purchase_count =1 or withdrawl_count = 1) 
group by [Month_number]
order by [Month_number];
--What is the closing balance for each customer at the end of the month?
with cte as 
(
select customer_id,  
sum(case when txn_type !='deposit' then -txn_amount else txn_amount end) as monthly_amount,
EOMONTH(txn_date)  as end_of_month 
from customer_transactions 
group by customer_id,
EOMONTH(txn_date) 
) 
SELECT
    customer_id,
    end_of_month,
    SUM(monthly_amount) OVER (
        PARTITION BY customer_id
        ORDER BY end_of_month
    ) AS closing_balance
FROM cte;
--What is the percentage of customers who increase their closing balance by more than 5%?
WITH cte AS (
  SELECT 
    customer_id,  
    SUM(CASE 
          WHEN txn_type != 'deposit' THEN -txn_amount 
          ELSE txn_amount 
        END) AS monthly_amount,
    EOMONTH(txn_date) AS end_of_month
  FROM customer_transactions 
  GROUP BY customer_id, EOMONTH(txn_date)
),

running_balance AS (
  SELECT
    customer_id,
    end_of_month,
    SUM(monthly_amount) OVER (
      PARTITION BY customer_id
      ORDER BY end_of_month
    ) AS closing_balance
  FROM cte 
),

result AS (
  SELECT 
    customer_id, 
    closing_balance,
    LEAD(closing_balance) OVER (
      PARTITION BY customer_id 
      ORDER BY end_of_month
    ) AS next_balance
  FROM running_balance
),

result1 AS (
  SELECT 
    customer_id
  FROM result 
  WHERE 
    next_balance IS NOT NULL 
    AND next_balance > closing_balance * 1.05
  GROUP BY customer_id
)
SELECT 
  ROUND(
    100.0 * COUNT(DISTINCT customer_id) / 
    NULLIF((SELECT COUNT(DISTINCT customer_id) FROM customer_transactions), 0), 
    2
  ) AS percentage_more_than_5_increase
FROM result1;
---------------------------------------------C. Data Allocation change------------------------------------------------------------------ 
--Running_Balances

WITH adjusted_txns as (
  select 
    customer_id,
    txn_date,
    case 
      when txn_type != 'deposit' then -txn_amount 
      else txn_amount 
    end as adjusted_amount
  from customer_transactions
),
running_balance as (
  select 
    customer_id,
    txn_date,
    adjusted_amount,
    SUM(adjusted_amount) OVER (
      partition by customer_id 
      order by txn_date
      rows BETWEEN unbounded preceding and current row
    ) as running_balance
  from adjusted_txns
)
select * from running_balance
order by customer_id, txn_date;

--Customer Balance at the end of each month
WITH adjusted_txns AS (
  SELECT 
    customer_id,
    txn_date,
    CASE 
      WHEN txn_type != 'deposit' THEN -txn_amount 
      ELSE txn_amount 
    END AS adjusted_amount
  FROM customer_transactions
),
running_balance AS (
  SELECT 
    customer_id,
    txn_date,
    SUM(adjusted_amount) OVER (
      PARTITION BY customer_id 
      ORDER BY txn_date
      ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_balance
  FROM adjusted_txns
),
month_end_balance AS (
  SELECT 
    customer_id,
    YEAR(txn_date) AS year,
    MONTH(txn_date) AS month,
    txn_date,
    running_balance,
    RANK() OVER (
      PARTITION BY customer_id, YEAR(txn_date), MONTH(txn_date)
      ORDER BY txn_date DESC
    ) AS rnk
  FROM running_balance
)
SELECT 
  customer_id,
  year,
  month,
  txn_date AS last_txn_date_in_month,
  running_balance AS end_of_month_balance
FROM month_end_balance
WHERE rnk = 1
ORDER BY customer_id, year, month;

--MIN, MAX and avg values of running balance for each customer

WITH adjusted_txns AS (
  SELECT 
    customer_id,
    txn_date,
    CASE 
      WHEN txn_type != 'deposit' THEN -txn_amount 
      ELSE txn_amount 
    END AS adjusted_amount
  FROM customer_transactions
),
running_balance AS (
  SELECT 
    customer_id,
    txn_date,
    SUM(adjusted_amount) OVER (
      PARTITION BY customer_id 
      ORDER BY txn_date
    ) AS running_balance
  FROM adjusted_txns
)
SELECT 
  customer_id,
  MIN(running_balance) AS min_balance,
  MAX(running_balance) AS max_balance,
  ROUND(AVG(running_balance), 2) AS avg_balance
FROM running_balance
GROUP BY customer_id
ORDER BY customer_id;

