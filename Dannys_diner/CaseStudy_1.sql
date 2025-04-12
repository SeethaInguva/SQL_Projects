-- Creating database
Create database dannys_diner

------------------------------------------------Creating tables for dannys_diner database-------------------------------------------------------------------------
Create table Menu 
(
product_id int not null primary key, 
product_name varchar(5) not null,
price int not null
)

Create table members
( 
customer_id varchar(1) not null primary key, 
join_date date not null
)

CREATE TABLE sales (
  customer_id VARCHAR(1),
  order_date DATE,
  product_id int, 
);

---------------------------------------------------------------Inserting data into the tables---------------------------------------------------------------------------
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
 
 INSERT INTO menu
  (product_id, product_name, price)
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  
  INSERT INTO members
  (customer_id, join_date)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');

  Select * from members
  select * from Menu
  select * from sales

  ------------------------------------------------------------------------Case study questions------------------------------------------------------------------------

  -- What is the total amount each customer spent at the restaurant?
  Select SUM(price), customer_id as Price
  from sales s left join menu m 
  on s.product_id =  m.product_id 
  group by customer_id;


  --How many days has each customer visited the restaurant?
  Select  count(distinct(order_date)) as [Number Of Days Visited by each customer],customer_id 
  from sales 
  group by customer_id;


  --What was the first item from the menu purchased by each customer?
  WITH RESULT AS 
  (
  SELECT product_name, customer_id, order_date,
  ROW_NUMBER() OVER (PARTITION BY CUSTOMER_ID ORDER BY Order_date) AS product_rank
  FROM sales s left join menu m ON s.product_id =m.product_id
  )
  SELECT customer_id, product_name AS [First Item By Each Customer] FROM result WHERE product_rank = 1;


--What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT TOP 1 product_name AS [Most Purchased Item], COUNT(*) as [Total Number Of times purchased]
FROM sales s left join menu m 
ON s.product_id = m.product_id 
GROUP BY product_name 
ORDER BY [Total Number Of times purchased] DESC;
 

--Which item was the most popular for each customer?
  WITH RESULT AS
  (
  SELECT customer_id, product_name,
  ROW_NUMBER() OVER (PARTITION BY CUSTOMER_ID ORDER BY COUNT(*) desc) as product_rank
  from sales s LEFT JOIN menu m on s.product_id = m.product_id
  GROUP BY product_name, customer_id 
  )
  SELECT CUSTOMER_ID, PRODUCT_NAME AS [Most Popular Item]  FROM RESULT WHERE product_rank =1;


  -- Which item was purchased first by the customer after they became a member?
  WITH RESULT AS 
  (
  SELECT PRODUCT_NAME, S.CUSTOMER_ID,ORDER_DATE, JOIN_DATE,
  ROW_NUMBER() OVER (PARTITION BY S.CUSTOMER_ID ORDER BY ORDER_DATE) AS row_no
  FROM Sales s 
  INNER JOIN members me on s.customer_id = me.customer_id 
  INNER JOIN menu m on s.product_id = m.product_id
  WHERE JOIN_DATE < ORDER_DATE
  )
  SELECT PRODUCT_NAME, CUSTOMER_ID from RESULT WHERE row_no = 1;


 -- Which item was purchased just before the customer became a member?
  WITH RESULT AS 
  (
  SELECT PRODUCT_NAME, S.CUSTOMER_ID,ORDER_DATE, JOIN_DATE,
  RANK() OVER (PARTITION BY S.CUSTOMER_ID ORDER BY ORDER_DATE DESC) AS row_no
  FROM Sales s 
  INNER JOIN members me on s.customer_id = me.customer_id 
  INNER JOIN menu m on s.product_id = m.product_id
  WHERE  join_date  > order_date
  )
  SELECT PRODUCT_NAME , CUSTOMER_ID from RESULT WHERE row_no = 1;

  --What is the total items and amount spent for each member before they became a member?

 SELECT s.customer_id, COUNT(*) as [Total Items],
 sum(price) as [Total Amount Spent]FROM SALES S 
 INNER JOIN Menu m on s.product_id = m.product_id
 inner join members me on s.customer_id = me.customer_id
 where join_date> order_date
 group by s.customer_id;

--If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
---Using iif else 
with result as
(
Select customer_id, 
iif( product_name !='Sushi', price, price * 2) as price
from sales s left join menu m on s.product_id = m.product_id
)
select customer_id, sum(price) as  [No. of points earned]from result group by customer_id;
--Using case statement
with result as
(
Select customer_id, 
	case when product_name !='Sushi'
		THEN price
		else price * 2
	end as price
from sales s left join menu m on s.product_id = m.product_id
)
select customer_id, sum(price) as  [No. of points earned]from result group by customer_id;


--In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

WITH RESULT AS
(
 Select s.customer_id, 
iif(order_date <= DATEADD(day, 7, join_date) and order_date >= join_date , 2*price , price)  as price
from sales s 
inner join members m on s.customer_id = m.customer_id
inner join menu me on s.product_id =me.product_id
where order_date <= '2021-01-31'
)
SELECT CUSTOMER_ID, SUM(PRICE) AS [Total No. Of points earned in January] from result group by customer_id


--- Expected output----
Select s.customer_id , order_date, product_name, price, 
iif(join_date is not null and order_date > = join_date , 'Y', 'N' ) as member 
from sales s 
left join members m on s.customer_id = m.customer_id
left join menu me on s.product_id = me.product_id 
order by customer_id, order_date, product_name