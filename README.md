# 🧮 Retail Sales Data Analysis with SQL

## 📌 Project Overview

This project performs a comprehensive analysis of a retail sales dataset using SQL. The goal is to derive valuable business insights by answering a broad range of exploratory, performance, product-based, customer-based, and time-series questions. 

The dataset includes information such as customer demographics, product details, transaction amounts, and order history.

---

## 🛠️ Tech Stack

- **Database**: MySQL / PostgreSQL (compatible with both)
- **Language**: SQL (including advanced features like window functions, CTEs, CASE statements)
- **Tools**: Any SQL IDE (MySQL Workbench, DBeaver, pgAdmin, etc.)

---

## 📂 Dataset Summary

The dataset contains tables such as:

- `customers`: Customer ID, Name, Birthdate, Country
- `orders`: Order ID, Order Date, Customer ID
- `products`: Product ID, Category, Subcategory, Product Name, Price
- `order_items`: Order ID, Product ID, Quantity, Revenue


## Questions Answered in This Project

Below is a categorized list of questions tackled during this analysis:


### Exploratory Analysis

| # | Question |
|--|----------|
| 1 | What are the unique countries in which our customers reside? |
| 2 | What are all the available product categories, subcategories, and products? |
| 3 | When did the first and last order occur, and what is the total span (in months)? |
| 4 | Who is the youngest and oldest customer based on birthdate? |
| 5 | How many total sales were made and how many items were sold? |
| 6 | What is the average selling price across all transactions? |
| 7 | How many total and distinct orders have been placed? |
| 8 | What is the total number of customers and how many of them placed an order? |


### Business Performance Summary

| # | Question |
|--|----------|
| 9 | What are the core KPIs for business performance (total sales, quantity, avg price, total orders, etc.)? |
| 10 | Which countries have the highest number of customers? |
| 11 | Which product categories have the most products listed? |
| 12 | What is the average cost of products in each category? |
| 13 | Which categories are contributing the most to total sales? |
| 14 | What is the revenue distribution by country and by product? |


### Product Performance

| # | Question |
|--|----------|
| 15 | Which 5 products are generating the highest revenue? |
| 16 | Which 5 products are the worst performers based on revenue? |
| 17 | How are products performing over time — are they improving or declining? |
| 18 | How many products fall into different cost segments (e.g., <100, 100–500, etc.)? |
| 19 | What product segments exist based on sales performance (High-Performer, Mid-Range, Low-Performer)? |
| 20 | What are the average order revenue and monthly revenue per product? |


### Customer Segmentation

| # | Question |
|--|----------|
| 21 | How do we segment customers as VIP, Regular, or New based on spending and history? |
| 22 | How many customers fall into each customer segment? |
| 23 | Who are the top 10 customers by revenue? |
| 24 | Who are the 3 customers with the fewest number of orders? |
| 25 | What are the age groups of our customer base? |


### Time-Based & Trend Analysis

| # | Question |
|--|----------|
| 26 | How does sales volume and customer activity vary by year and month? |
| 27 | What is the monthly sales trend along with running totals and moving averages? |
| 28 | How do product sales perform year-over-year? |
| 29 | What is the change in product sales compared to their average and prior year performance? |


## Reporting & Techniques Used

| # | Question |
|--|---------|
| 30 | The **Customer Report** provides insights into customer demographics, sales behavior, and spending segmentation. |
| 31 | The **Product Report** highlights key product performance indicators such as sales, quantity, recency, and average revenue per month. |
| 32 | Using window functions (e.g., `RANK()`, `LAG()`, `AVG() OVER`) gives deeper insights into comparative and temporal analytics. |
| 33 | Conditional segmentation (`CASE WHEN`) is effectively used for classifying customers and products into meaningful categories. |
| 34 | The structure of using CTEs (Common Table Expressions) before aggregation improves readability and maintainability of complex queries. |

