-- Checking for the data 
SELECT *
FROM superstore
LIMIT 5;

-- Total number of records
SELECT COUNT(*) AS Total_no_of_records
 FROM superstore;

-- Checking For Duplicates
SELECT row_id, COUNT(*)
FROM superstore
GROUP BY row_id
HAVING COUNT(*) > 1;

-- Checking for null values.
SELECT 
 SUM(CASE WHEN row_id IS NULL THEN 1 ELSE 0 END) as rowID_null_counting,
 SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) as orderID_null_counting,
 SUM(CASE WHEN order_date IS NULL THEN 1 ELSE 0 END) as orderDate_null_counting,
 SUM(CASE WHEN ship_date IS NULL THEN 1 ELSE 0 END) as shipDate_null_counting,
 SUM(CASE WHEN ship_mode IS NULL THEN 1 ELSE 0 END) as ship_mode_null_counting,
 SUM(CASE WHEN customer IS NULL THEN 1 ELSE 0 END) as customer_null_counting,
 SUM(CASE WHEN customer_name IS NULL THEN 1 ELSE 0 END) as customerName_null_counting,
 SUM(CASE WHEN segment IS NULL THEN 1 ELSE 0 END) as segment_null_counting,
 SUM(CASE WHEN country IS NULL THEN 1 ELSE 0 END) as country_null_counting,
 SUM(CASE WHEN city IS NULL THEN 1 ELSE 0 END) as city_null_counting,
 SUM(CASE WHEN state IS NULL THEN 1 ELSE 0 END) as state_null_counting,
 SUM(CASE WHEN postal_code IS NULL THEN 1 ELSE 0 END) as orderID_null_counting,
 SUM(CASE WHEN region IS NULL THEN 1 ELSE 0 END) as region_null_counting,
 SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) as productID_null_counting,
 SUM(CASE WHEN category IS NULL THEN 1 ELSE 0 END) as category_null_counting,
 SUM(CASE WHEN sub_category IS NULL THEN 1 ELSE 0 END) as subCategory_null_counting,
 SUM(CASE WHEN product_name IS NULL THEN 1 ELSE 0 END) as product_name_null_counting,
 SUM(CASE WHEN sales IS NULL THEN 1 ELSE 0 END) as sales_null_counting,
 SUM(CASE WHEN quantity IS NULL THEN 1 ELSE 0 END) as quantity_null_counting,
 SUM(CASE WHEN discount IS NULL THEN 1 ELSE 0 END) as discount_null_counting,
 SUM(CASE WHEN profit IS NULL THEN 1 ELSE 0 END) as profit_null_counting
FROM superstore;

-- A) Analysis for all years
-- Sales and Profit Analysis

-- Total Sales and Profit for All Years (2014 - 2017)
SELECT 
	ROUND(SUM(sales),2) AS total_sales,
	ROUND(SUM(profit),2) AS total_profit
 FROM superstore;

-- Profit Margin
SELECT 
ROUND((SUM(profit)/ SUM(sales))*100,2)AS profit_margin
FROM superstore;
	
-- Year Over Year Sales and profit Growth
WITH total_sales_profit	AS
	(
	SELECT 
		EXTRACT(year FROM order_date) AS year,
		ROUND(SUM(sales),2) AS total_sales,
		ROUND(SUM(profit),2) AS total_profit	
	FROM superstore
    GROUP BY year
    ORDER BY year
	),
	
previous_year AS (
	SELECT 
		year,
	 	total_sales,
		total_profit,
		LAG(total_sales) OVER(ORDER BY year) as previous_year_sales,
		LAG(total_profit) OVER(ORDER BY year) as previous_year_profit
	FROM total_sales_profit
),
yoy_growth AS
	(
	SELECT
		year,
		total_sales,
		total_profit,
	    COALESCE(previous_year_sales,0) AS previous_year_sales,
		COALESCE(previous_year_profit,0) AS previous_year_profit,
	    COALESCE(ROUND(((total_sales - previous_year_sales)/ previous_year_sales)*100,2),0) AS sales_growth_percent,
		COALESCE(ROUND(((total_profit - previous_year_profit)/previous_year_profit)*100,2),0) AS profit_growth_percent
	FROM previous_year
	)
SELECT *
from yoy_growth;


-- Total Sales and Profit per quarter for all years
SELECT 
	CASE 
	WHEN EXTRACT(quarter FROM order_date) = 1 THEN 'Q1' 
	WHEN EXTRACT(quarter FROM order_date) = 2 THEN 'Q2'
	WHEN EXTRACT(quarter FROM order_date) = 3 THEN 'Q3'
	ELSE 'Q4' END AS quarter,
	ROUND(SUM(sales),2) AS total_sales,
	ROUND(SUM(profit),2) AS total_profit
FROM superstore
GROUP BY quarter
ORDER BY quarter;

-- Sales and Profit per quarter for each year
SELECT 
    EXTRACT(year FROM order_date) AS year,  
    CASE 
	WHEN EXTRACT(quarter FROM order_date) = 1 THEN 'Q1' 
	WHEN EXTRACT(quarter FROM order_date) = 2 THEN 'Q2'
	WHEN EXTRACT(quarter FROM order_date) = 3 THEN 'Q3'
	ELSE 'Q4' END AS quarter,
	ROUND(SUM(sales),2) AS total_sales,
	ROUND(SUM(profit),2) AS total_profit
FROM 
    superstore 
GROUP BY 
    year, quarter
ORDER BY 
    year ASC, quarter ASC;

-- Sales and profit per month for all years
SELECT 
	EXTRACT(month FROM order_date) as month, 
	ROUND(SUM(sales),2) AS total_sales,
	ROUND(SUM(profit),2) AS total_profit
 FROM superstore 
 GROUP BY month
 ORDER BY month;


-- Sales and profit per day for all years
SELECT	
	TO_CHAR(order_date,'Day') AS days, 
	ROUND(SUM(sales)) AS total_sales,
	ROUND(SUM(profit)) AS total_profit
 FROM superstore 
 GROUP BY days
 ORDER BY total_profit DESC;


-- TOP performing regions
SELECT 
	region,
	ROUND(SUM(sales),2) AS total_sales,
	ROUND(SUM(profit),2) AS total_profit,
	ROUND((SUM(profit)/ SUM(sales))*100,2)AS profit_margin
FROM superstore
GROUP BY region
ORDER BY total_profit DESC 

-- Top 5 performing states
SELECT 
	state,
	ROUND(SUM(sales),2) AS total_sales,
	ROUND(SUM(profit),2) AS total_profit,
	ROUND((SUM(profit)/ SUM(sales))*100,2)AS profit_margin
FROM superstore
GROUP BY state
ORDER BY total_profit DESC
LIMIT 5;

-- Top 5 underperforming states 
SELECT 
	state,
	ROUND(SUM(sales),2) AS total_sales,
	ROUND(SUM(profit),2) AS total_profit,
	ROUND((SUM(profit)/ SUM(sales))*100,2)AS profit_margin
FROM superstore
GROUP BY state
ORDER BY total_profit ASC
LIMIT 5;

-- B) Product and Categoris Analysis:

-- Number of Total Products and quantity sold
SELECT 
	COUNT(distinct product_id) AS no_of_products,
	SUM(quantity) AS total_quantity
FROM superstore;

-- Categories and Sub_categories
-- Number of categories and Sub_categories
SELECT 
	COUNT(DISTINCT category) AS no_categories,
	COUNT(DISTINCT sub_category) AS no_sub_categories
FROM superstore;

-- Percentage of Categories in Terms of  profit
SELECT 
	category,
	ROUND((SUM(sales)/(SELECT SUM(sales) FROM superstore))*100,2) AS percentage_of_sales,
	ROUND((SUM(profit)/(SELECT SUM(profit) FROM superstore))*100,2) AS percentage_of_profit
FROM superstore
GROUP BY category
ORDER BY percentage_of_profit DESC;
	
-- sub-categories performance
SELECT  
	sub_category,
	ROUND(SUM(sales),2) AS total_sales,
	ROUND(SUM(profit),2) AS total_profit
FROM superstore
GROUP BY sub_category
ORDER BY total_profit DESC;

-- Top Performing categories and sub-categories per State 
SELECT 
	state,
	category,
	sub_category,
	ROUND(SUM(sales),2) AS total_sales,
	ROUND(SUM(profit),2) AS total_profit
FROM superstore
GROUP BY sub_category,category ,state  
ORDER BY total_profit DESC
LIMIT 5;

-- Lowest Performing categories and sub-categories per State 
SELECT 
	state,
	category,
	sub_category,
	ROUND(SUM(sales),2) AS total_sales,
	ROUND(SUM(profit),2) AS total_profit
FROM superstore
GROUP BY category, sub_category,state  
ORDER BY total_profit ASC
LIMIT 5;

-- Top 5 Products in terms of total_sales and their profit
SELECT 
	product_name, 
	category,
	sub_category,
	ROUND(SUM(sales),2) AS total_sales,
	ROUND(SUM(profit),2) AS total_profit
FROM superstore
GROUP BY product_name, category, sub_category
ORDER BY total_profit DESC
LIMIT 5;


-- Top 5 underperforming Products in terms of total_profit and their sales
SELECT 
	product_name, 
	category,
	sub_category,
	ROUND(SUM(sales),2) AS total_sales,
	ROUND(SUM(profit),2) AS total_profit
FROM superstore
GROUP BY product_name, category, sub_category
ORDER BY total_profit ASC
LIMIT 5;


-- Top profitable products for each year in terms of profit
WITH products_profit AS
(
	SELECT 
		EXTRACT(year FROM order_date) AS year,
		product_name,
		SUM(profit) AS total_profit
	FROM superstore
	GROUP BY year, product_name
),

product_rank AS
(
	SELECT 
		products_profit.*,
		ROW_NUMBER() OVER(PARTITION BY year ORDER BY total_profit DESC) AS ranking
	FROM products_profit
)

	SELECT 
	    ranking,
	    MAX(CASE WHEN year = 2014 THEN product_name END) AS "2014",
	    MAX(CASE WHEN year = 2015 THEN product_name END) AS "2015",
	    MAX(CASE WHEN year = 2016 THEN product_name END) AS "2016",
	    MAX(CASE WHEN year = 2017 THEN product_name END) AS "2017"
FROM product_rank
WHERE ranking <= 10
GROUP BY ranking
ORDER BY ranking;

-- tables subcategory
SELECT 
	product_name,
	ROUND(SUM(profit),2) AS total_profit,
	ROUND((SUM(profit)/ SUM(sales))*100,2)AS profit_margin
FROM superstore
WHERE sub_category = 'Tables' 
GROUP BY product_name
HAVING SUM(CAST(profit AS decimal(10,2))) < 0
ORDER BY total_profit
LIMIT 5;

-- Machines Subcategory
SELECT 
	product_name,
	ROUND(SUM(profit),2) AS total_profit,
	ROUND((SUM(profit)/ SUM(sales))*100,2)AS profit_margin
FROM superstore
WHERE sub_category = 'Machines' 
GROUP BY product_name
HAVING SUM(CAST(profit AS decimal(10,2))) < 0
ORDER BY total_profit
LIMIT 5;

-- Supplies sub-category
SELECT 
	product_name,
	ROUND(SUM(profit),2) AS total_profit,
	ROUND((SUM(profit)/ SUM(sales))*100,2)AS profit_margin
FROM superstore
WHERE sub_category = 'Supplies' 
GROUP BY product_name
HAVING SUM(CAST(profit AS decimal(10,2))) < 0
ORDER BY total_profit
LIMIT 5;
	
-- Bookcases Sub-category
SELECT 
	product_name,
	ROUND(SUM(profit),2) AS total_profit,
	ROUND((SUM(profit)/ SUM(sales))*100,2)AS profit_margin
FROM superstore
WHERE sub_category = 'Bookcases' 
GROUP BY product_name
HAVING SUM(CAST(profit AS decimal(10,2))) < 0
ORDER BY total_profit
LIMIT 5;

-- E) Customer Analysis
-- Total number of customers
SELECT 
	COUNT (DISTINCT customer_id) AS total_customer
FROM superstore;

-- Number of customers per region
SELECT 
	region,
	COUNT(DISTINCT customer_id) AS number_of_customers
FROM superstore
GROUP BY region
ORDER BY number_of_customers DESC;

-- Unique Customers with corresponding number of regions and cities
SELECT 
		DISTINCT customer_id,
		COUNT(DISTINCT region) AS no_regions,
		COUNT(DISTINCT city) AS no_cities
FROM superstore
GROUP BY customer_id
HAVING COUNT(DISTINCT region) >1
LIMIT 5; 

-- states with highest number of customers
SELECT 
	state,
	COUNT(DISTINCT customer_id) AS number_of_customers
FROM superstore
GROUP BY state
ORDER BY number_of_customers DESC
LIMIT 5;

-- states with lowest number of customers
SELECT 
	state,
	COUNT(DISTINCT customer_id) AS number_of_customers
FROM superstore
GROUP BY state
ORDER BY number_of_customers ASC
LIMIT 15;

-- Top performing customer segments
SELECT 
	segment,
	COUNT(DISTINCT customer_id) AS number_of_customers,
	ROUND(SUM(sales),2) AS total_sales,
	ROUND(SUM(profit),2) AS total_profit
FROM superstore
GROUP BY segment
ORDER BY total_profit DESC;

-- Top performing Customers 
SELECT 
	customer_id,
	ROUND(SUM(sales),2) AS total_sales,
	ROUND(SUM(profit),2) AS total_profit
FROM superstore
GROUP BY customer_id
ORDER BY total_profit DESC
LIMIT 5;

-- Customers years activity
SELECT 
    customer_id,
    COUNT(DISTINCT EXTRACT(year FROM order_date)) AS years_active
FROM superstore
GROUP BY customer_id
LIMIT 15;

-- Total number of orders
SELECT
	COUNT(DISTINCT order_id) AS total_orders
FROM superstore;

-- Total orders for each year
SELECT
	EXTRACT(year FROM order_date) as year,
	COUNT(DISTINCT order_id) AS total_orders
FROM superstore
GROUP BY year;

-- Shipping analysis 
-- Profitability by shipping mode
SELECT
	ship_mode,
	COUNT(order_id) AS total_number_orders,
	ROUND(SUM(sales),2) AS total_sales,
	ROUND(SUM(profit),2) AS total_profit
FROM superstore
GROUP BY ship_mode
ORDER BY total_profit DESC;

-- Average shipping time per class
SELECT 
	ship_mode,
    ROUND(AVG(ship_date - order_date),1) AS avg_shipping_time
FROM superstore
GROUP BY ship_mode
ORDER BY avg_shipping_time;



