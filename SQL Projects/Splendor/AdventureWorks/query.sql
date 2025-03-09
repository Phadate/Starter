-- Customer Behavior Analysis
SELECT * FROM Sales.SalesOrderHeader; 
SELECT * FROM Sales.SalesOrderDetail; 
SELECT * FROM Sales.SalesPerson 
SELECT * FROM Person.Person 
SELECT * FROM Production.Product 
SELECT * FROM Sales.Customer 
SELECT * FROM Production.ProductCategory 
SELECT * FROM Production.ProductSubcategory
-- 1.	Retrieve the top 10 customers by total purchase amount.

SELECT TOP 10 
        soh.CustomerID,
        pp.FirstName + ' ' + pp.LastName AS Fullname, 
        ROUND(SUM(soh.TotalDue),2) AS Total_purchase_amount
FROM Sales.SalesOrderHeader soh
JOIN Sales.Customer sc ON soh.CustomerID =sc.CustomerID
JOIN Person.Person pp ON sc.PersonID = pp.BusinessEntityID
GROUP BY soh.CustomerID, pp.FirstName + ' ' + pp.LastName 
ORDER BY Total_purchase_amount DESC;



-- 2.	Find customers who have made repeat purchases of the same product on different orders.
SELECT CustomerID, Name 
FROM (
            SELECT  soh.CustomerID, 
                    p.name, 
                    COUNT(sod.productID) AS ProductCNT
            FROM Sales.SalesOrderHeader soh
            JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
            JOIN Production.Product p ON sod.ProductID = p.ProductID
            GROUP BY soh.CustomerId, p.name) AS repeat

WHERE productCNT > 1
ORDER BY productCNT ;

-- 3.	List customers whose spending has dropped by more than 30% compared to the previous year.

WITH total_amount AS (
                        SELECT  
                                soh.CustomerId,
                                YEAR(soh.orderDate) AS Year,
                                ROUND(SUM(soh.TotalDue),2) AS Total_purchase_amount,
                                LAG(YEAR(soh.orderDate), 1) OVER (PARTITION BY CustomerID ORDER BY YEAR(soh.orderDate)) AS Previous_year,
                                LAG(ROUND(SUM(soh.TotalDue),2),1) OVER(PARTITION BY CustomerId ORDER BY YEAR(soh.orderDate)) AS prior_year_amount
                        FROM Sales.SalesOrderHeader soh
                        JOIN Sales.SalesOrderDetail sod ON sod.SalesOrderID = soh.SalesOrderID
                        GROUP BY soh.CustomerId, YEAR(soh.orderDate)  
                     ),

            YOY AS (
                    SELECT
                        CustomerId,
                        Year,
                        Total_purchase_amount,
                        Previous_year,
                        prior_year_amount,
                        ((Total_purchase_amount-prior_year_amount) / prior_year_amount) *100 AS YoY_percent
                    
                    FROM total_amount
                    WHERE Previous_year IS NOT NULL AND Year = Previous_year + 1
                )

SELECT 
        CustomerID,
        Year,
        Previous_year,
        Total_purchase_amount,
        prior_year_amount,
        YoY_percent  
FROM YOY
WHERE YoY_percent < -30
ORDER BY YoY_percent;

--  Query was adjusted in a way that those without purchase in the immediate previous year are not included 

-- 4.	Identify the average number of days between repeat purchases for each customer.

WITH Repeated_purchase AS   (SELECT  soh.CustomerID, 
                                    --p.Name,
                                    soh.SalesOrderID, 
                                    soh.orderDate,
                                    LAG(soh.OrderDate) OVER(PARTITION BY soh.CustomerId ORDER BY soh.orderDate) AS Previous_order_date      
                            FROM Sales.SalesOrderHeader soh
                            ),
                    
        Day_difference AS   (SELECT  
                                    CustomerID,
                                    SalesOrderID,
                                    OrderDate,
                                    Previous_order_date,
                                    DATEDIFF(DAY,OrderDate,Previous_order_date) AS Days_difference
                            FROM Repeated_purchase
                            )

SELECT  
        dd.CustomerID,
        FirstName + ' ' + LastName AS Fullname,
        ABS(AVG(Days_difference)) AS Avg_days 
FROM Day_difference dd
JOIN Sales.Customer sc ON dd.CustomerID = sc.CustomerID
JOIN Person.Person pp ON sc.PersonID = pp.BusinessEntityID
WHERE Previous_order_date IS NOT NULL
GROUP BY dd.CustomerID, FirstName + ' ' + LastName
ORDER BY Avg_days DESC;

-- 5.	Find the top 5 most common product categories purchased by customers.
SELECT 
        pc.Name,
        COUNT(*) AS product_count
FROM Sales.SalesOrderDetail sod 
JOIN Production.Product p ON sod.ProductID = p.ProductID
JOIN Production.ProductSubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
JOIN Production.ProductCategory pc ON ps.ProductCategoryID = pc.ProductCategoryID
GROUP BY pc.Name

SELECT  TOP 5
        ps.Name,
        COUNT(*)  AS product_count
FROM Sales.SalesOrderDetail sod 
JOIN Production.Product p ON sod.ProductID = p.ProductID
JOIN Production.ProductSubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
GROUP BY ps.Name
ORDER BY product_count DESC;

-- Sales Performance Analysis
-- 6.	Calculate total monthly sales revenue over the past three years.
SELECT  
        YEAR(soh.OrderDate) AS Year,
        MONTH(soh.OrderDate) AS Month,
        ROUND(SUM(sod.LineTotal),2) AS Total_revenue
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
WHERE YEAR(soh.OrderDate) IN (2014, 2013, 2012)
GROUP BY YEAR(soh.OrderDate), MONTH(soh.OrderDate)
ORDER BY [Year], [Month];

-- 7.	Identify the most profitable products in terms of total revenue.
SELECT TOP 1
    P.Name AS ProductName,
    ROUND(SUM(sod.LineTotal),2) AS Total_revenue
FROM Sales.SalesOrderDetail sod 
JOIN Production.Product p ON sod.ProductID = p.ProductID
JOIN Production.ProductSubcategory sc ON p.ProductSubcategoryID = sc.ProductSubcategoryID
JOIN Production.ProductCategory c ON sc.ProductCategoryID = c.ProductCategoryID
GROUP BY P.Name
ORDER BY Total_revenue DESC;

-- 8.	Determine the top 5 sales representatives based on total revenue generated.
SELECT  
        soh.SalesPersonID,
        pp.FirstName + ' ' + pp.LastName AS Fullname,
        ROUND(SUM(soh.TotalDue),2) AS Total_Sales
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesPerson sp ON soh.SalesPersonID = sp.BusinessEntityID
JOIN Person.Person pp ON sp.BusinessEntityID = pp.BusinessEntityID
GROUP BY soh.SalesPersonID, pp.FirstName + ' ' + pp.LastName
ORDER BY Total_Sales DESC;

SELECT  SalesPersonID,
        ROUND(SUM(TotalDue),2) AS Total_Sales
FROM Sales.SalesOrderHeader
GROUP BY SalesPersonID
ORDER BY Total_Sales DESC;
-- 9.	Calculate the year-over-year sales growth rate.
WITH Yearly_Sales AS (SELECT
    YEAR(OrderDate) AS Year,
    SUM(TotalDue) AS Total_Year_Sales,
    LAG(SUM(TotalDue)) OVER(ORDER BY YEAR(OrderDate))AS Prev_Year_Sales
    FROM Sales.SalesOrderHeader
GROUP BY YEAR(OrderDate)
)
SELECT 
        [Year],
        Total_Year_Sales,
        Prev_Year_Sales,
        (Total_Year_Sales - Prev_Year_Sales)/NULLIF(Prev_Year_Sales, 0) * 100  AS YoY_Growth
FROM Yearly_Sales
-- 10.	Identify the top 5 regions where AdventureWorks generates the most revenue.
SELECT TOP 5

        st.CountryRegionCode AS RegionCode,
        st.Name AS Region,
        ROUND(SUM(soh.TotalDue),2) AS Total_Revenue
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesTerritory st ON soh.TerritoryID = st.TerritoryID
GROUP BY st.CountryRegionCode, st.Name
ORDER BY Total_Revenue DESC;

-- Product and Inventory Insights
-- 11.	Find products frequently purchased together (appear in the same order).
-- 3 products that are ofthen bought together
WITH Purchased_together AS(
    SELECT 
        sod1.SalesOrderID,
        sod1.ProductID AS ProductA,
        sod2.ProductID AS ProductB,
        sod3.ProductID AS ProductC,
        pp1.Name AS ProductNameA,
        pp2.Name AS ProductNameB,
        pp3.Name AS ProductNameC
  
    FROM Sales.SalesOrderDetail  sod1
    JOIN Sales.SalesOrderDetail sod2 ON sod1.SalesOrderID = sod2.SalesOrderID AND sod1.ProductID < sod2.ProductID
    JOIN Sales.SalesOrderDetail sod3 ON sod2.SalesOrderID = sod3.SalesOrderID AND sod2.ProductID < sod3.ProductID
    JOIN Production.Product pp1 ON sod1.ProductID =pp1.ProductID
    JOIN Production.Product pp2 ON sod2.ProductID =pp2.ProductID
    JOIN Production.Product pp3 ON sod3.ProductID =pp3.ProductID  
)
SELECT 
    ProductNameA,
    ProductNameB,
    ProductNameC,
    COUNT(DISTINCT SalesOrderID) AS Pair_count
FROM Purchased_together
GROUP BY ProductNameA,ProductNameB, ProductNameC
ORDER BY Pair_count DESC;

-- 12.	Retrieve products that have never been sold.
SELECT 
		pp.Name AS Product_Name

FROM Production.Product pp
LEFT JOIN Sales.SalesOrderDetail sod ON pp.ProductID = sod.ProductID
WHERE sod.ProductID IS NULL -- This shows where product are not available in the salesorder 

-- 13.	Find the best-selling product in each category.
WITH Best_selling_rank AS(        
        SELECT 
                pc.Name AS ProductCategory,
                p.Name AS ProductName,        
                ROUND(SUM(sod.LineTotal),2) AS Total_Sales,
                DENSE_RANK() OVER(PARTITION BY pc.Name ORDER BY ROUND(SUM(sod.LineTotal),2) DESC) AS Sales_rank
        FROM Sales.SalesOrderDetail sod 
        JOIN Production.Product p ON sod.ProductID = p.ProductID
        JOIN Production.ProductSubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
        JOIN Production.ProductCategory pc ON ps.ProductCategoryID = pc.ProductCategoryID
        GROUP BY pc.Name, p.Name, sod.LineTotal
)

SELECT 
        ProductCategory,
        ProductName,
        Total_Sales
FROM Best_selling_rank
WHERE Sales_rank = 1
ORDER BY Total_Sales DESC;

-- 14.	Identify the most returned products based on order cancellations.
SELECT DISTINCT [Status]
FROM Sales.SalesOrderHeader ;
-- 15.	Find products with the highest order quantities but lowest total revenue.
WITH OrderDetails AS(
        SELECT 
                ProductID,
                SUM(OrderQty) AS Total_order_qty,
                SUM(LineTotal) AS Total_revenue

        FROM Sales.SalesOrderDetail sod 
        GROUP BY ProductID
)
SELECT *,
        Total_revenue/Total_order_qty AS Avg_revenue_per_unit
FROM OrderDetails
ORDER BY Total_order_qty DESC, Total_revenue;

SELECT COUNT(OrderQty) 
FROM Sales.SalesOrderDetail
WHERE ProductID = 712; 

SELECT SUM(OrderQty) 
FROM Sales.SalesOrderDetail
WHERE ProductID = 712; 

-- Advanced Business Insights
-- 16.	Calculate the monthly sales growth rate using a window function.

WITH MonthlyGrowth AS (
        SELECT
                YEAR(OrderDate) AS Year,
                MONTH(OrderDate) AS Month,
                SUM(TotalDue) AS MonthlySales,
                LAG(SUM(TotalDue)) OVER(ORDER BY YEAR(OrderDate),MONTH(OrderDate))AS PrevMonthSales
        FROM Sales.SalesOrderHeader
        GROUP BY YEAR(OrderDate), MONTH(OrderDate)
)
SELECT 
        [Year],
        [Month],
        MonthlySales,
        PrevMonthSales,
        (MonthlySales - PrevMonthSales)/NULLIF(PrevMonthSales, 0) * 100  AS MoM_Growth
FROM MonthlyGrowth
-- 17.	Identify customers who purchased the same product multiple times in different orders.
SELECT   
        soh.CustomerId,
        pp.FirstName + ' ' + pp.LastName AS Fullname,  
        sod.ProductID,
        p.Name AS Product_name,
        COUNT(DISTINCT sod.SalesOrderID) AS order_frequency
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON sod.SalesOrderID = soh.SalesOrderID
JOIN Sales.Customer sc ON soh.CustomerID =sc.CustomerID
JOIN Person.Person pp ON sc.PersonID = pp.BusinessEntityID
JOIN Production.Product p ON sod.ProductID = p.ProductID
GROUP BY soh.CustomerID, pp.FirstName + ' ' + pp.LastName, sod.ProductID,  p.Name
HAVING COUNT(DISTINCT sod.SalesOrderID) > 1

-- 18.	Compute a 3-month moving average revenue per sales representative.
WITH moving_average AS (
                SELECT  
                        soh.SalesPersonID,
                        YEAR(soh.OrderDate) AS Year,
                        MONTH(soh.OrderDate) AS Month,
                        pp.FirstName + ' ' + pp.LastName AS Fullname,
                        ROUND(SUM(soh.TotalDue),2) AS monthly_Sales,
                        AVG(SUM(soh.TotalDue)) OVER(PARTITION BY soh.SalesPersonID ORDER BY YEAR(soh.OrderDate), MONTH(soh.OrderDate) 
                        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS three_month_ma 
                FROM Sales.SalesOrderHeader soh
                JOIN Sales.SalesPerson sp ON soh.SalesPersonID = sp.BusinessEntityID
                JOIN Person.Person pp ON sp.BusinessEntityID = pp.BusinessEntityID
                GROUP BY soh.SalesPersonID, pp.FirstName + ' ' + pp.LastName, YEAR(soh.OrderDate),MONTH(soh.OrderDate)
)

SELECT 
        Fullname,
        [Year],
        [Month],
        monthly_Sales,
        three_month_ma
FROM moving_average;

-- 19.	Find frequently purchased product pairs using self-joins.
WITH Purchased_together AS(
    SELECT 
        sod1.SalesOrderID,
        sod1.ProductID AS ProductA,
        sod2.ProductID AS ProductB,
        pp1.Name AS ProductNameA,
        pp2.Name AS ProductNameB
  
    FROM Sales.SalesOrderDetail  sod1
    JOIN Sales.SalesOrderDetail sod2 ON sod1.SalesOrderID = sod2.SalesOrderID AND sod1.ProductID < sod2.ProductID
    JOIN Production.Product pp1 ON sod1.ProductID =pp1.ProductID
    JOIN Production.Product pp2 ON sod2.ProductID =pp2.ProductID 
)
SELECT 
    ProductNameA,
    ProductNameB,
    COUNT(*) AS Pair_count
FROM Purchased_together
GROUP BY ProductNameA,ProductNameB
ORDER BY Pair_count DESC;

-- 20.	Detect customers whose spending has declined significantly over time.
WITH total_amount AS (
                        SELECT  
                                soh.CustomerId,
                                pp.FirstName + ' ' + pp.LastName AS Fullname,
                                YEAR(soh.orderDate) AS Year,
                                ROUND(SUM(soh.TotalDue),2) AS Total_purchase_amount,
                                LAG(YEAR(soh.orderDate), 1) OVER (PARTITION BY soh.CustomerID ORDER BY YEAR(soh.orderDate)) AS Previous_year,
                                LEAD(YEAR(soh.orderDate), 1) OVER (PARTITION BY soh.CustomerID ORDER BY YEAR(soh.orderDate)) AS _year,
                                LAG(ROUND(SUM(soh.TotalDue),2),1) OVER(PARTITION BY soh.CustomerId ORDER BY YEAR(soh.orderDate)) AS prior_year_amount
                        FROM Sales.SalesOrderHeader soh
                        JOIN Sales.SalesOrderDetail sod ON sod.SalesOrderID = soh.SalesOrderID
                        JOIN Sales.Customer sc ON soh.CustomerID = sc.CustomerID
                        JOIN Person.Person pp ON sc.PersonID = pp.BusinessEntityID
                        GROUP BY soh.CustomerId, pp.FirstName + ' ' + pp.LastName, YEAR(soh.orderDate)  
                     ),

            YOY AS (
                    SELECT
                        CustomerId,
                        Fullname,
                        _year,
                        Year,
                        Total_purchase_amount,
                        Previous_year,
                        prior_year_amount,
                        ((Total_purchase_amount-prior_year_amount) / prior_year_amount) *100 AS YoY_percent
                    
                    FROM total_amount
                    )

SELECT 
        CustomerID,
        Fullname,
        _year,
        Year,
        Previous_year,
        Total_purchase_amount,
        prior_year_amount,
        YoY_percent  
FROM YOY
WHERE YoY_percent < -30
ORDER BY YoY_percent;
