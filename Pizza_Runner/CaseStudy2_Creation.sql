------------------------------------------------------Creation Queries & Data Cleaning---------------------------------------------------------------------------------------------
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

  ALTER TABLE customer_orders
  ALTER COLUMN exclusions varchar(20);

 Update customer_orders
 set exclusions = NULL
 where exclusions is NULL or exclusions = '' or exclusions = 'null'

 ALTER TABLE customer_orders
  ALTER COLUMN extras varchar(20);

 Update customer_orders
 set extras = NULL---- try using case as well; can be done togetherv. come back
 where extras is NULL or extras = '' or extras = 'null'

  --- To check the data Types of the columns 
 SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'customer_orders'


drop table if exists runner_orders;
  CREATE TABLE runner_orders (
  order_id INT PRIMARY KEY,
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


alter table runner_orders
alter column distance float;

alter table runner_orders
alter column duration float;

  CREATE TABLE pizza_names (
  pizza_id INT,
  pizza_name TEXT
);

INSERT INTO pizza_names
  (pizza_id, pizza_name)
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');

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

  CREATE TABLE runner_ratings (
    rating_id INT PRIMARY KEY IDENTITY(1,1),     
    order_id INT NOT NULL,                        
    rating INT CHECK (rating BETWEEN 1 AND 5),    
    FOREIGN KEY (order_id) REFERENCES runner_orders(order_id),
);

INSERT INTO runner_ratings (order_id,  rating)
SELECT 
    order_id,
    FLOOR(RAND(CHECKSUM(NEWID())) * 5) + 1  -- SQL Server: random rating between 1 and 5
FROM runner_orders
WHERE pickup_time IS NOT NULL;
