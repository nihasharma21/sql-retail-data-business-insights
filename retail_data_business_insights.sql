-- Aurora Outfitters Retail SQL Script
-- --------------------------------------------------------------------------
-- Use schema
Use final_project;

-- --------------------------------------------------------------------------
-- Heading 1. DDL: Create statements for tables
-- Tables are created in following orders to maintain dependency: Customers, Stores, Staff, Products, 
    -- Promotions, Orders, OrderItems, LineItemPromotions, Returns
    
-- Customers
CREATE TABLE Customers(
CustomerID INT UNSIGNED NOT NULL AUTO_INCREMENT,
CustFirstName VARCHAR(30) NOT NULL,
CustLastName VARCHAR(30) NOT NULL,
CustContacNo VARCHAR(16) NOT NULL,
Email VARCHAR(30) NOT NULL,
  PRIMARY KEY (CustomerID)
);

-- Stores
CREATE TABLE Stores(
StoreID INT UNSIGNED NOT NULL AUTO_INCREMENT,
StoreName VARCHAR(16) NOT NULL,
City VARCHAR(16) NOT NULL,
State VARCHAR(2) NOT NULL,
PRIMARY KEY (StoreID)
);

-- Staff
CREATE TABLE Staff(
StaffID INT UNSIGNED NOT NULL AUTO_INCREMENT,
StoreID INT UNSIGNED NOT NULL,
StaffFirstName VARCHAR(16) NOT NULL,
StaffLastName VARCHAR(16) NOT NULL,
StaffContactNo VARCHAR(16) NOT NULL,
PRIMARY KEY (StaffID),
CONSTRAINT fk_staff_stores FOREIGN KEY(StoreID) REFERENCES Stores(StoreID)
-- on deleting store, staff data should be deleted as well
ON DELETE CASCADE ON UPDATE CASCADE
);

-- Products
CREATE TABLE Products(
ProductID INT UNSIGNED NOT NULL AUTO_INCREMENT,
ProductName VARCHAR(16) NOT NULL,
ProductCategory VARCHAR(16) NOT NULL,
ProductType VARCHAR(16) NOT NULL,
PRIMARY KEY (ProductID)
);

-- Promotions
CREATE TABLE Promotions(
PromotionID INT UNSIGNED NOT NULL AUTO_INCREMENT,
PromotionTitle VARCHAR(16) NOT NULL,
PromotionCategory VARCHAR(16) NOT NULL,
PRIMARY KEY (PromotionID)
);

-- Orders
CREATE TABLE Orders(
OrderID INT UNSIGNED NOT NULL AUTO_INCREMENT,
CustID INT UNSIGNED NOT NULL,
OrderDate Date NOT NULL,
TotalCost DECIMAL(10,2) NOT NULL CHECK(TotalCost >=0),
SalesChannel VARCHAR(16) NOT NULL,
StoreID INT UNSIGNED NOT NULL,
PRIMARY KEY (OrderID),
CONSTRAINT fk_orders_stores FOREIGN KEY(StoreID) REFERENCES Stores(StoreID)
ON DELETE RESTRICT ON UPDATE RESTRICT,
CONSTRAINT fk_orders_customers FOREIGN KEY(CustID) REFERENCES Customers(CustID),
CONSTRAINT chk_orders_channel CHECK(SalesChannel IN ('InStore','Online'))
);

-- Error: Column Name mismatch in Orders and Customers. Alter statement to change column name 
ALTER TABLE Customers
CHANGE COLUMN CustomerID CustID INT UNSIGNED NOT NULL AUTO_INCREMENT;
DESCRIBE Customers;


-- OrderItems
CREATE TABLE OrderItems(
LineItemID INT UNSIGNED NOT NULL AUTO_INCREMENT,
OrderID INT UNSIGNED NOT NULL,
Qty INT NOT NULL CHECK(Qty>0),
UnitPrice DECIMAL(10,2) NOT NULL CHECK(UnitPrice >=0),
ProductID INT UNSIGNED NOT NULL,
PRIMARY KEY (LineItemID),
CONSTRAINT fk_orderitems_order FOREIGN KEY(OrderID) REFERENCES Orders(OrderID) 
-- when an order is deleted , line items should be deleted as well
ON DELETE CASCADE ON UPDATE RESTRICT,
CONSTRAINT fk_orderitems_products FOREIGN KEY(ProductID) REFERENCES Products(ProductID)
ON DELETE RESTRICT ON UPDATE RESTRICT
);


-- LineItemsPromotions
CREATE TABLE LineItemPromotions(
PromotionID INT UNSIGNED NOT NULL,
LineItemID INT UNSIGNED NOT NULL,
PRIMARY KEY (PromotionID,LineItemID),
CONSTRAINT fk_promotion_lineitems FOREIGN KEY(LineItemID) REFERENCES OrderItems(LineItemID)
-- on deleting lineitem, data should be delete from this table as well
ON DELETE CASCADE ON UPDATE CASCADE,
CONSTRAINT fk_promotion FOREIGN KEY(PromotionID) REFERENCES Promotions(PromotionID)
-- on deleting lineitem, data should be delete from this table as well
ON DELETE RESTRICT ON UPDATE RESTRICT
);


-- Returns
CREATE TABLE Returns(
LineItemID INT UNSIGNED NOT NULL,
ReturnQty INT UNSIGNED NOT NULL CHECK (ReturnQty>0),
ReturnDate DATE NOT NULL,
ReturnReason VARCHAR(100) NULL, -- A return can be made without any giving reason
RefundAmount DECIMAL(10,2) NOT NULL CHECK(RefundAmount >=0),
PRIMARY KEY (LineItemID),
CONSTRAINT fk_return_orderitems FOREIGN KEY(LineItemID) REFERENCES OrderItems(LineItemID)
-- on deleting lineitem, data should be delete from returns as well
ON DELETE CASCADE ON UPDATE CASCADE
);


SHOW TABLES;
Select count(*) from Customers;
Select count(*) from Stores;
Select count(*) from Staff;
Select count(*) from Products;
Select count(*) from Promotions;
Select count(*) from Orders;
Select count(*) from OrderItems;
Select count(*) from LineItemPromotions;
Select count(*) from Returns;

-- ---------------------------------------------------------------------------------
-- Heading2: Create Data
-- Step1. Give chatGPT a detailed prompt to create data

-- 1.Background: Imagine Aurora Outfitters to be a small retailer which sells outdoor clothing
-- and gear both in-store and online clothes. Imagine Patagonia company as a competitor with 
-- same product line. 
-- 2. Ask: I would like to create sample data for the following tables:   
-- customers lineitempromotions orderitems orders products promotions returns staff stores Data 
-- 3. Data Requirements: Following are the requirements of the data 
-- ≥ 120 orders across
-- ≥ 3 monthsand both channels ≥ 25 products (at least 3 categories)
-- ≥ 80 customers (some repeat purchasers) Returns on 5–15% of items 
-- ≥ 3 stores with differing performance 
-- 4. Table requirements: Keep the data as per the rules mentioned in ERD which is attached. 
-- 5. Business Requirements: Consider data for 2024 Q4. 
-- Follow the instructions given in the text added with each relationship between the tables.
-- For example: one item can only be returned once. 
-- Ask any questions before you generate the data. 
-- Generate the data for each table in one excel with different tabs.
-- Converted those file to each csv manually before importing.

-- Step2. Validated data to check if generated data is realistic, following rules and cover business questions. 

-- ---------------------------------------------------------------------------------

-- Heading3. Insert Data in tables
-- Step1. Load data using Table Data Import Wizard by uploading one file each for one table individually. 

-- ---------------------------------------------------------------------------------

-- Heading4. Business Questions

-- Q1. Monthly revenue trend by channel: One row per month for the last 3 months present in your data, 
       -- with month, in_store_revenue, online_revenue, and total_revenue.
-- Solution Steps
	-- All the data is available in orders table.
    -- Use join to combine the info by where clause
    -- Wrap it with total revenue info

SELECT 
i.month, i.in_store_revenue, o.online_revenue,(i.in_store_revenue+o.online_revenue) as total_revenue
FROM (
SELECT MONTH(OrderDate) AS month,
SUM(TotalCost) AS in_store_revenue
FROM Orders
WHERE SalesChannel = 'InStore'
GROUP BY MONTH(OrderDate)
) i
INNER JOIN(
SELECT MONTH(OrderDate) AS month,
SUM(TotalCost) AS online_revenue
FROM Orders
WHERE SalesChannel ='Online'
GROUP BY MONTH(OrderDate)
) o
ON i.month = o.month
ORDER BY i.month;

-- ---------------------------------------------------------------

-- Q2. Top products: For each channel, list the top 3 products by gross revenue (product name, channel, revenue)
        -- using a ranking approach.

-- Solution Steps
-- Combine Products, OrderItems( UnitPrice & Oty) & Orders(Sales channel) table.
-- Add Windows ROW_NUMBER function to create anothe table with ranking by Gross Revenue and for each SalesChannel
-- Create another subquery on top of this to limit data to only top 3 for each channel

Select rt.Ranking,rt.ProductID, rt.ProductName,rt.SalesChannel, rt.GrossRevenue FROM
(
Select p.ProductID, p.ProductName,o.SalesChannel,SUM(oi.Qty*oi.UnitPrice) as GrossRevenue,
ROW_NUMBER() OVER (PARTITION BY o.SalesChannel ORDER BY SUM(oi.Qty*oi.UnitPrice) DESC) AS Ranking
from Products p
INNER JOIN OrderItems oi ON oi.ProductID=p.ProductID
INNER JOIN Orders o on oi.OrderID = o.OrderID
GROUP BY p.ProductID, p.ProductName,o.SalesChannel
) rt
WHERE rt.Ranking<=3
ORDER BY rt.SalesChannel,rt.GrossRevenue DESC;

-- ------------------------------------------------------------

-- Q3 Store performance: Total revenue and average order value by store; 
    -- order stores from highest to lowest revenue. Include order count.

-- Solution Steps
-- We will connect Orders and Stores table for this. 
-- Assuming only physical stores

Select s.StoreID, s.StoreName, SUM(o.TotalCost) AS TotalRevenue, 
ROUND(AVG(o.TotalCost),2) AS AvgOrderValue, 
COUNT(o.OrderID) AS OrderCount
from Orders o 
INNER JOIN Stores s ON o.StoreID = s.StoreID
GROUP BY s.StoreID,s.StoreName
ORDER by SUM(o.TotalCost) DESC;

-- -----------------------------------------------------------
-- Q4 Customer repeat behavior: % of customers with 2+ orders, 
      -- and the median days between first and second order (use a window/subquery approach).
-- Assumption: Find % of repeat customers out of total customers (irrespective of whether they ordered or not). Also 2+ means 2 and more orders.
 
-- This query is done in two parts. 
-- Q4 Part1 
-- Find Customers where order>=2. Find total customers and find percentage

  SELECT 
  ROUND(100 * COUNT(*) / (SELECT COUNT(*) FROM Customers), 2) AS pct_customers_2plus_orders
FROM (
  SELECT CustID
  FROM Orders
  GROUP BY CustID
  HAVING COUNT(OrderID) >= 2
) repeat_customers;
-- Final solution: There are 47% customers who have ordered twice or more. 

  -- Q4 Part 2 Find median days between 1st and 2nd order
  
    -- Solution Steps: 
    -- Find all repeat customers.
    -- Find their 1st and 2nd order date. 
    -- Create a column with the difference b/w 2nd and 1st purchase. 
    -- Sort in asc order and then find median. 
  
DROP VIEW IF EXISTS daysbetweenorders;  
CREATE VIEW daysbetweenorders AS -- create view at the end to make this one table and use further
SELECT fs.CustID,fs.FirstDate, fs.SecondDate,DATEDIFF(fs.SecondDate,fs.FirstDate) As DaysBetween
FROM (
SELECT f.CustID, f.FirstDate,s.SecondDate FROM
(
SELECT CustID, MIN(OrderDate) AS FirstDate  -- 1. Find 1st order date
FROM Orders
GROUP BY CustID
)f      -- table which contains 1st order date
INNER JOIN 
(
SELECT CustID,OrderDate AS SecondDate
FROM (
SELECT CustID, OrderDate, ROW_NUMBER() OVER (PARTITION BY CustID ORDER BY OrderDate) AS rn -- create a ranking column to find 2nd order date
FROM Orders
)r  -- Table which contains ranking information
WHERE r.rn=2
) s -- Alias name for table with Second Order Date
ON s.CustID=f.CustID
) fs
ORDER BY DaysBetween;

-- Use view table to calculate ranking, find middle value and cal median ( for even/odd rows)
SELECT ROUND(AVG(DaysBetween),0) AS MedianDaysBetween 
FROM (
  SELECT 
    *, 
    ROW_NUMBER() OVER (ORDER BY DaysBetween) AS rn,
    COUNT(*) OVER () AS total_rows
  FROM daysbetweenorders
) finalquery
WHERE rn IN (
  FLOOR((total_rows + 1) / 2), 
  CEIL((total_rows + 1) / 2)
);
-- Final answer: 15 days median value between 1st and 2nd order by repeated customers
 -----------------------------------------------------------------------------
 
-- Q5: Promotion effectiveness: Revenue, orders, 
       -- and lift for promoted vs non-promoted items (define “promoted” from your model). 
       -- Show absolute and % differences.
       
-- Approach: OrderItems>LineItemsPromotions>Promotions. If a line item is present in LineItemsPromotions, it is a promoted product. 
-- Solution 1 ( with Bug)
-- Joining all three queries together to cal. revenue, orders for promoted , non promoted and total
-- Create view on top
-- Use view to calculate percentages

DROP VIEW IF EXISTS PromotionEffectiveness;
CREATE VIEW promotioneffectiveness AS
SELECT
p.promoted_revenue, p.promoted_orders, p.promoted_lineitems,
np.non_promoted_revenue, np.non_promoted_orders, np.non_promoted_lineitems,
t.total_revenue, t.total_orders, t.total_lineitems
FROM (
-- Promoted Products Revenue and Count
SELECT SUM(oi.Qty*oi.UnitPrice) AS promoted_revenue,
 COUNT(DISTINCT oi.OrderID) AS promoted_orders, COUNT(DISTINCT oi.LineItemID) AS promoted_lineitems
FROM OrderItems oi
INNER JOIN LineItemPromotions lip
ON lip.LineItemID = oi.LineItemID
)p
CROSS JOIN (
-- Non Promotted Products Revenue and Count
SELECT SUM(oi.Qty * oi.UnitPrice) AS non_promoted_revenue,
COUNT(DISTINCT oi.OrderID) AS non_promoted_orders, COUNT(DISTINCT oi.LineITemID) AS non_promoted_lineitems
FROM OrderItems oi
LEFT JOIN LineItemPromotions lip
ON lip.LineItemID = oi.LineItemID
WHERE lip.LineItemID IS NULL  -- If a product is non promoted, no row should be in lip
)np
CROSS JOIN (
-- Total Revenue and Count for % calculation
-- Note (promoted_orders+non_promoted_orders> total_orders as 1 order can have multiple promoted and non-promoted line items
SELECT SUM(oi.Qty*oi.UnitPrice) AS total_revenue,
COUNT(DISTINCT oi.OrderID) AS total_orders, COUNT(DISTINCT oi.LineITemID) AS total_lineitems
FROM OrderItems oi
) t;

-- Now I will use View to do % calculations as the query became quite complex
SELECT
promoted_revenue, promoted_orders,
non_promoted_revenue, non_promoted_orders,
total_revenue, total_orders,
ROUND(promoted_revenue*100/total_revenue, 2) AS promoted_revenue_pct,
ROUND(non_promoted_revenue*100/total_revenue, 2) AS non_promoted_revenue_pct
FROM PromotionEffectiveness;


-- Solution 1 Problem: If you see here, (promoted_revenue+non_promoted_revenue)>100 because as one line item can have multiple promotions.

-- Debugging and Corrected Solution
-- Assumption: I will assume that only one promotion will be counted for one line item 
-- New Solution

DROP VIEW IF EXISTS PromotionEffectiveness;
CREATE VIEW PromotionEffectiveness AS
SELECT
  p.promoted_revenue,
  p.promoted_orders,
  p.promoted_lineitems,
  np.non_promoted_revenue,
  np.non_promoted_orders,
  np.non_promoted_lineitems,
  t.total_revenue,
  t.total_orders,
  t.total_lineitems
FROM (
  -- PROMOTED: count each line item ONCE even if it has several promos
  SELECT
    SUM(oi.Qty*oi.UnitPrice) AS promoted_revenue,
    COUNT(DISTINCT oi.OrderID) AS promoted_orders,
    COUNT(*) AS promoted_lineitems
  FROM OrderItems oi
  JOIN (
    SELECT DISTINCT LineItemID
    FROM LineItemPromotions
  ) d
    ON d.LineItemID = oi.LineItemID
) p
CROSS JOIN (
  -- NON-PROMOTED: line items with no promotion rows
  SELECT
    SUM(oi.Qty * oi.UnitPrice) AS non_promoted_revenue,
    COUNT(DISTINCT oi.OrderID) AS non_promoted_orders,
    COUNT(*) AS non_promoted_lineitems
  FROM OrderItems oi
  LEFT JOIN (
    SELECT DISTINCT LineItemID
    FROM LineItemPromotions
  ) d
    ON d.LineItemID = oi.LineItemID
  WHERE d.LineItemID IS NULL
) np
CROSS JOIN (
  -- TOTALS
  SELECT
    SUM(oi.Qty * oi.UnitPrice) AS total_revenue,
    COUNT(DISTINCT oi.OrderID) AS total_orders,
    COUNT(*) AS total_lineitems
  FROM OrderItems oi
) t;

-- Query on View to get % calculations
SELECT
promoted_revenue, promoted_orders,
non_promoted_revenue, non_promoted_orders,
total_revenue, total_orders,
ROUND(promoted_revenue*100/total_revenue, 2) AS promoted_revenue_pct,
ROUND(non_promoted_revenue*100/total_revenue, 2) AS non_promoted_revenue_pct
FROM PromotionEffectiveness;


-- -------------------------------------------------------------------------------
-- Q6 Return rate: Item-level return rate overall and by product category (items returned / items sold).
--  Flag any category with return rate > 10%.

-- This question is solved using two queries separately
-- Q6 Part 1 Solution: Find total return rate by item level.
-- Solution Approach
	-- Connect Return ( ReturnQty) & OrderItems( Qty)
SELECT
  SUM(r.ReturnQty) AS total_items_returned,
  SUM(oi.Qty) AS total_items_sold,
  ROUND(SUM(r.ReturnQty) * 100.0 / SUM(oi.Qty), 2) AS overall_return_rate_pct
FROM
  OrderItems oi
  LEFT JOIN Returns r ON oi.LineItemID = r.LineItemID; -- left join here because we want all the orders sold
  
  -- Final solution: Return Rate is ~7% for all the orders sold. 
  -- --------------------------------------------------------------
-- Q6 Part2.  Return Rate by category
-- Solution Approach: Category comes from Product table. So Returns>OrderItems> Product
SELECT
p.ProductCategory,
SUM(r.ReturnQty) AS category_items_returned,
SUM(oi.Qty) AS category_items_sold,
ROUND(SUM(r.ReturnQty) * 100.0 / SUM(oi.Qty), 2) AS category_return_rate_pct,
CASE                                                           -- Added a case condition to flag if return>10%
WHEN (SUM(r.ReturnQty) * 1.0 / SUM(oi.Qty)) > 0.10 THEN 'FLAGGED'  
ELSE ''
END AS flag
FROM
OrderItems oi
LEFT JOIN Returns r ON oi.LineItemID = r.LineItemID  
INNER JOIN Products p ON oi.ProductID = p.ProductID
GROUP BY
p.ProductCategory;                   -- Use group by to combine by ProductCategory


  -- ------------------------------------------------------------------
  -- Q7. Basket composition: Average distinct products per order 
          -- and the share of orders with ≥ 3 items.
  -- This question is solved using two queries separately
  
  -- Q7 Part 1: Average distinct products per order
  -- Solution Approach: OrderItems>Products. For each order, find distinct product count, calculate average
  
SELECT     -- Take avg of distinct product count column to get overall avg
ROUND(AVG(product_count), 2) AS avg_distinct_products_per_order
FROM (
SELECT    -- For each order,lets find out the distinct product count
oi.OrderID,
COUNT(DISTINCT oi.ProductID) AS product_count
FROM OrderItems oi
GROUP BY oi.OrderID
 ) subq;                                                 
 -- Final answer: 2 distinct products/ order on an average. 	
 
 -- Q7 Part 2: share of orders with ≥ 3 items
	
SELECT
  ROUND(sub1.num_orders_with_3plus * 100.0 / sub2.total_orders, 2) -- Calculate %
  AS pct_orders_with_3plus_distinct_products
FROM
  (SELECT COUNT(*) AS num_orders_with_3plus             -- Step2. Count those orders
   FROM (
     SELECT oi.OrderID                                  -- Step1. Select all orders with >= 3products
     FROM OrderItems oi
     GROUP BY oi.OrderID
     HAVING COUNT(DISTINCT oi.ProductID) >= 3
   ) qualified_orders
  ) sub1,
  (SELECT COUNT(*) AS total_orders FROM Orders) sub2;     -- Step3: Count total orders
  
  -- Final solution: There are 26% orders with product count >= 3 items. 
  
  
  -- --------------------------------------------------------------------------------------
  
  -- Q8. High-value customers: List the top 10 customers by lifetime revenue with their order count and first/last order dates.
  -- Break ties by higher average order value.

  -- Query Solution Approach
  -- Find total order value, order count and avg order size of all customer. Add first and 2nd order dates as well. 
  -- Sort descending by total revenue and then by avg order size. Limit to top 10 customers only 
    
    
  SELECT
  c.CustID,
  c.CustFirstName,
  c.CustLastName,
  COUNT(o.OrderID) AS order_count,
  MIN(o.OrderDate) AS first_order_date,
  MAX(o.OrderDate) AS last_order_date,
  SUM(o.TotalCost) AS lifetime_revenue,
  ROUND(AVG(o.TotalCost),2) AS avg_order_value
FROM
  Customers c
  INNER JOIN Orders o ON c.CustID = o.CustID    -- Combine Customers and Order tables to get all info.
GROUP BY
  c.CustID, c.CustFirstName, c.CustLastName
ORDER BY
  lifetime_revenue DESC,     -- Sort by total order value
  avg_order_value DESC       -- If there are equal value, sort by avg. order value
LIMIT 10;

-- -------------------------------------------------------------------------------

-- Q9. Underperforming products: Products with below-median revenue in their own category
       --  (name, category, product revenue, category median).

-- Solution Approach
    -- 1. Calculate category level median revenue
			-- Calculate product level revenue
            -- Rank within category
            -- Median ( add condition for both odd and even rows by cal avg of median row/rows
	-- 3. Calculate product level revenue again and filter < Category median revenue
    
    
SELECT 
  pr.ProductName,
  pr.ProductCategory,
  pr.revenue AS product_revenue,
  ROUND(cm.median_revenue,2) AS category_median_revenue
FROM
  (
    -- Step 1: Calculate total revenue per product across all orders
    SELECT
      p.ProductID,
      p.ProductName,
      p.ProductCategory,
      SUM(oi.Qty * oi.UnitPrice) AS revenue
    FROM Products p
    JOIN OrderItems oi ON p.ProductID = oi.ProductID
    GROUP BY p.ProductID, p.ProductName, p.ProductCategory
  ) pr
JOIN
  (
    -- Step 2: Calculate median revenue per product category
    SELECT 
      ProductCategory,
      AVG(revenue) AS median_revenue
    FROM
      (
        -- Step 2a: Rank products by revenue within each category, and get total counts per category
        SELECT 
          ProductCategory,
          revenue,
          ROW_NUMBER() OVER (PARTITION BY ProductCategory ORDER BY revenue) AS rn,
          COUNT(*) OVER (PARTITION BY ProductCategory) AS cnt
        FROM
          (
            -- Step 1 repeated here to get product revenues for ranking
            SELECT
              p.ProductCategory,
              SUM(oi.Qty * oi.UnitPrice) AS revenue
            FROM Products p
            JOIN OrderItems oi ON p.ProductID = oi.ProductID
            GROUP BY p.ProductID, p.ProductCategory
          ) product_revenues
      ) ranked
    -- Step 2b: Identify the median positions within the ranking (handles odd & even number of products)
    WHERE rn IN (FLOOR((cnt + 1) / 2), CEIL((cnt + 1) / 2))
    GROUP BY ProductCategory
  ) cm ON pr.ProductCategory = cm.ProductCategory
-- Step 3: Filter the products where revenue is less than the category median revenue
WHERE pr.revenue < cm.median_revenue
-- Step 4: Sort results for easier reading
ORDER BY pr.ProductCategory, pr.revenue;



-- ----------------------------------------------------------------------
-- Q10.Dead inventory signal: Products not sold in the most recent full month of your data
    --  but sold earlier (product, last sold date). (Anti-join or NOT EXISTS.)
    
-- Solution Approach:
	-- Product>OrderItems>Orders(for OrderDate)
    -- Find products sold in Dec.
    -- Find products, order date which were not sold in Dec. 
        
SELECT
  p.ProductID,
  p.ProductName,
  MAX(o.OrderDate) AS last_sold_date
FROM Products p
JOIN OrderItems oi ON p.ProductID = oi.ProductID
JOIN Orders o ON oi.OrderID = o.OrderID
WHERE NOT EXISTS (
  -- Exclude products sold in December 2024
  SELECT 1
  FROM OrderItems oi2
  JOIN Orders o2 ON oi2.OrderID = o2.OrderID
  WHERE oi2.ProductID = p.ProductID
    AND o2.OrderDate >= '2024-12-01'
    AND o2.OrderDate < '2025-01-01'
)
GROUP BY p.ProductID, p.ProductName
HAVING MAX(o.OrderDate) < '2024-12-01'  -- to avoid sold after
ORDER BY last_sold_date DESC;
-- Final Solution: There is no dead inventory. Every product that is sold in Oct/Nov is sold in Dec as well. 
