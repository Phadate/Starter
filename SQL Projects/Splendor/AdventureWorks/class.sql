-- CASE STATEMENTS

-- THE CASE STATEMENT IN SQL IS USED TO CREATE CONDITIONAL LOGIC WITHIN QUERIES.
-- IT ALLOWS US TO RETURN DIFFERENT VALUES BASED ON CONDITIONS.

/*

CASE
    WHEN condition1 THEN result1
    WHEN condition2 THEN result2
    ELSE default_value
END 


-- WHEN defines the condition
-- THEN specifies the value to return if the condition is met
-- ELSE provides a default value if none of the conditions match

*/

SELECT * FROM Production.Product;

-- CATEGORIZE PRODUCTS BASED ON THEIR LISTPRICE


SELECT 
    Name,
    ListPrice,
    CASE 
        WHEN ListPrice = 0 THEN 'Free'
        WHEN ListPrice BETWEEN 1 AND 100 THEN 'Budget'
        WHEN ListPrice BETWEEN 101 AND 500 THEN 'Mid-Range'
        ELSE 'Premium'
    END AS PriceCategory
FROM Production.Product;

-- USING CASE IN AGGREGATION 

SELECT 
    CASE 
        WHEN ListPrice = 0 THEN 'Free'
        WHEN ListPrice BETWEEN 1 AND 100 THEN 'Budget'
        WHEN ListPrice BETWEEN 101 AND 500 THEN 'Mid-Range'
        ELSE 'Premium'
    END AS PriceCategory,
    COUNT(*) AS ProductCount
FROM Production.Product
GROUP BY CASE 
        WHEN ListPrice = 0 THEN 'Free'
        WHEN ListPrice BETWEEN 1 AND 100 THEN 'Budget'
        WHEN ListPrice BETWEEN 101 AND 500 THEN 'Mid-Range'
        ELSE 'Premium'
    END
ORDER BY ProductCount DESC;



-- USING CASE IN FILTERING (WHERE CLAUSE)

SELECT Name, ListPrice
FROM Production.Product
WHERE 
    CASE 
        WHEN ListPrice> 500 THEN 'Premium'
        ELSE 'Other'
    END = 'Premium'
ORDER BY ListPrice DESC;


-- USING THE CASE IN CALCLUALTED FIELDS

SELECT
    Name,
    ListPrice,
    CASE
        WHEN ListPrice >= 500 THEN ListPrice * 0.90 -- 10% discount
        WHEN ListPrice BETWEEN 100 AND 499 then ListPrice * 0.95 -- 5% discount
        ELSE ListPrice -- NO DISCOUNT
    END AS DiscountPrice
FROM Production.Product;


-- NESTED CASE STATEMENTS

SELECT 
    Name,
    ListPrice,
    CASE 
        WHEN ListPrice = 0 THEN 'Free'
        WHEN ListPrice BETWEEN 1 AND 100 THEN 'Budget'
        WHEN ListPrice BETWEEN 101 AND 500 THEN 'Mid-Range'
        WHEN ListPrice BETWEEN 501 AND 1000 THEN 'Premium'
        ELSE 
            CASE 
                WHEN ListPrice > 1000 THEN 'Luxury'
                ELSE 'Other'
            END
    END AS PriceCategory
FROM Production.Product;



-- USING CASE IN JOIN CONDITIONS

SELECT
    sod.SalesOrderID,
    p.Name AS ProductName,
    sod.OrderQty,
    sod.LineTotal,
    CASE 
        WHEN sod.OrderQty >= 10 THEN 'Bulk Order'
        WHEN sod.OrderQty BETWEEN 5 AND 9 THEN 'Medium Order'
        ELSE 'Small Order'
    END AS OrderCategory
FROM Sales.SalesOrderDetail sod 
JOIN Production.Product p ON sod.ProductID = p.ProductID;


-- REVENUE CONTRIBUTION BY EACH PRODUCT CATEGORY



SELECT
    c.Name AS CategoryName,
    SUM(SOD.LineTotal) AS TotalRevenue,
    ROUND(100.0 * SUM(SOD.LineTotal) / SUM(SUM(SOD.LineTotal)) OVER(), 2) AS RevenuePercentage
FROM Sales.SalesOrderDetail sod 
JOIN Production.Product p ON sod.ProductID = p.ProductID
JOIN Production.ProductSubcategory sc ON p.ProductSubcategoryID = sc.ProductSubcategoryID
JOIN Production.ProductCategory c ON sc.ProductCategoryID = c.ProductCategoryID
GROUP BY c.Name;




-- WINDOW FUNCTIONS
-- ANALYTICAL FUNCTIONS

-- WINDOW FUNCTION PERFORMS CALCULATIONS ACROSS A SET OF ROWS RELATED TO THE CURRENT ROW WITHOUT COLLAPSING THE RESULT INTO A SINGLE OUTPUT LIKE AGGREGATE 
-- FUNCTIONS
-- THEY LET US COMPUTE RUNNING TOTALS, RANKINGS, MOVING AVERAGES AND PERCENTAGES


-- TYPES OF WINDOW FUNCTIONS

-- AGGREGATE WINDOW FUNCTIONS
-- SUM(), AVG(), COUNT(), MIN(), MAX()
-- COMPUTE CUMMUMLATIVE VALUES OVER A WINDOW

-- RANKING WINDOWS FUNCTIONS 
-- RANK(), DENSE_RANK(), ROW_NUMBER()
-- ASSIGN RANKS TO ROWS BAED ON ORDER

-- VALUE BASED WINDOW FUNCTIONS
-- LAG(), LEAD(), FIRST_VALUE(), LAST_VALUE()
-- RETRIEVE PREVIOUS, NEXT OR SPECIFIC ROW VALUES

-- STATISTICAL/NTH VALUE FUNCTIONS
-- NTILE()
-- PERFORM PERCENTILE OR DISTRIBUTION CALCULATIONS


-- RUNNING TOTAL OF SALES

SELECT
    SalesOrderID,
    CustomerID,
    OrderDate,
    TotalDue,
    SUM(TotalDue) OVER (PARTITION BY CustomerID ORDER BY OrderDate) AS RunningTotal
FROM Sales.SalesOrderHeader 
ORDER BY CustomerID, OrderDate;


-- MOVING AVERAGE


SELECT
    SalesOrderID,
    CustomerID,
    OrderDate,
    TotalDue,
    AVG(TotalDue) OVER (PARTITION BY CustomerID ORDER BY OrderDate ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS MovingAvg
FROM Sales.SalesOrderHeader 
ORDER BY CustomerID, OrderDate;


-- RANK

SELECT
    SalesOrderID,
    CustomerID,
    OrderDate,
    TotalDue,
    RANK() OVER (ORDER BY TotalDue DESC) AS Rank
FROM Sales.SalesOrderHeader 


SELECT
    SalesOrderID,
    CustomerID,
    OrderDate,
    TotalDue,
    ROW_NUMBER() OVER (ORDER BY TotalDue DESC) AS ROWnUM
FROM Sales.SalesOrderHeader 

-- LEAD AND LAG

SELECT
    YEAR(OrderDate) AS Year,
    MONTH(OrderDate) AS Month,
    SUM(TotalDue) AS MonthlySales,
    LAG(SUM(TotalDue)) OVER(
        ORDER BY YEAR(OrderDate), MONTH(OrderDate)
    )AS PrevMonthSales,
    (SUM(TotalDue) - lag(SUM(TotalDue)) OVER(
        ORDER BY YEAR(OrderDate), MONTH(OrderDate)
    ))/NULLIF(LAG(SUM(TotalDue)) OVER (
        ORDER BY YEAR(OrderDate), MONTH(OrderDate)
    ), 0) * 100  AS MoM_Growth
FROM Sales.SalesOrderHeader
GROUP BY YEAR(OrderDate), MONTH(OrderDate)
ORDER BY [Year], [Month];

-- VIEWS


-- CREATE VIEW MoM_Growth AS 
-- SELECT
--     YEAR(OrderDate) AS Year,
--     MONTH(OrderDate) AS Month,
--     SUM(TotalDue) AS MonthlySales,
--     LAG(SUM(TotalDue)) OVER(
--         ORDER BY YEAR(OrderDate), MONTH(OrderDate)
--     )AS PrevMonthSales,
--     (SUM(TotalDue) - lag(SUM(TotalDue)) OVER(
--         ORDER BY YEAR(OrderDate), MONTH(OrderDate)
--     ))/NULLIF(LAG(SUM(TotalDue)) OVER (
--         ORDER BY YEAR(OrderDate), MONTH(OrderDate)
--     ), 0) * 100  AS MoM_Growth
-- FROM Sales.SalesOrderHeader
-- GROUP BY YEAR(OrderDate), MONTH(OrderDate)


SELECT * FROM MoM_Growth;