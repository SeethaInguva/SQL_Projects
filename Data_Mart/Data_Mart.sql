CREATE TABLE weekly_sales (
  week_date varchar(10), 
  region VARCHAR(13),
  platform VARCHAR(7),
  segment VARCHAR(4),
  customer_type VARCHAR(8),
  transactions INTEGER,
  sales INTEGER
);

BULK INSERT weekly_sales
FROM 'C:\Users\inguv\PycharmProjects\PythonProject\output.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 1,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);
------------------------------------------------------Cleaned table creation--------------------------------------------------------------
SELECT 
    CAST(week_date AS DATE) AS week_date,
      DATEPART(WEEK, week_date) AS week_number,
    MONTH(CAST(week_date AS DATE)) as month_number,
    YEAR(CAST(week_date AS DATE)) as calendar_year, 
    region,
    platform,
    segment,
    case 
        when segment is NULL or segment = 'null' then 'unknown'
        when TRY_CAST(right(segment,1) AS INT) = 1 then 'Young Adults'
        when TRY_CAST(right(segment,1) AS INT) = 2 then 'Middle Aged'
        when TRY_CAST(right(segment,1) AS INT) = 3 or TRY_CAST(right(segment,1) AS INT) = 4 then 'Retirees'
        else 'unknown'
    end as age_band,
    case 
        when segment is NULL or segment = 'null' then 'unknown'
        when left(segment,1) = 'C' then 'Couples'
        when left(segment,1) = 'F' then 'Families'
        else 'unknown'
    end as demographic,
    customer_type, 
    transactions,
    sales,
    sales/transactions as avg_transaction
INTO clean_weekly_sales
FROM weekly_sales;


----------------------------------------2. Data Exploration----------------------------------------------------
--What day of the week is used for each week_date value?
select week_date, 
format(week_date, 'dddd') 
from clean_weekly_sales

--What range of week numbers are missing from the dataset?
with all_weeks as 
(
select top 52 ROW_NUMBER() over (order by (select null)) as week_number from sys.all_objects
), 
weeks_present as
(
 select distinct week_number from clean_weekly_sales
)
select aw.week_number as weeks_missing from all_weeks aw left join weeks_present wp on aw.week_number = wp.week_number
where wp.week_number is NULL 
order by wp.week_number
--How many total transactions were there for each year in the dataset?
select calendar_year, sum(transactions) as Total_Transactions from clean_weekly_sales group by calendar_year
--What is the total sales for each region for each month?
select region, 
month_number, 
sum(CAST(sales as bigint))
from clean_weekly_sales 
group by region, month_number
order by month_number, region
--What is the total count of transactions for each platform
select platform, 
count(transactions) as [Platform wise - Total Transactions]
from clean_weekly_sales 
group by platform;
--What is the percentage of sales for Retail vs Shopify for each month?
with platform_sales as
(
select sum(cast(case when platform = 'Retail' then sales end as bigint)) as Retail_Sales,
sum(cast(case when platform = 'Shopify' then sales  end as bigint)) as Shopify_Sales, month_number 
from  clean_weekly_sales 
group by month_number
)
select cast(Retail_Sales*100.0/(Retail_Sales+Shopify_Sales) as decimal(5,2)) as Retail_Percentage, 
cast(Shopify_Sales*100.0/(Retail_Sales+Shopify_Sales) as decimal (5,2)) as Shopify_Percentage 
from platform_sales;

--What is the percentage of sales by demographic for each year in the dataset?
with  demographic_sales as
(
Select calendar_year, 
sum(cast(case when demographic='Couples' then sales end as bigint)) as Couples_Sales,
sum(cast(case when demographic='Families' then sales end as bigint)) as Families_Sales 
from clean_weekly_sales 
group by calendar_year
)
select cast(Couples_Sales*100.0/(Couples_Sales+Families_Sales) as decimal(5,2)) as Couples_Percentage,
cast(Families_Sales*100.0/(Families_Sales+Families_Sales) as decimal(5,2)) as Couples_Percentage
from demographic_sales;

--Which age_band and demographic values contribute the most to Retail sales?
SELECT top 1 demographic, SUM(CAST(sales AS BIGINT)) AS total_sales
FROM clean_weekly_sales
WHERE platform = 'Retail' and age_band <> 'unknown'
GROUP BY demographic
ORDER BY total_sales DESC;

SELECT top 1 age_band, SUM(CAST(sales AS BIGINT)) AS total_sales
FROM clean_weekly_sales
WHERE platform = 'Retail' and age_band <> 'unknown'
GROUP BY age_band
ORDER BY total_sales DESC;

--Can we use the avg_transaction column to find the average transaction size for each year for Retail 
--vs Shopify? If not - how would you calculate it instead?
SELECT 
calendar_year, 
platform,
ROUND(CAST(SUM(CAST(sales AS BIGINT)) AS FLOAT) / NULLIF(SUM(CAST(transactions AS BIGINT)), 0),2) AS avg_transaction_size
FROM clean_weekly_sales 
GROUP BY calendar_year, platform 
ORDER BY calendar_year, platform;


select * from clean_weekly_sales;

--This technique is usually used when we inspect an important event and want to inspect the impact before and after a certain point
--in time.Taking the week_date value of 2020-06-15 as the baseline week where the Data Mart sustainable packaging changes came into
--effect. We would include all week_date values for 2020-06-15 as the start of the period after the change and the previous week_date
--values would be before Using this analysis approach - answer the following questions:





--What is the total sales for the 4 weeks before and after 2020-06-15?
--What is the growth or reduction rate in actual values and percentage of sales?
with before_sales as
(
select sum(cast(sales as bigint)) as sales_before from clean_weekly_sales 
where week_date > DATEADD(DAY, -28, '2020-06-15') and week_date <= '2020-06-15' 
), 
after_sales as
(
select sum(cast(sales as bigint)) as sales_after from clean_weekly_sales 
where week_date > '2020-06-15' and week_date <= DATEADD(DAY, 28, '2020-06-15')
) select sales_before, sales_after, (sales_after- sales_before) as difference, 
round((sales_after- sales_before) * 100.0 / NULLIF(sales_before, 0),2) AS percentage_change
    from before_sales  CROSS JOIN after_sales;

--What about the entire 12 weeks before and after?
with before_sales as
(
select sum(cast(sales as bigint)) as sales_before from clean_weekly_sales 
where week_date > DATEADD(DAY, -84, '2020-06-15') and week_date < '2020-06-15' 
), 
after_sales as
(
select sum(cast(sales as bigint)) as sales_after from clean_weekly_sales 
where week_date >='2020-06-15' and week_date < DATEADD(DAY, 84, '2020-06-15')

) select sales_before, sales_after, (sales_after- sales_before) as difference, 
round(( sales_after- sales_before) * 100.0 / NULLIF(sales_before, 0),2) AS percentage_change
    from before_sales  CROSS JOIN after_sales;

   --How do the sale metrics for these 2 periods before and after compare with the previous years in 2018 and 2019?
   WITH sales_periods AS (
    SELECT
        datepart(year, cast(week_date as date)) AS sales_year,
        week_date,
        sales,
        CASE 
            WHEN week_date BETWEEN '2018-03-26' AND '2018-06-17' THEN 'Before'
            WHEN week_date BETWEEN '2018-06-18' AND '2018-09-09' THEN 'After'
            WHEN week_date BETWEEN '2019-03-25' AND '2019-06-16' THEN 'Before'
            WHEN week_date BETWEEN '2019-06-17' AND '2019-09-08' THEN 'After'
            WHEN week_date BETWEEN '2020-03-23' AND '2020-06-14' THEN 'Before'
            WHEN week_date BETWEEN '2020-06-15' AND '2020-09-06' THEN 'After'
            ELSE NULL
        END AS period
    FROM clean_weekly_sales
    WHERE week_date BETWEEN '2018-03-26' AND '2020-09-06'
)
SELECT 
    sales_year,
    period,
    SUM(CAST(sales AS BIGINT)) AS total_sales,
    ROUND(AVG(CAST(sales AS FLOAT)), 2) AS avg_weekly_sales
FROM sales_periods
WHERE period IS NOT NULL
GROUP BY sales_year, period
ORDER BY sales_year, period;