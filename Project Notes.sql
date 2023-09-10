
-- 1. date difference

-- when we do recency, we use
DATEDIFF(latest_date, last_order_date) # RETURN int




-- 2. ntile
-- The number of tiles or buckets you want to divide the result set into.
-- An optional OVER clause specifying the partitioning and ordering of the rows.
 
 NTILE(4) OVER (ORDER BY sales) AS quartile
 
 -- In this example, the NTILE() function assigns a value of 1, 2, 3, or 4 to the quartile 
 -- column for each row, indicating which quartile the row's sales value falls into.
 -- 平均分为4个等级 
 
 
 -- 3.cast
 
-- The CAST() function in SQL is used to explicitly convert an expression from one data type to
-- another. It allows you to change the data type of a value or column in a query result.

CAST(expression AS new_data_type)



-- 4. CONCAT
CONCAT('a','b','c') returns "abc"
 
 -- 5. Grou_concat 将一列的结果整合为一个string
 Syntax:
/*
GROUP_CONCAT([DISTINCT] expression [ORDER BY sorting] [SEPARATOR separator])

DISTINCT (optional): Specifies that duplicate values 

expression: The COLUMN or expression whose values you want to concatenate.

ORDER BY sorting (optional): Specifies the order in which the values should be concatenated within each group.

SEPARATOR separator (optional): Specifies the separator string between concatenated values. The DEFAULT separator is a comma (,).
Usage:

GROUP_CONCAT is typically used in conjunction with the GROUP BY clause to perform aggregation
on groups of rows and concatenate values within each group.

*/