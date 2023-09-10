-- DROP table and temporary table
/*
1. drop table if exists #rfm

The SQL statement DROP TABLE IF EXISTS #rfm is used to drop a temporary table named #rfm if it exists. Let's break down what each part of the statement means:

DROP TABLE: This is the command to remove a table from the database.

IF EXISTS: This is an optional clause that ensures the table is dropped only if it exists. If the table doesn't exist, no error will be raised.

#rfm: This is the name of the table you want to drop. In this case, it appears to be a temporary table named #rfm.

2. #

CREATE TEMPORARY TABLE final_rfm AS (
	SELECT 
		c.*,
		rfm_recency + rfm_frequency + rfm_monetary AS rfm_cell,
		CONCAT(CAST(rfm_recency AS CHAR), CAST(rfm_frequency AS CHAR), CAST(rfm_monetary AS CHAR)) AS rfm_cell_string
	FROM rfm_calc c
);*/

-- Case
/*
In SQL, the CASE statement is a conditional expression that allows you to perform different actions based
on specified conditions.


1) In a simple CASE expression, you specify an expression, and then for each value you want to evaluate, you
provide a value to compare it with (value1, value2, etc.), and the corresponding result if the expression matches
the value.

SELECT product_name,
    CASE category_id
        WHEN 1 THEN 'Electronics'
        WHEN 2 THEN 'Clothing'
        ELSE 'Other'
    END AS category
FROM products;


2) In a searched CASE expression, you provide one or more conditions, and the result is based on the first condition
that evaluates to true.

SELECT order_id, order_date,
    CASE
        WHEN total_amount > 1000 THEN 'High Value'
        WHEN total_amount > 500 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS order_value
FROM orders;

!!!!!!!!If none of the conditions are met and there is no ELSE clause, the result will be NULL.
*/

-- 
