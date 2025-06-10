  --------------------------------------------------D. Outside The Box Questions--------------------------------------------------------
/*The following are open ended questions which might be asked during a technical interview for this case study - there are no right
or wrong answers, but answers that make sense from both a technical and a business perspective make an amazing impression!*/

--How would you calculate the rate of growth for Foodie-Fi?

--This query gives a sense of variance in monthly new customer acquisition, showing how much peak months difference by low months. 
With monthly_customers as (
    Select 
        format(start_date, 'yyyy-MM') AS month,
        count(distinct customer_id) AS customer_count
    from subscriptions
    where start_date BETWEEN '2020-01-01' AND '2020-12-31'
    group by format(start_date, 'yyyy-MM')
)
SELECT 
    ROUND(
        CAST(1.0 * (MAX(customer_count) - MIN(customer_count)) / NULLIF(MIN(customer_count), 0) AS DECIMAL(5, 2)) * 100,
    2) AS growth_rate_pct
FROM monthly_customers;

--What key metrics would you recommend Foodie-Fi management to track over time to assess performance of their overall business?
/*
1. New Subscribers per Month
2. Plan Conversion Rates
3. Churn Rate
4. Monthly Revenue
5. upgrade/downgrade rates for plans
6. Avg revenue for customer */

--What are some key customer journeys or experiences that you would analyse further to improve customer retention?

-- Trial to Paid Conversion, Upgrade and Downgrade Paths, Churn Timing, Inactivity before churn

/*If the Foodie-Fi team were to create an exit survey shown to customers who wish to cancel their subscription,
what questions would you include in the survey?*/

/*What’s the main reason you're cancelling?
How satisfied were you with Foodie-Fi?
What aspects should be improved to win you back? If so
Would you consider rejoining in the future?*/


--What business levers could the Foodie-Fi team use to reduce the customer churn rate? 
--How would you validate the effectiveness of your ideas?

/*Levers to reduce churn:
Offer a 'pause plan' option instead of full cancellation.
Send reminders before renewal with content personalized to users interests.
Introduce personalized discounts for users about to churn.

Validation:
A/B test each idea on different user segments.

Measure churn rate changes before and after implementation.*/