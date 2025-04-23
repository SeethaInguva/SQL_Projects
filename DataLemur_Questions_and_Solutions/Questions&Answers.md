
**Question 1 :** [SQL- Histogram of Tweets](https://datalemur.com/questions/sql-histogram-tweets)  

Solution - 
    
    with result as 
      (
      SELECT count(user_id) as count_of_tweets, user_id 
      from tweets 
      where tweet_date < '01/01/2023'and tweet_date >= '01/01/2022'
      group by user_id 
      )
      select distinct(count_of_tweets) as tweet_bucket, count(count_of_tweets) as users_num 
      from result 
      group by count_of_tweets;
---

**Question 2 :** [SQL- Data Science Skills](https://datalemur.com/questions/matching-skills) 

Solution - 
    
    with result as 
    (
      SELECT candidate_id, count(candidate_id)as count_of_skills FROM candidates
      where skill IN('Python','Tableau','PostgreSQL') 
      group by candidate_id
    ) 
    select candidate_id from result where count_of_skills =3;
  ---

**Question 3 :** [SQL- Page With No Likes](https://datalemur.com/questions/sql-page-with-no-likes) 

Solution - 
    
    SELECT page_id from pages where page_id not in (select page_id from page_likes)
    order by page_id;
---

**Question 4 :** [SQL- Unfinished Parts](https://datalemur.com/questions/tesla-unfinished-parts) 

Solution - 
    
    SELECT part, assembly_step FROM parts_assembly where finish_date is null;
  ---

**Question 5 :** [SQL- Laptop vs. Mobile Viewership](https://datalemur.com/questions/laptop-mobile-viewership) 

Solution - 
    
    SELECT sum(case 
               when device_type = 'laptop' then 1
               end) as laptop_views,
        sum(case 
               when device_type = 'tablet' or device_type = 'phone' then 1
               end) as mobile_views 
        from viewership;
  ---
  **Question 6 :** [SQL- Average Post Hiatus (Part 1)](https://datalemur.com/questions/sql-average-post-hiatus-1) 

Solution - 
    
    	SELECT user_id, MAX(post_date::date)- MIN(post_date::date) AS days_between FROM posts
        WHERE DATE_PART('year',post_date::date)=2021 
        GROUP BY user_id
        HAVING COUNT(post_id)>1;
 ---
   **Question 7 :** [SQL- Teams Power Users](https://datalemur.com/questions/teams-power-users) 

Solution - 
    
    	SELECT sender_id,  count(sender_id) as message_count FROM messages 
        where DATE_PART('year',sent_date::date)=2022 and DATE_PART('month',sent_date::date)=8
        group by sender_id order by count(sender_id) desc limit 2 ;
---
 **Question 8 :** [SQL- Duplicate Job Listings](https://datalemur.com/questions/duplicate-job-listings) 

Solution - 
    
    	with result as 
        (SELECT *, row_number() over(partition by company_id, title, description order by company_id, title, description) as rowno
          FROM job_listings
        ) select count(rowno) as duplicate_companies from result where rowno =2;
---
 **Question 9 :** [SQL- Cities With Completed Trades](https://datalemur.com/questions/completed-trades) 

Solution - 
    
    	SELECT city, count(*) as total_orders FROM trades t 
        left join users u on t.user_id = u.user_id where status = 'Completed'
        group by city
        order by count(*) desc limit 3;
---
 **Question 10 :** [SQL- Average Review Ratings](https://datalemur.com/questions/sql-avg-review-ratings) 

Solution - 
    
    	SELECT date_part('month',submit_date:: DATE) AS mth, product_id as product, round(avg(stars),2) as avg_stars FROM reviews
        group by product_id,  date_part('month',submit_date:: DATE) 
        order by date_part('month',submit_date:: DATE);
---
 **Question 11 :** [SQL- Well Paid Employees](https://datalemur.com/questions/sql-well-paid-employees) 

Solution - 
    
    	SELECT e.employee_id, e.name as employee_name 
        FROM employee e 
        join  employee m on e.manager_id = m.employee_id 
        where e.salary > m.salary;
---
**Question 12 :** [SQL- App Click-through Rate (CTR)](https://datalemur.com/questions/click-through-rate) 

Solution - 
    
        SELECT app_id, round(100.0 * sum(CASE WHEN event_type = 'click' THEN 1 ELSE 0 END) /sum(CASE WHEN event_type = 'impression' THEN 1 ELSE 0 END),2) AS 
        ctr_rate FROM events WHERE timestamp >= '2022-01-01' AND timestamp < '2023-01-01'
        GROUP BY app_id;
---
**Question 13 :** [SQL- Second Day Confirmation](https://datalemur.com/questions/second-day-confirmation) 

Solution - 
    
        SELECT user_id FROM emails e 
        left join texts t on e.email_id = t. email_id 
        where signup_action = 'Confirmed' and action_date = signup_date + INTERVAL '1 day';
---
**Question 14 :** [SQL- IBM db2 Product Analytics](https://datalemur.com/questions/sql-ibm-db2-product-analytics) 

Solution - 
    
        WITH result AS (
        SELECT e.employee_id, COUNT(q.query_id) AS unique_queries FROM employees e 
        LEFT JOIN queries q ON e.employee_id = q.employee_id 
        AND (
            (EXTRACT(QUARTER FROM q.query_starttime::DATE) = 3 
            AND EXTRACT(YEAR FROM q.query_starttime::DATE) = 2023) 
            OR q.query_starttime IS NULL
          )
         GROUP BY e.employee_id
         ) 
         SELECT unique_queries, COUNT(unique_queries) AS employee_count FROM result 
         GROUP BY unique_queries
         order by unique_queries;
---
**Question 15 :** [SQL- Cards Issued Difference](https://datalemur.com/questions/cards-issued-difference) 

Solution - 
    
       SELECT card_name, max(issued_amount) - min(issued_amount) as difference
       FROM monthly_cards_issued 
       group by card_name 
       order by card_name desc;
---
**Question 16 :** [SQL- Compressed Mean](https://datalemur.com/questions/alibaba-compressed-mean) 

Solution - 
    
       with result as (
       SELECT sum(item_count* order_occurrences) as Total_Items, sum(order_occurrences) as Total_orders 
       FROM items_per_order
       )select  ROUND(total_items::NUMERIC / total_orders, 1) as mean from result 
---
**Question 17 :** [SQL- Pharmacy Analytics (Part 1)](https://datalemur.com/questions/top-profitable-drugs) 

Solution - 
    
       SELECT drug, (total_sales - cogs) as total_profit 
       FROM pharmacy_sales 
       order by (total_sales - cogs) desc 
       limit 3; 
**Question 18 :** [SQL- Pharmacy Analytics (Part 2)](https://datalemur.com/questions/non-profitable-drugs) 

Solution - 
    
       SELECT manufacturer, count(drug) as drug_count, abs(sum(total_sales - cogs)) as total_loss
       FROM pharmacy_sales where total_sales - cogs < 0 group by manufacturer
       order by total_loss desc;
---
**Question 19 :** [SQL- Pharmacy Analytics (Part 3)](https://datalemur.com/questions/total-drugs-sales) 

Solution - 
    
       WITH drug_sales AS (
       SELECT manufacturer, SUM(total_sales) as sales FROM pharmacy_sales 
       GROUP BY manufacturer
       ) 
        SELECT manufacturer, ('$' || ROUND(sales / 1000000) || ' million') AS sales_mil 
        FROM drug_sales 
        ORDER BY sales DESC, manufacturer;
---
**Question 20 :** [SQL- Patient Support Analysis (Part 1)](https://datalemur.com/questions/frequent-callers) 

Solution - 
    
      with result as(
       SELECT distinct(count(policy_holder_id)) as policy_count, policy_holder_id 
       FROM callers 
       group by policy_holder_id
       )select count(policy_count) as policy_holder_count from result where policy_count >=3;
---
**Question 21 :** [SQL- User's Third Transaction)](https://datalemur.com/questions/sql-third-transaction) 

Solution - 
    
      with result AS(
      SELECT  user_id, spend, transaction_date, row_number() over(partition by user_id order by transaction_date) as no 
      FROM transactions
      ) select user_id, spend, transaction_date from result where no = 3;
---
**Question 22 :** [SQL- Second Highest Salary)](https://datalemur.com/questions/sql-second-highest-salary) 

Solution - 
    
      with result AS(
      SELECT *, dense_rank() over(order by salary desc) as ra FROM employee
      )
      select salary as second_highest_salary from result where ra =2;
---

**Question 23 :** [SQL- Sending vs. Opening Snaps)](https://datalemur.com/questions/time-spent-snaps) 

Solution - 
    
      SELECT age.age_bucket, ROUND(100.0 * SUM(activities.time_spent) FILTER (WHERE activities.activity_type = 'send')/SUM(activities.time_spent),2) AS send_perc, 
      ROUND(100.0 * SUM(activities.time_spent) FILTER (WHERE activities.activity_type = 'open')/SUM(activities.time_spent),2) AS open_perc FROM activities
      INNER JOIN age_breakdown AS age ON activities.user_id = age.user_id 
      WHERE activities.activity_type IN ('send', 'open') 
      GROUP BY age.age_bucket;
---
**Question 24 :** [SQL- Tweets' Rolling Averages)](https://datalemur.com/questions/rolling-average-tweets) 

Solution - 
    
       SELECT user_id, tweet_date, 
       round(avg(tweet_count) over (partition by user_id order by tweet_date rows between 2 PRECEDING and CURRENT ROW), 2) as rolling_avg_3d
       FROM tweets;
---
**Question 25 :** [SQL- Highest-Grossing Items)](https://datalemur.com/questions/sql-highest-grossing) 

Solution - 
    
       WITH result AS (
       SELECT category, product, SUM(spend) AS total_spend, ROW_NUMBER() OVER(PARTITION BY category ORDER BY SUM(spend) DESC, product) AS ro1 
       FROM product_spend 
       WHERE transaction_date BETWEEN '2022-01-01 00:00:00' AND '2022-12-31 23:59:59'
       GROUP BY category, product
       )
       SELECT category, product, total_spend FROM result 
       WHERE ro1 IN (1, 2)
       ORDER BY category;
---
**Question 26 :** [SQL- Top Three Salaries)](https://datalemur.com/questions/sql-top-three-salaries) 

Solution - 
        
        with result AS(
        SELECT department_name, name, salary, dense_rank() over (partition by department_name order by salary desc ) as ra 
        FROM employee e left join department d on e.department_id = d.department_id
        ) select department_name, name, salary from result where ra <=3;

---
**Question 27 :** [SQL- Signup Activation Rate)](https://datalemur.com/questions/signup-confirmation-rate) 

Solution - 
        
        SELECT * FROM emails
        LEFT JOIN texts
        ON emails.email_id = texts.email_id and texts.signup_action = 'Confirmed';

---
**Question 28 :** [SQL- Supercloud Customer)](https://datalemur.com/questions/supercloud-customer) 

Solution - 
        
        with result as 
        (
        select row_number() over(partition by customer_id, product_category order by customer_id) as ro,
        customer_id, product_category from customer_contracts cc left join products p on cc.product_id =p.product_id
        )select customer_id from result where ro =1 group by customer_id having count(ro) >=3;

---
**Question 28 :** [SQL- Odd and Even Measurements)](https://datalemur.com/questions/odd-even-measurements) 

Solution - 
        
        With result AS
        (
        SELECT CAST(measurement_time AS DATE) AS measurement_day,  measurement_value, ROW_NUMBER() OVER(partition by CAST(measurement_time AS DATE)  order by              measurement_time) as measurement_number 
        FROM measurements
        )select measurement_day,sum(case when measurement_number%2 <>0 then measurement_value else 0 end) as odd_sum, 
        sum(case when measurement_number%2 =0 then measurement_value else 0 end) as even_sum 
        from result 
        group by measurement_day;

---
**Question 29 :** [SQL- Swapped Food Delivery)](https://datalemur.com/questions/sql-swapped-food-delivery) 

Solution - 
        
        select order_id, case when (order_id% 2<>0) then 
				              case 
					          when order_id < count(order_id) over() then (select item from orders as T2 where T2.order_id = orders.order_id +1)
					          when order_id = count(order_id) over() then (select item from orders as T2 where T2.order_id = orders.order_id) 
				              end 
			              else (select item from orders  as T2 where T2.order_id = orders.order_id -1)
			              end AS item
		from orders ;

---
**Question 29 :** [SQL- FAANG Stock Min-Max (Part 1))](https://datalemur.com/questions/sql-bloomberg-stock-min-max-1) 

Solution - 
        
        select order_id, case when (order_id% 2<>0) then 
				              case 
					          when order_id < count(order_id) over() then (select item from orders as T2 where T2.order_id = orders.order_id +1)
					          when order_id = count(order_id) over() then (select item from orders as T2 where T2.order_id = orders.order_id) 
				              end 
			              else (select item from orders  as T2 where T2.order_id = orders.order_id -1)
			              end AS item
		from orders ;

  ---
  **Question 30 :** [SQL- User Shopping Sprees)](https://datalemur.com/questions/amazon-shopping-spree) 

Solution - 
        
        SELECT DISTINCT T1.user_id FROM transactions AS T1 
        INNER JOIN transactions AS T2 ON DATE(T2.transaction_date) = DATE(T1.transaction_date) + 1
        INNER JOIN transactions AS T3 ON DATE(T3.transaction_date) = DATE(T1.transaction_date) + 2 
        ORDER BY T1.user_id;

---
 **Question 31 :** [SQL- Histogram of Users and Purchases)](https://datalemur.com/questions/histogram-users-purchases) 

Solution - 
      
       with result AS(
       SELECT row_number() over(partition by user_id order by transaction_date desc) as row_no, count(user_id) as purchase_count, user_id, transaction_date 
       FROM user_transactions 
       group by transaction_date, user_id 
       order by transaction_date desc
       )select transaction_date, user_id, purchase_count from result 
       where row_no =1 
       order by transaction_date, purchase_count;

---
 **Question 32 :** [SQL- Compressed Mode)](https://datalemur.com/questions/alibaba-compressed-mode) 

Solution - 
       
       with result AS(
       SELECT item_count, order_occurrences,
       dense_rank() over (order by order_occurrences desc) as rankno
       FROM items_per_order
       ) select item_count as mode from result where rankno =1 order by item_count ;

---
**Question 33 :** [SQL- Card Launch Success)](https://datalemur.com/questions/card-launch-success) 

Solution - 
       
       with result AS(
       SELECT *, row_number() over(partition by card_name order by issue_year, issue_month) as number 
       FROM monthly_cards_issued
       )
       select card_name, issued_amount 
       from result 
       where number =1 
       order by issued_amount desc;

---
**Question 34 :** [SQL- Patient Support Analysis (Part 2))](https://datalemur.com/questions/uncategorized-calls-percentage) 

Solution - 
      
      SELECT round(100.0 * sum(case when call_category is null or call_category = 'n/a' or call_category =' ' then 1 end)/count(*),1) as uncategorised_call_pct
      FROM callers ;

---
**Question 35 :** [SQL- Active User Retention)](https://datalemur.com/questions/user-retention) 

Solution - 
      
      SELECT date_part('month', event_date:: DATE) as month, count(user_id) as monthly_active_users FROM user_actions  
      where (event_date >= '06/01/2022 12:00:00' and event_date <='07/31/2022 12:00:00') AND event_type IN ('sign-in', 'like','comment') 
      group by date_part('month', event_date:: DATE), user_id 
      order by user_id;




