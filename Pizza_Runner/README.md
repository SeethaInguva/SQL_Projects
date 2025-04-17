# 🍕 Pizza Runner – Case Study 2 | #8WeekSQLChallenge

Welcome to **Case Study #2 – Pizza Runner**, part of the [#8WeekSQLChallenge](https://8weeksqlchallenge.com/case-study-2/) by Danny Ma!  
In this case study, I explored how a small delivery business operates, focusing on orders, runners, and performance metrics using SQL.

---

## 📌 Case Study Overview

**Pizza Runner** is a startup that coordinates pizza deliveries between customers and freelance runners.  
The goal was to create a well-structured database from raw data, clean and transform inconsistent fields, and answer analytical questions related to:

- Customer ordering behavior
- Delivery runner performance
- Business optimization insights

---

## 📂 What This Project Covers

### 🗂️ 1. Database Setup
- Created tables for:
  - `runners`
  - `customer_orders`
  - `runner_orders`
- Populated tables using provided raw datasets with inconsistencies.

### 🧹 2. Data Cleaning & Transformation
- Normalized data fields like:
  - `exclusions` and `extras` in customer orders
  - `distance` and `duration` in runner orders
- Standardized nulls, converted textual values, and adjusted column data types for analytical accuracy.

### 📊 3. Analytical Insights (Case Study Questions)
- Explored order counts per customer
- Assessed delivery timings and distances
- Analyzed cancellations and runner assignments
- Identified potential improvements in data handling and runner efficiency

> 🧠 **Fun Fact**: Some fields contained `'null'`, `''`, or inconsistent formatting (`'20km'`, `'32 minutes'`, etc.). I implemented conditional logic and casting to clean them effectively!

---

## 🛠️ Tools Used
- **SQL** (Structured Query Language)
- **Microsoft SQL Server** (you can adapt this to other RDBMS)
- **Subqueries, CTEs, CASE WHEN logic**, and **data type transformations**

---
## 🎯 Key Learnings

- Hands-on practice in **data wrangling** and **cleaning**
- Dealing with real-world messiness like inconsistent nulls, string formats, and duplicate data
- Writing **efficient SQL** to derive business insights
- Understanding **data transformation pipelines**

---

## 🧠 My Favorite Insight

> By converting vague fields like `'20km'` or `'15 minutes'` into structured numeric formats, I was able to compute average delivery distances and durations for each runner — helping the business identify who delivered fastest and most efficiently!

---

## 📎 Challenge Link

🔗 [8WeekSQLChallenge - Case Study 2](https://8weeksqlchallenge.com/case-study-2/)
