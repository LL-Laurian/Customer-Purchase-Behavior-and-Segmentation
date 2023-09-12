SELECT * FROM Project1.sales_data_sample;

-- Checking unique values
SELECT DISTINCT status FROM sales_data_sample; -- Nice one to plot
SELECT DISTINCT year_id FROM sales_data_sample;
SELECT DISTINCT PRODUCTLINE FROM sales_data_sample; -- Nice to plot
SELECT DISTINCT COUNTRY FROM sales_data_sample; -- Nice to plot
SELECT DISTINCT DEALSIZE FROM sales_data_sample; -- Nice to plot
SELECT DISTINCT TERRITORY FROM sales_data_sample; -- Nice to plot

SELECT DISTINCT MONTH_ID FROM sales_data_sample
WHERE year_id = 2003
ORDER BY month_id;

SELECT DISTINCT MONTH_ID FROM sales_data_sample
WHERE year_id = 2004
ORDER BY month_id;

SELECT DISTINCT MONTH_ID FROM sales_data_sample
WHERE year_id = 2005
ORDER BY month_id;
-- Analysis
-- Grouping sales by productline
SELECT
	productline,
    Sum(sales) AS revenue
FROM sales_data_sample
GROUP BY productline
ORDER BY revenue DESC;

-- checking the sales accross the year
SELECT
	year_id,
    Sum(sales) AS revenue
FROM sales_data_sample
GROUP BY year_id
ORDER BY revenue DESC; #FOUND 2005 is much less tha the other 2 years. By line 11-13, we found that not all the months are shown in 2005

-- checking the dealsize (S/m/l) accross the year
SELECT
	dealsize,
    Sum(sales) AS revenue
FROM sales_data_sample
GROUP BY dealsize
ORDER BY revenue DESC;

-- ------------------------------------------------------------------------------------------------------------------
-- What was the best month for sales in a specific year? How much was earned that month? And what earn the most for those highest months?
DROP TABLE IF EXISTS month_info;
DROP TABLE IF EXISTS max_revenue;
DROP TABLE IF EXISTS best_month;
DROP TABLE IF EXISTS month_productline;
DROP TABLE IF EXISTS best_productline_revenue;
DROP TABLE IF EXISTS best_productline;


-- Generate a table to contain each month's revenue
CREATE TEMPORARY TABLE month_info AS(
	SELECT
		year_id,
		month_id,
		sum(sales) AS month_revenue,
        count(ordernumber) AS month_frequency
	FROM sales_data_sample s
	GROUP BY month_id, year_id
);

-- Generate a table conatining the highest month revenue every year
CREATE TEMPORARY TABLE max_revenue AS(
	SELECT 
			year_id,
			max(month_revenue) AS best_month_revenue
		FROM month_info
        GROUP BY year_id
);

-- Generate a table conataining the month contains the highest revenue and the corresponding revenue
CREATE TEMPORARY TABLE best_month AS(
	SELECT
			max_revenue.year_id,
			c.month_id,
			max_revenue.best_month_revenue
            
		FROM max_revenue
		JOIN month_info c ON max_revenue.best_month_revenue = c.month_revenue AND c.year_id = max_revenue.year_id
);

-- Generate a table to contain each month's productline and its revenue by productline
CREATE TEMPORARY TABLE month_productline AS(
	SELECT
		year_id,
		month_id,
        productline AS month_productline,
		sum(sales) AS productline_revenue
	FROM sales_data_sample 
	GROUP BY month_id, year_id,month_productline
);

-- Generate a table conatining the highest productline revenue by month
CREATE TEMPORARY TABLE best_productline_revenue AS(
	SELECT 
			year_id,
            month_id,
            max(productline_revenue) AS best_productline_revenue
		FROM month_productline
        GROUP BY year_id,month_id
 );
 
-- 
-- Generate a table conatining the highest productline revenue by month, and the productline. Joining best_month info together 
 CREATE TEMPORARY TABLE best_productline AS(
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


-- Conatain a big table with year revenue, highest month revenue of each year and the highest productline of the corresponding highest month
SELECT 
	a.year_id,
    sum(sales) AS year_revenue,
    sum(ordernumber) As year_frequency,
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
 )detail_month_info  
    ON a.year_id = detail_month_info.year_id
GROUP BY a.year_id, detail_month_info.best_month_revenue, detail_month_info.month_id, detail_month_info.best_month_frequency, detail_month_info.month_productline,
    detail_month_info.best_productline_revenue;

-- ------------------------------------------------------------------------------------------------------------------------------------------------------
-- Convert the date format to the sql form; first let sql regonize that this is a date then convert
UPDATE sales_data_sample
SET orderdate = DATE_FORMAT(STR_TO_DATE(orderdate, '%m/%d/%Y %H:%i'), '%Y-%m-%d %H:%i');

-- -------------------------------------------------------------------------------------------------
-- RFM Analysis to evaluate if it is a valuable customer

-- Recency: How long ago their last purchase was (last order date)
-- frequency: how often they purchase (count order)
-- monetary value: how much they spent (sales amount)



-- SOLVE:Who is our best customer; this can be answer by the RFM

-- Drop regular tables if they exist
DROP TABLE IF EXISTS final_rfm;
DROP TABLE IF EXISTS rfm;
DROP TABLE IF EXISTS rfm_calc;

-- Create a regular table for rfm
CREATE TEMPORARY TABLE rfm AS (
    SELECT
        customername,
        sum(sales) AS monetary_value,
        avg(sales) AS average_monetary_value,
        count(ordernumber) AS frequency,
        max(orderdate) AS last_order_date,
        (SELECT max(orderdate) FROM sales_data_sample) AS latest_date,
        DATEDIFF((SELECT max(orderdate) FROM sales_data_sample), max(orderdate)) AS recency 
    FROM sales_data_sample
    GROUP BY customername
);

-- Calculate RFM values and insert into rfm_calc table
CREATE TEMPORARY TABLE rfm_calc AS (
    SELECT 
        r.*,
        NTILE(4) OVER (ORDER BY recency desc) AS rfm_recency,
        NTILE(4) OVER (ORDER BY frequency) AS rfm_frequency,
        NTILE(4) OVER (ORDER BY monetary_value) AS rfm_monetary
    FROM rfm r
    -- ORDER BY 4 desc
);

-- Create the temporary table
CREATE TEMPORARY TABLE final_rfm AS (
	SELECT 
		c.*,
		rfm_recency + rfm_frequency + rfm_monetary AS rfm_cell,
		CONCAT(CAST(rfm_recency AS CHAR), CAST(rfm_frequency AS CHAR), CAST(rfm_monetary AS CHAR)) AS rfm_cell_string
	FROM rfm_calc c
);

SELECT * FROM final_rfm;
    
SELECT CUSTOMERNAME , rfm_recency, rfm_frequency, rfm_monetary,
	CASE 
		WHEN rfm_cell_string IN (111, 112 , 121, 122, 123, 132, 211, 212, 114, 141) THEN 'lost_customers'  -- lost customers
		WHEN rfm_cell_string IN (133, 134, 143, 244, 334, 343, 344, 144) THEN 'slipping away, cannot lose' -- (Big spenders who haven’t purchased lately) slipping away
		WHEN rfm_cell_string IN (311, 411, 331) THEN 'new customers'
		WHEN rfm_cell_string IN (222, 223, 233, 322) THEN 'potential churners'
		WHEN rfm_cell_string IN (323, 333,321, 422, 332, 432) THEN 'active' -- (Customers who buy often & recently, but at low price points)
		WHEN rfm_cell_string IN (433, 434, 443, 444) THEN 'loyal'
	END AS rfm_segment

FROM final_rfm;

-- -------------------------------------------------------------------------------------------------

-- Solve: What products are often sold together when buy two types of products?


SELECT 
	order_item_code,
    count(order_item_code) AS occurence
FROM (
	-- Organize the order_item_codes from the ordernumber (these is for the ordernumber that buy two items
	SELECT 
		a.ordernumber,
		Group_concat(a.productcode SEPARATOR ', ')  AS order_item_code
	FROM sales_data_sample a
	WHERE a.ordernumber IN (
			SELECT ordernumber
			FROM (
				SELECT
					b.ordernumber,
					count(b. ordernumber) AS quantity_ordertype
				FROM sales_data_sample b
				WHERE status = 'shipped'
				GROUP by ordernumber
			) m
			WHERE quantity_ordertype = 2
		)
	GROUP BY a.ordernumber
) order_details 
GROUP BY order_item_code 
ORDER BY occurence DESC;

-- ---------------------------------------------------------------------------------------

-- Solve: which counrty contributes the sales the most?

SELECT 
	year_id,
	country,
    sum(sales) AS country_revenue,
     Group_concat((SELECT productline FROM sales_data_sample GROUP BY productline ORDER BY sum(sales) DESC LIMIT 3) SEPARATOR ', ') AS 'best-product_by country'
FROM sales_data_sample
WHERE year_id =2003
GROUP BY country, year_id
ORDER BY year_id DESC
LIMIT 3;

SELECT 
	year_id,
	country,
    sum(sales) AS country_revenue,
    Group_concat((SELECT productline FROM sales_data_sample GROUP BY productline ORDER BY sum(sales) DESC LIMIT 3) SEPARATOR ', ') AS 'best-product_by country'
FROM sales_data_sample
WHERE year_id =2004
GROUP BY country, year_id
ORDER BY year_id DESC
LIMIT 3;

SELECT 
	year_id,
	country,
    sum(sales) AS country_revenue,
    Group_concat((SELECT productline FROM sales_data_sample GROUP BY productline ORDER BY sum(sales) DESC LIMIT 3) SEPARATOR ', ') AS 'best-product_by country'
FROM sales_data_sample
WHERE year_id =2005
GROUP BY country, year_id
ORDER BY year_id DESC
LIMIT 3;


