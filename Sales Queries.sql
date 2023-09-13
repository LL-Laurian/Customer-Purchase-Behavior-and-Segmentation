-- Load the sales data sample from Project1.sales_data_sample table
SELECT * FROM Project1.sales_data_sample;

-- Identify unique values in key columns for initial exploration
SELECT DISTINCT status FROM sales_data_sample; 
SELECT DISTINCT year_id FROM sales_data_sample;  
SELECT DISTINCT PRODUCTLINE FROM sales_data_sample; 
SELECT DISTINCT COUNTRY FROM sales_data_sample; 
SELECT DISTINCT DEALSIZE FROM sales_data_sample; 
SELECT DISTINCT TERRITORY FROM sales_data_sample; 

-- Select distinct months in 2003,2004,2005 for further analysis
SELECT DISTINCT MONTH_ID FROM sales_data_sample
WHERE year_id = 2003
ORDER BY month_id;

SELECT DISTINCT MONTH_ID FROM sales_data_sample
WHERE year_id = 2004
ORDER BY month_id;

SELECT DISTINCT MONTH_ID FROM sales_data_sample
WHERE year_id = 2005
ORDER BY month_id;

-- Analyze sales revenue by product line
SELECT
	productline,
    SUM(sales) AS revenue
FROM sales_data_sample
GROUP BY productline
ORDER BY revenue DESC;

-- Analyze sales revenue across years
SELECT
	year_id,
    SUM(sales) AS revenue
FROM sales_data_sample
GROUP BY year_id
ORDER BY revenue DESC; -- Identified a significant drop in sales in 2005 compared to other years

-- Analyze sales revenue by deal size (S/M/L)
SELECT
	dealsize,
    SUM(sales) AS revenue
FROM sales_data_sample
GROUP BY dealsize
ORDER BY revenue DESC;

-- Analyze the best sales month per year, including product line details
-- Create temporary tables for intermediate results
DROP TABLE IF EXISTS month_info;
DROP TABLE IF EXISTS max_revenue;
DROP TABLE IF EXISTS best_month;
DROP TABLE IF EXISTS month_productline;
DROP TABLE IF EXISTS best_productline_revenue;
DROP TABLE IF EXISTS best_productline;

-- Generate a table to contain each month's revenue and frequency
CREATE TEMPORARY TABLE month_info AS (
	SELECT
		year_id,
		month_id,
		SUM(sales) AS month_revenue,
        COUNT(ordernumber) AS month_frequency
	FROM sales_data_sample s
	GROUP BY month_id, year_id
);

-- Generate a table containing the highest month revenue every year
CREATE TEMPORARY TABLE max_revenue AS (
	SELECT 
		year_id,
		MAX(month_revenue) AS best_month_revenue
	FROM month_info
	GROUP BY year_id
);

-- Generate a table containing the month with the highest revenue and corresponding revenue
CREATE TEMPORARY TABLE best_month AS (
	SELECT
		max_revenue.year_id,
		c.month_id,
		max_revenue.best_month_revenue
	FROM max_revenue
	JOIN month_info c ON max_revenue.best_month_revenue = c.month_revenue AND c.year_id = max_revenue.year_id
);

-- Generate a table containing each month's product line and its revenue
CREATE TEMPORARY TABLE month_productline AS (
	SELECT
		year_id,
		month_id,
        productline AS month_productline,
		SUM(sales) AS productline_revenue
	FROM sales_data_sample 
	GROUP BY month_id, year_id, month_productline
);

-- Generate a table containing the highest product line revenue by month
CREATE TEMPORARY TABLE best_productline_revenue AS (
	SELECT 
		year_id,
        month_id,
        MAX(productline_revenue) AS best_productline_revenue
	FROM month_productline
	GROUP BY year_id, month_id
);

-- Generate a table containing the highest product line revenue by month, along with the product line
-- Joining best_month info together 
CREATE TEMPORARY TABLE best_productline AS (
	SELECT
		m.year_id,
        m.month_id,
        best_month_revenue,
        n.month_productline,
		m.best_productline_revenue
	FROM best_productline_revenue m
	JOIN month_productline n ON m.year_id = n.year_id AND m.month_id = m.month_id AND n.productline_revenue = m.best_productline_revenue
	JOIN best_month ON m.year_id = best_month.year_id AND m.month_id = best_month.month_id
);

-- Create a summary table with year revenue, highest month revenue of each year, and the highest product line of the corresponding highest month
SELECT 
	a.year_id,
    SUM(sales) AS year_revenue,
    SUM(ordernumber) AS year_frequency,
    detail_month_info.month_id,
    best_month_revenue,
    best_month_frequency,
    month_productline,
    best_productline_revenue
FROM sales_data_sample a
JOIN (
	SELECT 
		best_productline.year_id,
        best_productline.month_id,
        best_month_revenue,
        d.month_frequency AS best_month_frequency,
        month_productline,
        best_productline_revenue
	FROM best_productline
	JOIN month_info d ON d.year_id = best_productline.year_id AND d.month_id = best_productline.month_id
) detail_month_info ON a.year_id = detail_month_info.year_id
GROUP BY a.year_id, detail_month_info.best_month_revenue, detail_month_info.month_id, detail_month_info.best_month_frequency, detail_month_info.month_productline,
    detail_month_info.best_productline_revenue;

-- Convert the date format to SQL format
-- UPDATE sales_data_sample
-- SET orderdate = DATE_FORMAT(STR_TO_DATE(orderdate, '%m/%d/%Y %H:%i'), '%Y-%m-%d %H:%i');

-- Perform RFM Analysis to evaluate customer value and segmentation
-- Drop regular tables if they exist
DROP TABLE IF EXISTS final_rfm;
DROP TABLE IF EXISTS rfm;
DROP TABLE IF EXISTS rfm_calc;

-- Create a regular table for RFM analysis
CREATE TEMPORARY TABLE rfm AS (
    SELECT
        customername,
        SUM(sales) AS monetary_value,
        AVG(sales) AS average_monetary_value,
        COUNT(ordernumber) AS frequency,
        MAX(orderdate) AS last_order_date,
        (SELECT MAX(orderdate) FROM sales_data_sample) AS latest_date,
        DATEDIFF((SELECT MAX(orderdate) FROM sales_data_sample), MAX(orderdate)) AS recency 
    FROM sales_data_sample
    GROUP BY customername
);


-- RFM Analysis to evaluate if it is a valuable customer

-- Recency: How long ago their last purchase was (last order date)
-- Frequency: how often they purchase (count order)
-- Monetary Value: how much they spent (sales amount)


-- Calculate RFM values and insert into rfm_calc table
CREATE TEMPORARY TABLE rfm_calc AS (
    SELECT 
        r.*,
        NTILE(4) OVER (ORDER BY recency DESC) AS rfm_recency,
        NTILE(4) OVER (ORDER BY frequency) AS rfm_frequency,
        NTILE(4) OVER (ORDER BY monetary_value) AS rfm_monetary
    FROM rfm r
    -- ORDER BY 4 DESC
);

-- Create the temporary table with RFM segments
CREATE TEMPORARY TABLE final_rfm AS (
	SELECT 
		c.*,
		rfm_recency + rfm_frequency + rfm_monetary AS rfm_cell,
		CONCAT(CAST(rfm_recency AS CHAR), CAST(rfm_frequency AS CHAR), CAST(rfm_monetary AS CHAR)) AS rfm_cell_string
	FROM rfm_calc c
);
-- Query to select all rows from the final RFM table
SELECT * FROM final_rfm;

-- Query to select customer information along with RFM segments
SELECT 
    CUSTOMERNAME,
    rfm_recency,
    rfm_frequency,
    rfm_monetary,
    CASE 
        WHEN rfm_cell_string IN (111, 112, 121, 122, 123, 132, 211, 212, 114, 141) THEN 'lost_customers' -- Lost customers
        WHEN rfm_cell_string IN (133, 134, 143, 244, 334, 343, 344, 144) THEN 'slipping away, cannot lose' -- Big spenders who haven't purchased lately, slipping away
        WHEN rfm_cell_string IN (311, 411, 331) THEN 'new customers'
        WHEN rfm_cell_string IN (222, 223, 233, 322) THEN 'potential churners'
        WHEN rfm_cell_string IN (323, 333, 321, 422, 332, 432) THEN 'active' -- Customers who buy often & recently, but at low price points
        WHEN rfm_cell_string IN (433, 434, 443, 444) THEN 'loyal'
    END AS rfm_segment
FROM final_rfm;

-- Solve: What products are often sold together when customers buy two types of products?

-- Query to find products often sold together when customers buy two items
SELECT 
    order_item_code,
    COUNT(order_item_code) AS occurrence
FROM (
    -- Organize the order_item_codes from the ordernumber (these are for the ordernumbers that buy two items)
    SELECT 
        a.ordernumber,
        GROUP_CONCAT(a.productcode SEPARATOR ', ') AS order_item_code
    FROM Project1.sales_data_sample a
    WHERE a.ordernumber IN (
        SELECT ordernumber
        FROM (
            SELECT
                b.ordernumber,
                COUNT(b.ordernumber) AS quantity_ordertype
            FROM Project1.sales_data_sample b
            WHERE status = 'shipped'
            GROUP BY ordernumber
        ) m
        WHERE quantity_ordertype = 2
    )
    GROUP BY a.ordernumber
) order_details 
GROUP BY order_item_code 
ORDER BY occurrence DESC;

-- Solve: Which country contributes the most to sales?

-- Query to find the top countries and the corresponding top products contributing the most to sales in 2003
SELECT 
    year_id,
    country,
    SUM(sales) AS country_revenue
FROM Project1.sales_data_sample
WHERE year_id = 2003
GROUP BY country, year_id
ORDER BY year_id DESC
LIMIT 3;

-- Query to find the top countries contributing the most to sales in 2004
SELECT 
    year_id,
    country,
    SUM(sales) AS country_revenue
FROM Project1.sales_data_sample
WHERE year_id = 2004
GROUP BY country, year_id
ORDER BY year_id DESC
LIMIT 3;

-- Query to find the top countries contributing the most to sales in 2005
SELECT 
    year_id,
    country,
    SUM(sales) AS country_revenue
FROM Project1.sales_data_sample
WHERE year_id = 2005
GROUP BY country, year_id
ORDER BY year_id DESC
LIMIT 3;