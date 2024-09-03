# SuperStore-Analysis-Portfolio-Project
# Project Overview
In today's competitive retail landscape, businesses must continuously adapt to shifting consumer preferences and market dynamics. This project centers on Superstore, a fictional retail giant, aiming to provide actionable insights by analyzing its profit performance data from 2014 to 2017. Through an in-depth analysis of customer behavior, product performance, market and profit trends, this analysis identifies key performance indicators (KPIs) and uncovers patterns that significantly impact profitability. The goal is to offer data-driven recommendations that support the Superstore’s strategic decision-making and long-term growth focused on profit optimization.
# Objective
The primary objective of this project is to optimize profit which is achieved through detailed analysis of different aspects of the superstore data set to give data driven recommendation.
# Tools used
**SQL** (PostgreSQL):  data analysis.  **[You can Check my SQL queries here!!](superstore_data_analysis_project.sql)**

**Power BI**: Used for visualizing insights with interactive dashboards. **[You can Check my Power BI pdf here!!](superstore_analysis.pdf)**
# Data Description
The Superstore dataset is publicly available through Kaggle website as one CSV file, it’s a comprehensive collection of sales data from 2014-01-13 to 2017-12-28 consisting of 8000 rows including headers and 21 columns which are: 

Row ID, Order ID, Order Date, Ship Date, Ship Mode, Customer ID , Customer Name, Segment, Country, City, State, Postal Code, Region, Product ID, Category, Sub-Category, Product Name, Sales, Quantity, Discount, Profit.
# Data Loading and Pre-Processing
The dataset was initially provided as a CSV file. To facilitate analysis, I created a PostgreSQL database named ‘SuperStore’ and within this database, I established a table titled ‘superstore’. The data from the CSV file was then imported into this table. Subsequent to the import, I executed a query to verify the successful import of the data, which appeared to be clean and well-structured. To ensure data integrity, I performed additional checks for duplicates and null values.
# The Analysis
We will begin by performing an exploratory data analysis (EDA) on the Superstore dataset. This involves answering a set of important questions through SQL queries, with each query followed by its result. After completing the analysis, we will move on to building a dashboard that presents the most significant findings, providing actionable insights to solve the business problem. 
### A) Overview Analysis
In this section, the analysis focuses on identifying and understanding profit trends over the period from 2014 to 2017.

 1.	What is superstore total sales and profit for the four years?
```sql 
SELECT 
	ROUND(SUM(sales),2) AS total_sales,
	ROUND(SUM(profit),2) AS total_profit
 FROM superstore;
```
| Total Sales  | Total Profit |
|--------------|--------------|
| 1,838,587.67 | 225,073.86   |
2.	What is our profit margin? 
```sql
SELECT 
ROUND((SUM(profit)/ SUM(sales))*100,2)AS profit_margin
FROM superstore;
```
| Profit Margin |
|---------------|
| 12.24%        |

 The company's profit margin of 12.24% shows that the business is moderately profitable. For every $100 in sales, the company earns approximately $12.24 in profit. While this indicates healthy profitability, it might suggest that there could be room for improvement. 
### B) Trend Analysis
3.	What is our year over year growth?
``` sql
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
```
| Year | Total Sales | Total Profit | Previous Year Sales | Previous Year Profit | Sales Growth (%) | Profit Growth (%) |
|------|-------------|--------------|---------------------|----------------------|------------------|-------------------|
| 2014 | 410,701.40  | 43,807.45    | 0                   | 0                    | 0.00             | 0.00              |
| 2015 | 372,506.53  | 51,005.25    | 410,701.40          | 43,807.45            | -9.30            | 16.43             |
| 2016 | 468,985.32  | 59,842.38    | 372,506.53          | 51,005.25            | 25.90            | 17.33             |
| 2017 | 586,394.42  | 70,418.78    | 468,985.32          | 59,842.38            | 25.03            | 17.67             |

The query shows that in 2015, even though sales dropped by 9.3% compared to the previous year, profit grew significantly by 16.43%. This indicates that the business improved its cost management, which helped maintain profitability despite lower revenue. In the following years, 2016 and 2017, sales rebounded strongly with growth rates of 25.9% and 25.03%, respectively, and profit continued to rise by over 17% each year.

4.	What are our total sales and profit per quarter?
```sql
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
```
| Quarter | Total Sales | Total Profit |
|---------|-------------|--------------|
| Q1      | 264,067.49  | 35,229.01    |
| Q2      | 350,964.51  | 45,176.48    |
| Q3      | 510,586.81  | 61,842.47    |
| Q4      | 712,968.87  | 82,825.91    |

- **Q4 (October - December):** Consistently the strongest quarter each year.

5.	What are our total sales and profit per month?
```sql
SELECT 
	EXTRACT(month FROM order_date) as month, 
	ROUND(SUM(sales),2) AS total_sales,
	ROUND(SUM(profit),2) AS total_profit
 FROM superstore 
 GROUP BY month
 ORDER BY month;
 ```
 | Month | Total Sales | Total Profit |
|-------|-------------|--------------|
| 1     | 64,486.04   | 9,249.93     |
| 2     | 40,227.11   | 6,864.42     |
| 3     | 159,354.33  | 19,114.65    |
| 4     | 117,387.16  | 9,631.30     |
| 5     | 123,847.08  | 20,922.80    |
| 6     | 109,730.26  | 14,622.37    |
| 7     | 125,531.71  | 16,134.94    |
| 8     | 128,571.18  | 17,566.33    |
| 9     | 256,483.92  | 28,141.20    |
| 10    | 162,768.39  | 26,319.62    |
| 11    | 285,587.12  | 26,348.58    |
| 12    | 264,613.35  | 30,157.71    |

- **Highest Sales and Profit Months:**: September, November, and December
- **Lowest Performance Month:** February.

6.	What are our highest and lowest profitable days?
```sql
-- Sales and profit per day for all years
SELECT	
	TO_CHAR(order_date,'Day') AS days, 
	ROUND(SUM(sales)) AS total_sales,
	ROUND(SUM(profit)) AS total_profit
 FROM superstore 
 GROUP BY days
 ORDER BY total_profit DESC;
 ```
 | Day       | Total Sales | Total Profit |
|-----------|-------------|--------------|
| Sunday    | 323,946     | 49,823       |
| Monday    | 348,992     | 43,132       |
| Friday    | 343,482     | 36,557       |
| Saturday  | 297,711     | 35,128       |
| Tuesday   | 225,439     | 24,157       |
| Thursday  | 233,088     | 23,737       |
| Wednesday | 65,930      | 12,541       |

- **Sunday** is the most profitable day.
- **Wednesday** is the least profitable day.

### C) Regional Analysis
This part include analyzing regions and states profit.

7.	Which regions generate the highest profit?
```sql
SELECT 
	region,
	ROUND(SUM(sales),2) AS total_sales,
	ROUND(SUM(profit),2) AS total_profit,
	ROUND((SUM(profit)/ SUM(sales))*100,2)AS profit_margin
FROM superstore
GROUP BY region
ORDER BY total_profit DESC;
```
| Region  | Total Sales | Total Profit | Profit Margin |
|---------|-------------|--------------|---------------|
| West    | 574,871.57  | 79,739.36    | 13.87         |
| East    | 551,176.30  | 72,473.65    | 13.15         |
| South   | 317,934.81  | 38,766.37    | 12.19         |
| Central | 394,604.98  | 34,094.49    | 8.64          |

The West region excels in both sales and profit, with the highest profit margin of 13.87%, indicating superior efficiency in converting sales into profit. In contrast, the Central region, despite strong sales, has the lowest profit margin at 8.64%, making it the least efficient in profitability.

8.	What are the top 5 most profitable states?
```sql
SELECT 
	state,
	ROUND(SUM(sales),2) AS total_sales,
	ROUND(SUM(profit),2) AS total_profit,
	ROUND((SUM(profit)/ SUM(sales))*100,2)AS profit_margin
FROM superstore
GROUP BY state
ORDER BY total_profit DESC
LIMIT 5;
```
| State       | Total Sales | Total Profit | Profit Margin |
|-------------|-------------|--------------|---------------|
| California  | 359,678.19  | 59,671.63    | 16.59         |
| New York    | 248,234.16  | 58,475.69    | 23.56         |
| Washington  | 99,237.30   | 21,411.25    | 21.58         |
| Michigan    | 59,824.55   | 17,742.37    | 29.66         |
| Indiana     | 45,155.12   | 16,373.26    | 36.26         |

- **California:** has the Highest profit.
- **Indiana:** is in the fifth place with the highest profit margin indicating strong posibility for growth.

9.	What are the top 5 states with the lowest profits?
```sql 
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
```
| State         | Total Sales | Total Profit | Profit Margin |
|---------------|-------------|--------------|---------------|
| Texas         | 127,608.54  | -17,096.23   | -13.40        |
| Ohio          | 65,354.54   | -15,753.59   | -24.10        |
| Pennsylvania  | 93,430.97   | -12,890.56   | -13.80        |
| Illinois      | 64,135.61   | -10,716.34   | -16.71        |
| Colorado      | 30,430.85   | -6,592.44    | -21.66        |

- **Texas:** is the highest state in generating profit losses.

### D) Category and product Analysis

In this section, we will conduct an analysis of the various categories within the superstore, focusing on identifying the most profitable products as well as those that are underperforming. Our goal is to gain insights into the performance of different product categories to inform strategic decisions moving forward.

10. What is the total number and total quantity of our products?
```sql
SELECT 
	COUNT(distinct product_id) AS no_of_products,
	SUM(quantity) AS total_quantity
FROM superstore;
```

| Number of Products | Total Quantity |
|--------------------|----------------|
| 1,831              | 30,295         |

11.	How many products categories and sub-categories do we have?
```sql
SELECT 
	COUNT(DISTINCT category) AS no_categories,
	COUNT(DISTINCT sub_category) AS no_sub_categories
FROM superstore;
```
| Number of Categories | Number of Sub-Categories |
|----------------------|--------------------------|
| 3                    | 17                       |

12.	 What is the percentage distribution of different categories in terms of sales and profit?
```sql 
SELECT 
	category,
	ROUND((SUM(sales)/(SELECT SUM(sales) FROM superstore))*100,2) AS percentage_of_sales,
	ROUND((SUM(profit)/(SELECT SUM(profit) FROM superstore))*100,2) AS percentage_of_profit
FROM superstore
GROUP BY category
ORDER BY percentage_of_profit DESC;
```
| Category         | Percentage of Sales | Percentage of Profit |
|------------------|----------------------|----------------------|
| Technology       | 36.97                | 49.51                |
| Office Supplies  | 31.05                | 42.99                |
| Furniture        | 31.97                | 7.50                 |

The Technology category leads with the highest percentage of both sales and profit, making it the strongest performer among the three categories. Office Supplies follows closely behind. While the Furniture category accounts for a slightly higher sales percentage than Office Supplies, it struggles with a much lower profit percentage, indicating inefficiency in converting sales into profit.

13.	What are our sub-categories’ performance?
```sql 
SELECT  
	sub_category,
	ROUND(SUM(sales),2) AS total_sales,
	ROUND(SUM(profit),2) AS total_profit
FROM superstore
GROUP BY sub_category
ORDER BY total_profit DESC;
```
| Sub-Category | Total Sales | Total Profit |
|--------------|-------------|--------------|
| Copiers      | 119,148.40  | 43,747.94    |
| Phones       | 267,838.33  | 36,534.32    |
| Accessories  | 133,812.17  | 34,178.39    |
| Paper        | 64,098.00   | 27,916.97    |
| Chairs       | 264,689.17  | 22,956.24    |
| Binders      | 146,508.36  | 20,775.34    |
| Storage      | 179,766.53  | 17,622.59    |
| Appliances   | 87,090.60   | 14,819.75    |
| Furnishings  | 72,994.71   | 10,851.42    |
| Envelopes    | 14,332.51   | 6,119.92     |
| Art          | 21,913.11   | 5,243.79     |
| Labels        | 10,540.86   | 4,685.54     |
| Fasteners    | 2,508.55    | 818.60       |
| Supplies     | 44,201.81   | -1,239.67    |
| Machines     | 159,003.28  | -3,024.86    |
| Bookcases    | 87,723.11   | -3,539.48    |
| Tables       | 162,418.17  | -13,392.94   |

Among our 17 sub-categories, Copiers, Phones, Accessories, and Paper are the top performers. Conversely, Supplies, Machines, Bookcases, and Tables are at the lower end of our list, showing negative profits despite their high sales volumes, especially tables. 

16.	What are the top 5 performing categories with their corresponding  sub-categories in each state?
```sql
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
```
| State      | Category    | Sub-Category | Total Sales | Total Profit |
|------------|-------------|--------------|-------------|--------------|
| New York   | Technology  | Machines     | 37,503.90   | 14,821.74    |
| New York   | Technology  | Phones       | 38,645.39   | 10,568.60    |
| Indiana    | Technology  | Copiers      | 18,499.93   | 8,849.97     |
| California | Technology  | Accessories  | 28,711.22   | 8,426.55     |
| California | Technology  | Copiers      | 20,799.60   | 6,722.88     |

- **Machines and phones:** are top subcategories in New York.
- **Copiers:** in Indiana.
- **Accessories and Copiers:** in California.

17.	What are the top 5 underperforming categories with their corresponding  sub-categories in each city?
```sql
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
```
| State           | Category        | Sub-Category | Total Sales | Total Profit |
|-----------------|------------------|--------------|-------------|--------------|
| Ohio            | Technology       | Machines     | 8,651.31    | -11,534.60   |
| Texas           | Office Supplies  | Binders      | 5,709.60    | -9,235.01    |
| Illinois        | Office Supplies  | Binders      | 3,962.16    | -6,216.01    |
| North Carolina  | Technology       | Machines     | 12,620.66   | -5,384.81    |
| Texas           | Office Supplies  | Appliances   | 1,935.77    | -4,920.22    |

- **Ohio and Texas:** have the highest losses in Machines and binders respectively. 

18.	What are our top 5 performing products?
```sql
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
```
| Product Name                                                    | Category    | Sub-Category | Total Sales | Total Profit |
|-----------------------------------------------------------------|-------------|--------------|-------------|--------------|
| Canon imageCLASS 2200 Advanced Copier                          | Technology  | Copiers      | 47,599.86   | 18,479.95    |
| Hewlett Packard LaserJet 3310 Copier                           | Technology  | Copiers      | 17,039.72   | 6,743.89     |
| Ativa V4110MDD Micro-Cut Shredder                              | Technology  | Machines     | 7,699.89    | 3,772.95     |
| 3D Systems Cube Printer, 2nd Generation, Magenta                | Technology  | Machines     | 14,299.89   | 3,717.97     |
| Plantronics Savi W720 Multi-Device Wireless Headset System     | Technology  | Accessories  | 9,367.29    | 3,696.28     |

19. What are our top 5 underperforming products? 
```sql
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
```
| Product Name                                                | Category    | Sub-Category | Total Sales | Total Profit |
|-------------------------------------------------------------|-------------|--------------|-------------|--------------|
| Cubify CubeX 3D Printer Double Head Print                  | Technology  | Machines     | 11,099.96   | -8,879.97    |
| Lexmark MX611dhe Monochrome Laser Printer                 | Technology  | Machines     | 16,829.90   | -4,589.97    |
| Cubify CubeX 3D Printer Triple Head Print                  | Technology  | Machines     | 7,999.98    | -3,839.99    |
| Bush Advantage Collection Racetrack Conference Table        | Furniture   | Tables       | 5,217.78    | -2,087.11    |
| Cisco TelePresence System EX90 Videoconferencing Unit     | Technology  | Machines     | 22,638.48   | -1,811.08    |

### E) Customer Analysis
This section delves into a comprehensive analysis of our customer base, exploring key demographics in addition to our top performing customers.

20.	 What is the total number of customers? 
```sql
SELECT 
	COUNT (DISTINCT customer_id) AS total_customer
FROM superstore;
```
| Total Customers |
|-----------------|
| 784             |

We have 784 total customers, reflecting those who purchased at least once across the four-year period.

21.	What is the number of customers per region??
```sql 
SELECT 
	region,
	COUNT(DISTINCT customer_id) AS number_of_customers
FROM superstore
GROUP BY region
ORDER BY number_of_customers DESC;
```
| Region  | Number of Customers |
|---------|----------------------|
| West    |       637                  |
| East    | 601                  |
| Central | 559                  |
| South   | 446                  |
- **The West:** has the highest number of customers followed by East, Central, and South.

The previous query revealed that the total number of unique customers is 784. This suggests that if we sum up the number of customers in each region, the total will likely exceed 784. This conflict may indicate that some customers placed orders from different regions. We can confirm this hypothesis with the following query.

```sql
SELECT 
		DISTINCT customer_id,
		COUNT(DISTINCT region) AS no_regions,
		COUNT(DISTINCT city) AS no_cities
FROM superstore
GROUP BY customer_id
HAVING COUNT(DISTINCT region) >1
LIMIT 5; 
```
| Customer ID | No. of Regions | No. of Cities |
|-------------|----------------|---------------|
| AA-10315    | 3              | 4             |
| AA-10375    | 4              | 8             |
| AA-10480    | 3              | 4             |
| AA-10645    | 3              | 4             |
| AB-10060    | 3              | 6             |
We were right, most of our unique customers made orders from different regions and cities across the four years.

22.	What are the  cities with the highest number of customers?
```sql 
SELECT 
	state,
	COUNT(DISTINCT customer_id) AS number_of_customers
FROM superstore
GROUP BY state
ORDER BY number_of_customers DESC
LIMIT 5;
```
| State          | Number of Customers |
|----------------|----------------------|
| California     | 514                  |
| New York       | 354                  |
| Texas          | 308                  |
| Pennsylvania   | 206                  |
| Illinois       | 189                  |
- **California** has the highest number of customers.

23.	Which segment of customers is the most profitable?
```sql
-- Top performing customer segments
SELECT 
	segment,
	COUNT(DISTINCT customer_id) AS number_of_customers,
	ROUND(SUM(sales),2) AS total_sales,
	ROUND(SUM(profit),2) AS total_profit
FROM superstore
GROUP BY segment
ORDER BY total_profit DESC;
```
| Segment     | Number of Customers | Total Sales | Total Profit |
|-------------|----------------------|-------------|--------------|
| Consumer    | 406                  | 906,473.10  | 103,683.14   |
| Corporate   | 234                  | 564,515.34  | 69,434.18    |
| Home Office | 144                  | 367,599.24  | 51,956.55    |

- **Consumer Segment** has the highest number of customers and profit.
- **Home Office** comes at last.

24.	  Who are our top customers?
```sql 
SELECT 
	customer_id,
	ROUND(SUM(sales),2) AS total_sales,
	ROUND(SUM(profit),2) AS total_profit
FROM superstore
GROUP BY customer_id
ORDER BY total_profit DESC
LIMIT 5;
```
| Customer ID | Total Sales | Total Profit |
|-------------|-------------|--------------|
| TC-20980    | 18,444.45   | 8,747.62     |
| HL-15040    | 12,873.30   | 5,622.43     |
| SC-20095    | 12,037.79   | 4,881.14     |
| TA-21385    | 14,588.58   | 4,701.75     |
| CM-12385    | 6,922.63    | 3,214.27     |

27.	What is the total number of orders?  
```sql 
SELECT
	COUNT(DISTINCT order_id) AS total_orders
FROM superstore;
```
| Total Orders |
|--------------|
| 3962         |

28.	 What is the total number of orders per year?  
```sql
SELECT
	EXTRACT(year FROM order_date) as year,
	COUNT(DISTINCT order_id) AS total_orders
FROM superstore
GROUP BY year;
```
| Year | Total Orders |
|------|--------------|
| 2014 | 763          |
| 2015 | 824          |
| 2016 | 1034         |
| 2017 | 1341         |

We can see that the highest number of orders was in 2017 followed by 2016 which means that we have an increase in number of orders every year.

### F) Shipping Analysis
In this section, we will analyze shipping modes and their profitability, along with the delivery times associated with each mode.

29. What is our most profitable ship mode?

```sql 
SELECT
	ship_mode,
	COUNT(order_id) AS total_number_orders,
	ROUND(SUM(sales),2) AS total_sales,
	ROUND(SUM(profit),2) AS total_profit
FROM superstore
GROUP BY ship_mode
ORDER BY total_profit DESC;
```
| Ship Mode      | Total Number of Orders | Total Sales  | Total Profit |
|----------------|-------------------------|--------------|--------------|
| Standard Class | 4788                    | 1,088,294.09 | 134,441.49   |
| Second Class   | 1565                    | 379,063.37   | 47,263.14    |
| First Class    | 1220                    | 267,161.45   | 33,120.07    |
| Same Day       | 427                     | 104,068.77   | 10,249.17    |

The Standard Class shipping mode stands out as the most utilized and profitable, generating the highest total sales and profit. Second Class and First-Class modes also contribute well, but with fewer orders, indicating a balance between faster shipping preferences and profitability. Same Day shipping, despite being the least used, still generates a respectable profit, possibly due to premium pricing.

30.	What is the average shipping time per class?
```sql
SELECT 
	ship_mode,
    ROUND(AVG(ship_date - order_date),1) AS avg_shipping_time
FROM superstore
GROUP BY ship_mode
ORDER BY avg_shipping_time;
```
| Ship Mode      | Avg Shipping Time |
|----------------|--------------------|
| Same Day       | 0.0                |
| First Class    | 2.2                |
| Second Class   | 3.2                |
| Standard Class | 5.0                |

Same Day shipping has an average shipping time of 0 days, which is expected, but it's the least used option despite its speed. First Class and Second-Class shipping offer relatively quick delivery times (2.2 and 3.2 days, respectively) and Standard Class has the longest average shipping time of 5 days and is the most utilized and profitable.

# Recommendations
- Prioritize marketing, promotions, stock management, and customer service during Q4 (October - December), given its high profitability. Consider including September due to its strong performance. 
- Leverage Sunday’s high profitability with exclusive deals or promotions. Investigate the lower profitability on Wednesday and explore strategies to boost sales on this day.
- Consider maintaining or increasing market share on the West, East, and South regions, which are already generating strong profits while addressing the lower profits  margin (8.64%) on the central region by identifying inefficiencies and deciding on potential market exit or improvement.
- For top states focus on maximizing market potential in high profitable states such as Calefornia, New York , Washington, Michigan, and Indiana While for underperforming states Implement strategic interventions or consider exiting markets with significant losses, such as Texas, Ohio, Pennsylvania, Illinois,and Colorado.
- Technology is our top performing category, so we need to keep stock and follow the market trend with evolving new technology products with high demand to keep it highly profitable as it is. On the other hand, furniture category is the last in terms of profit, we need to understand why its products is not performing well whether it’s a shift in customer preferences or products quality or weak marketing and solve the issue in order to make it more profitable. 
- Copiers, Phones, Accessories, and Paper these are our top performing subcategories so, we need to watch for their stock, increase their marketing and make competitive market strategies to boost their performance. While Supplies, Machines, Bookcases, and Tables are generating losses especially tables, so we need to conduct a thorough review of pricing, cost structures, and sales strategies and to identify the root causes of negative profits to improve their performance or to consider phasing out these products.
- Focus on maintaining inventory and promoting high-profit items like Canon imageCLASS 2200 and HP LaserJet 3310.
- consider discontinuing low-performing products like Cubify CubeX 3D Printers and Lexmark MX611dhe.
- Prioritize the most profitable Consumer segment while targeting growth opportunities in the Corporate and Home Office segments.
- Optimize Standard Class shipping mode operations and explore premium shipping options like Same Day and First Class to drive overall profitability.
- Consider rewarding our top performing customers.
# What I Learned
- Advanced SQL Querying: Gained proficiency in complex SQL functions and data extraction techniques.
- Data Analysis Techniques: Improved ability to analyze profit trends and sales.
- Data Visualization with Power BI: Enhanced skills in creating interactive and effective visual dashboards.
- Critical Thinking and Problem Solving: Strengthened ability to interpret data and provide actionable insights.
- Project Documentation and Presentation: Learned to document my project using GitHub.
