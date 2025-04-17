
**Company Name: Twitter**

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
**Company Name: LinkedIn**

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
 **Company Name: Facebook**

**Question 3 :** [SQL- Page With No Likes](https://datalemur.com/questions/sql-page-with-no-likes) 

Solution - 
    
    SELECT page_id from pages where page_id not in (select page_id from page_likes)
    order by page_id;
---
 **Company Name: Tesla**

**Question 4 :** [SQL- Unfinished Parts](https://datalemur.com/questions/tesla-unfinished-parts) 

Solution - 
    
    SELECT part, assembly_step FROM parts_assembly where finish_date is null;
  ---
   **Company Name: NY Times**

**Question 4 :** [SQL- Laptop vs. Mobile Viewership](https://datalemur.com/questions/laptop-mobile-viewership) 

Solution - 
    
    SELECT sum(case 
               when device_type = 'laptop' then 1
               end) as laptop_views,
        sum(case 
               when device_type = 'tablet' or device_type = 'phone' then 1
               end) as mobile_views 
        from viewership;
  ---

            







