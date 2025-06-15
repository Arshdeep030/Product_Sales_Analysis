SHOW tables;

use datawarehouseanalytics;
select * from dim_customers;
select * from dim_products;
select * from fact_sales;

-- Retrieve a list of unique countries from which customers originate
select distinct country from dim_customers
order by country;

-- Retrieve a list of unique categories, subcategories, and products
select distinct category,subcategory, product_name from dim_products;

-- Determine the last and first order date and the total duration in months
SELECT 
  MAX(order_date) AS last_order_date, 
  MIN(order_date) AS first_order_date,
  TIMESTAMPDIFF(MONTH, MIN(order_date), MAX(order_date)) AS order_range_in_months
FROM fact_sales;

-- Find the youngest and oldest customer based on birthdate
select max(birthdate) as youngest_birth,
      timestampdiff(year, max(birthdate),curdate()) as youngest_age,
      min(birthdate) as oldest_birth,
      timestampdiff(year,min(birthdate),curdate()) as oldest_age
from dim_customers;
      
-- Find Total Sales
select sum(sales_amount) as total_sales from fact_sales;

-- Find how many items are sold
select sum(quantity) as items_sold from fact_sales;

-- Find the average selling price
select round(avg(price),2) as avg_selling_price from fact_sales;

-- Find the Total number of Orders
select count(order_number) as total_number from fact_sales;
select count(distinct order_number) as total_number from fact_sales;

-- Find the total number of products
select count(product_name) as total_number from dim_products;

-- Find the total number of customers
select count(customer_key) as total_number from dim_customers;

-- Find the total number of customers that has placed an order
select count(distinct customer_key) as total_number from dim_customers;

-- Generate a Report that shows all key metrics of the business
SELECT 'Total Sales' AS measure_name, SUM(sales_amount) AS measure_value FROM fact_sales
UNION ALL
SELECT 'Total Quantity', SUM(quantity) FROM fact_sales
UNION ALL
SELECT 'Average Price', AVG(price) FROM fact_sales
UNION ALL
SELECT 'Total Orders', COUNT(DISTINCT order_number) FROM fact_sales
UNION ALL
SELECT 'Total Products', COUNT(DISTINCT product_name) FROM dim_products
UNION ALL
SELECT 'Total Customers', COUNT(customer_key) FROM dim_customers;


-- Find total customers by countries
select country, count(customer_key) as total_customers from dim_customers
group by country
order by count(customer_key) desc;

-- Find total products by category
select category, count(product_key) as total_products from dim_products 
group by category
order by count(product_key) desc;

-- What is the average costs in each category?
select category, round(avg(cost),2) from dim_products
group by category
order by round(avg(cost),2) desc;

-- What is the total revenue generated for each category?
select p.category, sum(f.sales_amount) as revenue from dim_products as p
left join fact_sales as f on
p.product_key = f.product_key
group by p.category
order by revenue desc;

-- What is the distribution of sold items across countries?
SELECT
    c.country,
    SUM(f.quantity) AS total_sold_items
FROM fact_sales f
LEFT JOIN dim_customers c
    ON c.customer_key = f.customer_key
GROUP BY c.country
ORDER BY total_sold_items DESC;

-- Which 5 products Generating the Highest Revenue?
select p.product_name, sum(f.sales_amount) as revenue from fact_sales as f
left join dim_products p on p.product_key = f.product_key 
group by p.product_name 
order by revenue desc
limit 5;

-- Complex but Flexibly Ranking Using Window Functions
select * from 
      (select p.product_name, sum(f.sales_amount) as revenue,
      rank() over (order by sum(f.sales_amount) desc) AS rank_products
      from fact_sales f left join dim_products p 
      on f.product_key = p.product_key
      group by p.product_name
) rank_products
where rank_products <= 5;
      
-- What are the 5 worst-performing products in terms of sales?
select p.product_name, sum(f.sales_amount) as revenue from fact_sales as f
left join dim_products p on p.product_key = f.product_key 
group by p.product_name 
order by revenue asc
limit 5;

-- Find the top 10 customers who have generated the highest revenue
select * from 
    ( select c.customer_key,c.first_name, sum(f.sales_amount) as highest_revenue,
      rank() over (order by sum(f.sales_amount) desc ) as rank_customers
      from fact_sales f left join dim_customers c on
      f.customer_key = c.customer_key
      where c.customer_key is not null
      group by c.customer_key, c.first_name 
      ) rank_customers
      where rank_customers <= 10;
      
-- The 3 customers with the fewest orders placed
select  c.customer_key,c.first_name, count(distinct f.order_number) as order_placed
 from fact_sales f left join dim_customers c 
 on f.customer_key = c.customer_key 
 group by c.customer_key, c.first_name
 order by count(distinct f.order_number) asc
 limit 3;

-- Extract Order year and order month & total sales 
select year(order_date) as order_year, month(order_date) as order_month, sum(sales_amount) as total_sales,
       count(distinct customer_key) as total_customers, sum(quantity) as total_quantity
       from fact_sales
       where order_date is not null
       group by order_year,order_month
       order by order_year,order_month;
 
-- FORMAT()
SELECT
    FORMAT(order_date, 'yyyy-MMM') AS order_date,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity
FROM fact_sales
WHERE order_date IS NOT NULL
GROUP BY FORMAT(order_date, 'yyyy-MMM')
ORDER BY FORMAT(order_date, 'yyyy-MMM');

-- Calculate the total sales per month 
-- and the running total of sales over time 
SELECT 
  STR_TO_DATE(year_str, '%Y-%m-%d') AS order_date,
  total_sales,
  SUM(total_sales) OVER (ORDER BY STR_TO_DATE(year_str, '%Y-%m-%d')) AS running_total_sales,
  AVG(avg_price) OVER (ORDER BY STR_TO_DATE(year_str, '%Y-%m-%d')) AS moving_average_price
FROM (
    SELECT 
      CONCAT(DATE_FORMAT(order_date, '%Y'), '-01-01') AS year_str,
      SUM(sales_amount) AS total_sales,
      AVG(price) AS avg_price
    FROM fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY year_str
) t;

/* Analyze the yearly performance of products by comparing their sales 
to both the average sales performance of the product and the previous year's sales */
WITH yearly_product_sales AS (
    SELECT
        YEAR(f.order_date) AS order_year,
        p.product_name,
        SUM(f.sales_amount) AS current_sales
    FROM fact_sales f
    LEFT JOIN dim_products p
        ON f.product_key = p.product_key
    WHERE f.order_date IS NOT NULL
    GROUP BY 
        YEAR(f.order_date),
        p.product_name
)
SELECT
    order_year,
    product_name,
    current_sales,
    AVG(current_sales) OVER (PARTITION BY product_name) AS avg_sales,
    current_sales - AVG(current_sales) OVER (PARTITION BY product_name) AS diff_avg,
    CASE 
        WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) > 0 THEN 'Above Avg'
        WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) < 0 THEN 'Below Avg'
        ELSE 'Avg'
    END AS avg_change,
    -- Year-over-Year Analysis
    LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS py_sales,
    current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS diff_py,
    CASE 
        WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increase'
        WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) < 0 THEN 'Decrease'
        ELSE 'No Change'
    END AS py_change
FROM yearly_product_sales
ORDER BY product_name, order_year;


/*Segment products into cost ranges and count how many products fall into each segment*/
WITH product_segments AS (
    SELECT
        product_key, product_name, cost,
        CASE 
            WHEN cost < 100 THEN 'Below 100'
            WHEN cost BETWEEN 100 AND 500 THEN '100-500'
            WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
            ELSE 'Above 1000'
        END AS cost_range
    FROM dim_products
)
SELECT 
    cost_range,
    COUNT(product_key) AS total_products
FROM product_segments
GROUP BY cost_range
ORDER BY total_products DESC;

/*Group customers into three segments based on their spending behavior:
	- VIP: Customers with at least 12 months of history and spending more than €5,000.
	- Regular: Customers with at least 12 months of history but spending €5,000 or less.
	- New: Customers with a lifespan less than 12 months.
And find the total number of customers by each group
*/
WITH customer_spending AS (
    SELECT
        c.customer_key,
        SUM(f.sales_amount) AS total_spending,
        MIN(order_date) AS first_order,
        MAX(order_date) AS last_order,
        TIMESTAMPDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan
    FROM fact_sales f
    LEFT JOIN dim_customers c
        ON f.customer_key = c.customer_key
    GROUP BY c.customer_key
)
SELECT 
    customer_segment,
    COUNT(customer_key) AS total_customers
FROM (
    SELECT 
        customer_key,
        CASE 
            WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP'
            WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'Regular'
            ELSE 'New'
        END AS customer_segment
    FROM customer_spending
) AS segmented_customers
GROUP BY customer_segment
ORDER BY total_customers DESC;

-- Which categories contribute the most to overall sales?
with category_sales as (
     select p.category, sum(f.sales_amount) as total_sales from fact_sales f
     left join dim_products p on p.product_key = f.product_key 
     group by p.category )
select
      category,total_sales, sum(total_sales) over () as overall_sales,
      ROUND((CAST(total_sales AS FLOAT) / SUM(total_sales) OVER ()) * 100, 2) AS percentage_of_total
from category_sales
order by total_sales desc;


/*
===============================================================================
Customer Report
===============================================================================
Purpose:
    - This report consolidates key customer metrics and behaviors

Highlights:
    1. Gathers essential fields such as names, ages, and transaction details.
	2. Segments customers into categories (VIP, Regular, New) and age groups.
    3. Aggregates customer-level metrics:
	   - total orders
	   - total sales
	   - total quantity purchased
	   - total products
	   - lifespan (in months)
    4. Calculates valuable KPIs:
	    - recency (months since last order)
		- average order value
		- average monthly spend
===============================================================================
*/

-- Drop view if it exists
DROP VIEW IF EXISTS gold_report_customers;

-- Create view
CREATE VIEW gold_report_customers AS

WITH base_query AS (
    SELECT
        f.order_number,
        f.product_key,
        f.order_date,
        f.sales_amount,
        f.quantity,
        c.customer_key,
        c.customer_number,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        TIMESTAMPDIFF(YEAR, c.birthdate, CURRENT_DATE) AS age
    FROM fact_sales f
    LEFT JOIN dim_customers c ON c.customer_key = f.customer_key
    WHERE f.order_date IS NOT NULL
),

customer_aggregation AS (
    SELECT 
        customer_key,
        customer_number,
        customer_name,
        age,
        COUNT(DISTINCT order_number) AS total_orders,
        SUM(sales_amount) AS total_sales,
        SUM(quantity) AS total_quantity,
        COUNT(DISTINCT product_key) AS total_products,
        MAX(order_date) AS last_order_date,
        TIMESTAMPDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan
    FROM base_query
    GROUP BY 
        customer_key,
        customer_number,
        customer_name,
        age
)

SELECT
    customer_key,
    customer_number,
    customer_name,
    age,
    CASE 
        WHEN age < 20 THEN 'Under 20'
        WHEN age BETWEEN 20 AND 29 THEN '20-29'
        WHEN age BETWEEN 30 AND 39 THEN '30-39'
        WHEN age BETWEEN 40 AND 49 THEN '40-49'
        ELSE '50 and above'
    END AS age_group,
    
    CASE 
        WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
        WHEN lifespan >= 12 AND total_sales <= 5000 THEN 'Regular'
        ELSE 'New'
    END AS customer_segment,
    
    last_order_date,
    TIMESTAMPDIFF(MONTH, last_order_date, CURRENT_DATE) AS recency,
    total_orders,
    total_sales,
    total_quantity,
    total_products,
    lifespan,
    
    -- Average Order Value (AVO)
    CASE WHEN total_orders = 0 THEN 0
         ELSE total_sales / total_orders
    END AS avg_order_value,
    
    -- Average Monthly Spend
    CASE WHEN lifespan = 0 THEN total_sales
         ELSE total_sales / lifespan
    END AS avg_monthly_spend

FROM customer_aggregation;

SELECT * FROM gold_report_customers;


/*
===============================================================================
Product Report
===============================================================================
Purpose:
    - This report consolidates key product metrics and behaviors.

Highlights:
    1. Gathers essential fields such as product name, category, subcategory, and cost.
    2. Segments products by revenue to identify High-Performers, Mid-Range, or Low-Performers.
    3. Aggregates product-level metrics:
       - total orders
       - total sales
       - total quantity sold
       - total customers (unique)
       - lifespan (in months)
    4. Calculates valuable KPIs:
       - recency (months since last sale)
       - average order revenue (AOR)
       - average monthly revenue
===============================================================================
*/

-- Drop the view if it already exists
DROP VIEW IF EXISTS gold_report_products;

-- Create the view
CREATE VIEW gold_report_products AS

WITH base_query AS (
    SELECT
        f.order_number,
        f.order_date,
        f.customer_key,
        f.sales_amount,
        f.quantity,
        p.product_key,
        p.product_name,
        p.category,
        p.subcategory,
        p.cost
    FROM fact_sales f
    LEFT JOIN dim_products p ON f.product_key = p.product_key
    WHERE f.order_date IS NOT NULL
),

product_aggregations AS (
    SELECT
        product_key,
        product_name,
        category,
        subcategory,
        cost,
        TIMESTAMPDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan,
        MAX(order_date) AS last_sale_date,
        COUNT(DISTINCT order_number) AS total_orders,
        COUNT(DISTINCT customer_key) AS total_customers,
        SUM(sales_amount) AS total_sales,
        SUM(quantity) AS total_quantity,
        ROUND(AVG(IFNULL(sales_amount / NULLIF(quantity, 0), 0)), 1) AS avg_selling_price
    FROM base_query
    GROUP BY
        product_key,
        product_name,
        category,
        subcategory,
        cost
)

SELECT 
    product_key,
    product_name,
    category,
    subcategory,
    cost,
    last_sale_date,
    TIMESTAMPDIFF(MONTH, last_sale_date, CURRENT_DATE()) AS recency_in_months,
    
    CASE
        WHEN total_sales > 50000 THEN 'High-Performer'
        WHEN total_sales >= 10000 THEN 'Mid-Range'
        ELSE 'Low-Performer'
    END AS product_segment,
    
    lifespan,
    total_orders,
    total_sales,
    total_quantity,
    total_customers,
    avg_selling_price,

    -- Average Order Revenue (AOR)
    CASE 
        WHEN total_orders = 0 THEN 0
        ELSE ROUND(total_sales / total_orders, 2)
    END AS avg_order_revenue,

    -- Average Monthly Revenue
    CASE
        WHEN lifespan = 0 THEN total_sales
        ELSE ROUND(total_sales / lifespan, 2)
    END AS avg_monthly_revenue

FROM product_aggregations;

SELECT * FROM gold_report_products;


