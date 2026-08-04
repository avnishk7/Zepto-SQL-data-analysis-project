CREATE DATABASE zepto_analysis;
use zepto_analysis;
drop table if exists zepto;

create table zepto (
sku_id INT AUTO_INCREMENT PRIMARY KEY,
category VARCHAR(120),
name VARCHAR(150) NOT NULL,
mrp NUMERIC(8,2),
discountPercent NUMERIC(5,2),
availableQuantity INTEGER,
discountedSellingPrice NUMERIC(8,2),
weightInGms INTEGER,
outOfStock BOOLEAN,	
quantity INTEGER
);

-- LOADING DATA IN TABLE 
LOAD DATA LOCAL INFILE 'C:/Users/Avnish/Downloads/zepto_v22.csv'
INTO TABLE zepto
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(category,
 name,
 mrp,
 discountPercent,
 availableQuantity,
 discountedSellingPrice,
 weightInGms,
 outOfStock,
 quantity);
 
 -- Data Exploration 
	
-- Count of number of rows
SELECT count(*)
FROM zepto; 

-- sample data 
SELECT * 
FROM zepto
LIMIT 20;

-- Checking null values
SELECT * 
FROM zepto
WHERE category IS NULL
OR 
name IS NULL 
OR
mrp IS NULL
OR
discountPercent IS NULL
OR
discountedSellingPrice IS NULL
OR
weightInGms IS NULL
OR
availableQuantity IS NULL
OR
outOfStock IS NULL
OR
quantity IS NULL;

-- Different product categories
SELECT DISTINCT category
FROM zepto 
ORDER BY category;

-- Product in stock vs out of stock
SELECT
    SUM(CASE WHEN outOfStock = 1 THEN 1 ELSE 0 END) AS out_of_stock,
    SUM(CASE WHEN outOfStock = 0 THEN 1 ELSE 0 END) AS in_stock
FROM zepto;

-- Product names which is present multiple times
SELECT name,count(sku_id) as 'Number of sku(s)'
FROM zepto
GROUP BY name
HAVING count(sku_id) > 1
ORDER BY count(sku_id) desc;

-- Data cleaning part

-- Products with price = 0
SELECT * FROM zepto 
WHERE mrp = 0 or discountedSellingPrice = 0;

-- temporary disabling safe updates 
SET SQL_SAFE_UPDATES = 0;

-- Deleting a product which contains mrp = 0
DELETE FROM zepto 
WHERE mrp = 0;

-- Convert paise to rupees
UPDATE zepto
SET mrp = mrp / 100.0,
discountedSellingPrice = discountedSellingPrice / 100.0;

-- After converting looking at the columns 
SELECT mrp, discountedSellingPrice FROM zepto;

-- Data analysis

-- Q1. Find the top 10 best-value products based on the discount percentage.
SELECT name, mrp, discountPercent
FROM zepto 
ORDER BY discountPercent desc
LIMIT 10;

-- Q2.What are the unique Products with  MRP greater than 300 but Out of Stock
SELECT DISTINCT name,mrp
FROM zepto 
WHERE mrp > 300 and outOfStock = 1;

-- Q3.Calculate Estimated Revenue for each category
SELECT category, sum(discountedSellingPrice * availableQuantity) as total_revenue
FROM zepto 
GROUP BY category
ORDER BY total_revenue desc;

-- Q4. Find all products where MRP is greater than ₹500 and discount is less than 10%.
SELECT DISTINCT name, mrp, discountPercent
FROM zepto
WHERE mrp > 500 AND discountPercent < 10
ORDER BY mrp DESC, discountPercent DESC;

-- Q5. Identify the top 5 categories offering the highest average discount percentage.
SELECT category,
ROUND(AVG(discountPercent),2) AS avg_discount
FROM zepto
GROUP BY category
ORDER BY avg_discount DESC
LIMIT 5;

-- Q6. Find the price per gram for products above 100g and sort by best value.
SELECT DISTINCT name, weightInGms, discountedSellingPrice,
ROUND(discountedSellingPrice/weightInGms,2) AS price_per_gram
FROM zepto
WHERE weightInGms >= 100
ORDER BY price_per_gram;

-- Q7. Group the products into categories like Low, Medium, Bulk.
SELECT DISTINCT name, weightInGms,
CASE WHEN weightInGms < 1000 THEN 'Low'
	WHEN weightInGms < 5000 THEN 'Medium'
	ELSE 'Bulk'
	END AS weight_category
FROM zepto;

-- Q8. Find the average MRP for each category.
SELECT category, ROUND(AVG(mrp),2) as Average
FROM zepto
GROUP BY  category;

-- Q9. Find categories having more than 100 products.
SELECT category,COUNT(quantity) as Product_Count
FROM zepto
GROUP BY category
HAVING Product_Count > 100
ORDER BY Product_Count;

-- Q10. Find products whose MRP is above the overall average MRP.
SELECT sku_id,name,mrp,category
FROM zepto
WHERE mrp > (
	SELECT AVG(mrp)
    FROM zepto 
)
ORDER BY mrp; 
-- Q11. Find products whose selling price is less than ₹100.
SELECT name,discountedSellingPrice
FROM zepto 
WHERE discountedSellingPrice < 100
ORDER BY discountedSellingPrice;

-- Q12. Rank products by MRP within each category.
-- Many Solutions of this question First is using Rank() window function it assigns the same rank to tied values and skips the next rank.
-- Second using DENSE_RANK() here there are no gaps in ranking tied values same rank.

SELECT name,category,mrp,
RANK() over(partition by category order by mrp desc) as Product_rank
FROM zepto
ORDER BY category,Product_rank;

-- second solution 
SELECT name,category,mrp,
	DENSE_RANK() OVER (
        PARTITION BY category
        ORDER BY mrp DESC
    ) AS product_rank
FROM zepto
ORDER BY category, product_rank;

-- Q13. Find the second most expensive product in every category. 
WITH second_most_expensive as (
SELECT name,category,mrp,
ROW_NUMBER() over(partition by category order by mrp desc)  as rn
FROM zepto 
)
SELECT name,category,mrp
FROM second_most_expensive
WHERE rn = 2;

-- Q14. Find the top 3 costliest products from each category.

WITH top_three as (
SELECT name,category,mrp,
ROW_NUMBER() over(partition by category order by mrp desc)  as rn
FROM zepto 
)
SELECT name,category,mrp
FROM top_three
WHERE rn <= 3;

-- Q15. Find products whose price is greater than the average price of their own category.
WITH cte AS(
	SELECT name,category,mrp,
	AVG(mrp) OVER(partition by category) AS category_avg
	FROM zepto
)
SELECT name,category,mrp
FROM cte
WHERE mrp > category_avg
ORDER BY category, mrp DESC;

-- Q16. Find the top 5 products causing the highest revenue loss due to discounts.
SELECT sku_id,name,category,mrp,discountedSellingPrice,availableQuantity,
(mrp - discountedSellingPrice) as discount_per_unit,
(mrp - discountedSellingPrice) * availableQuantity as revenue_loss
FROM zepto 
WHERE mrp > discountedSellingPrice
ORDER BY revenue_loss DESC
LIMIT 5;

-- Q17. Which category gives customers the highest average discount?
SELECT category,ROUND(AVG(discountPercent),2) as average_discount_percent
FROM zepto 
GROUP BY category
ORDER BY average_discount_percent desc
LIMIT 1;

-- Q18. Find duplicate product names.
SELECT name,count(*) as duplicate_count
FROM zepto 
GROUP BY name 
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;

-- Q19. Find the number of out-of-stock products in each category.
SELECT category,count(*) as out_of_stock_count
FROM zepto 
WHERE outOfStock = 1
GROUP BY category
ORDER BY out_of_stock_count desc;

-- Q20. Find the top 5 most discounted products in every category.
WITH top_discounted AS(
	SELECT name,category,discountPercent,
RANK() OVER(partition by category order by discountPercent desc) as rn
FROM zepto
)
SELECT name,category,discountPercent
FROM top_discounted
WHERE rn <= 5
ORDER BY category;

-- Q21. Which 10 products generate the highest revenue?
SELECT sku_id,name,category,discountedSellingPrice,availableQuantity,
discountedSellingPrice * availableQuantity AS revenue
FROM zepto
ORDER BY revenue DESC
LIMIT 10;

