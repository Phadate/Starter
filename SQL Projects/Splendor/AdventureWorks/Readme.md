# Sales and Customer Behavior Analysis Report

## Introduction

This report explores and analyzes the **AdventureWorks2019** database to uncover insights into sales trends and customer behavior. The findings will support data-driven decision-making and provide actionable recommendations to improve business performance.

**AdventureWorks2019** is a sample **Online Transaction Processing (OLTP)** database provided by Microsoft. It supports a fictional manufacturing multinational corporation, **Adventure Works Cycles**, and serves as an excellent resource for practicing and learning SQL. The analysis was conducted using **SQL Server**, and visualizations were created in **Excel**.

---

## Data Description

The database consists of **72 tables**, but only **9 tables** were used for this analysis:

1. **Sales.SalesOrderHeader**  
   Contains general information about sales orders. The primary key is **SalesOrderID**, which links to the **Sales.SalesOrderDetail** table. Key columns include **CustomerID**, **SalesPersonID**, and **TerritoryID**.

2. **Sales.SalesOrderDetail**  
   Tracks individual products within each sales order. The primary key is **SalesOrderDetailID**, and it links to **Sales.SalesOrderHeader** via **SalesOrderID**.

3. **Sales.Customer**  
   Stores customer records. The primary key is **CustomerID**, which links to **Sales.SalesOrderHeader**. The **PersonID** column connects to the **Person.Person** table.

4. **Sales.SalesPerson**  
   Contains salesperson records. The primary key is **BusinessEntityID**, which links to **Sales.SalesOrderHeader** via **SalesPersonID**.

5. **Sales.SalesTerritory**  
   Lists sales territories. The primary key is **TerritoryID**, which links to **Sales.Customer**, **Sales.SalesOrderHeader**, and **Sales.SalesPerson**.

6. **Production.Product**  
   Tracks product details such as **Name** and **Color**. The primary key is **ProductID**, which links to **Sales.SalesOrderDetail**. The **ProductSubcategoryID** column connects to **Production.ProductSubCategory**.

7. **Production.ProductSubCategory**  
   Contains product subcategories. The primary key is **ProductSubcategoryID**, which links to **Production.Product**. The **ProductCategoryID** column connects to **Production.ProductCategory**.

8. **Production.ProductCategory**  
   Lists product categories. The primary key is **ProductCategoryID**, which links to **Production.ProductSubCategory**.

9. **Person.Person**  
   Stores basic customer and employee information, such as **FirstName** and **LastName**. The primary key is **BusinessEntityID**, which links to **Sales.Customer**.

---

## Analysis and Insights

### Customer Behavior Analysis

1. **Top 10 Customers by Total Purchase Amount**  

```SQL
SELECT TOP 10 
        soh.CustomerID,
        pp.FirstName + ' ' + pp.LastName AS Fullname, 
        ROUND(SUM(soh.TotalDue),2) AS Total_purchase_amount
FROM Sales.SalesOrderHeader soh
JOIN Sales.Customer sc ON soh.CustomerID =sc.CustomerID
JOIN Person.Person pp ON sc.PersonID = pp.BusinessEntityID
GROUP BY soh.CustomerID, pp.FirstName + ' ' + pp.LastName 
ORDER BY Total_purchase_amount DESC;

```
   - The top 10 customers spent between **$820K and $990K**, with **Roger Harui** leading at **$989.2K**.  
   - The top 5 customers (Roger Harui to Ryan Calafato) spent over **$900K**, while the next 5 (Joseph Castellucio to Stacey Cereghino) spent between **$820K and $887K**. This indicates a clear distinction between the top-tier and mid-tier high-value customers
   - The top 10 customers collectively contributed **~$8.9M** in revenue. This highlights the importance of retaining and nurturing these high-value customers, as they drive a significant portion of the company's revenue

#### **Recommendations** 
Target these high-value customers with premium products, exclusive offers, or loyalty programs.

- **Personalized Engagement**  
   - Assign dedicated account managers or customer success teams to these high-value customers.  
   - Offer personalized recommendations based on their purchase history.

- **Exclusive Offers**  
   - Provide early access to new products, limited-edition items, or VIP discounts.  
   - Create loyalty programs tailored to their spending habits.

- **Upselling Opportunities**  
   - Promote premium or high-margin products to these customers.  
   - Bundle complementary products to increase average order value.

2. **Customers Who Made Repeat Purchases**  
   - Only **1,153 out of 19,820 customers** made repeat purchases of the same product.  
   - **Recommendation:** Improve customer engagement through personalized follow-ups, promotions, and reminders.

3. **Customers with a 30% Drop in Spending**  
   - **2,947 customers** (14% of the total) experienced a **30% or greater decline** in spending compared to the previous year.  
   - **Recommendation:** Investigate external factors (e.g., economic conditions, competition) and offer win-back incentives.

4. **Average Days Between Repeat Purchases**  
   - **7,470 customers** returned for repeat purchases, with an average gap of **months to years**.  
   - **Recommendation:** Introduce subscription models or maintenance packages for durable products like bikes.

5. **Top 5 Most Common Product Categories**  
   - **Bikes** led with **90.3K units sold**, followed by **Clothing (73.7K)**, **Accessories (61.9K)**, and **Components (49.0K)**.  
   - **Recommendation:** Focus marketing efforts on high-demand categories like bikes and clothing.

---

### Sales Performance Analysis

6. **Monthly Sales Revenue Over Three Years**  
   - Revenue grew from **2011 to 2013**, peaking in **June 2013 ($5.72M)**. However, it dropped sharply in **June 2014 ($54K)**.  
   - **Recommendation:** Investigate the cause of the 2014 decline and implement strategies to stabilize revenue.

7. **Most Profitable Products**  
   - The **Mountain-200 Black, 38** bike generated the highest revenue at **$4.40M**.  
   - **Recommendation:** Expand stock and promote similar high-performing models.

8. **Top 5 Sales Representatives**  
   - **Linda Mitchell** led with **$11.70M** in revenue, followed closely by **Jillian Carson ($11.34M)**.  
   - **Recommendation:** Reward top performers and share best practices across the sales team.

9. **Year-over-Year Sales Growth Rate**  
   - Revenue grew by **166% in 2012** but declined by **54% in 2014**.  
   - **Recommendation:** Analyze market trends and adjust strategies to sustain growth.

10. **Top 5 Revenue-Generating Regions**  
    - **Southwest, North America** dominated with **$27.15M**, followed by **Canada ($18.40M)**.  
    - **Recommendation:** Focus on expanding market share in underperforming regions.

---

### Product and Inventory Insights

11. **Frequently Purchased Product Pairs**  
    - **Bottles and Cages** were the most frequently purchased pair, with over **1,500 orders**.  
    - **Recommendation:** Bundle complementary products to increase sales.

12. **Products Never Sold**  
    - **238 out of 504 products** (47%) have never been sold.  
    - **Recommendation:** Phase out underperforming products or improve their visibility through promotions.

13. **Best-Selling Products by Category**  
    - **Mountain-200 Black, 38** (Bikes), **AWC Logo Cap** (Clothing), and **Water Bottle — 30 oz.** (Accessories) were top performers.  
    - **Recommendation:** Leverage bestsellers to drive sales of related products.

14. **Most Returned Products**  
    - No products were returned, indicating effective quality control.  
    - **Recommendation:** Maintain current standards to minimize returns.

15. **High-Volume, Low-Revenue Products**  
    - **32 products** had high order quantities but low revenue.  
    - **Recommendation:** Bundle these items with higher-margin products or introduce premium variants.

---

### Advanced Business Insights

16. **Monthly Sales Growth Rate**  
    - Revenue fluctuated significantly, with strong growth in **June 2013 (57%)** and sharp declines in **August 2013 (-32%)**.  
    - **Recommendation:** Optimize inventory and promotions based on seasonal trends.

17. **Customers Purchasing the Same Product Multiple Times**  
    - **1,153 customers** purchased the same product multiple times.  
    - **Recommendation:** Introduce loyalty programs to encourage repeat purchases.

18. **3-Month Moving Average Revenue per Sales Representative**  
    - Salesperson performance varied, with significant fluctuations in monthly revenue.  
    - **Recommendation:** Provide additional training and resources to improve consistency.

19. **Frequently Purchased Product Pairs**  
    - **Helmets and Jerseys** were frequently paired, indicating a demand for full cycling gear sets.  
    - **Recommendation:** Create bundled offers for complementary products.

20. **Customers with Declining Spending**  
    - **193 customers** experienced a significant decline in spending over two consecutive years.  
    - **Recommendation:** Re-engage these customers with personalized offers and incentives.

---

## Recommendations

1. **Increase Repeat Purchases**  
   - Implement loyalty programs, personalized discounts, and targeted email campaigns.

2. **Address Customer Drop-Off**  
   - Analyze purchase history and offer win-back incentives or personalized recommendations.

3. **Optimize Product Offerings**  
   - Phase out underperforming products or bundle them with bestsellers.

4. **Boost High-Volume, Low-Revenue Products**  
   - Introduce bundling strategies or premium variants to increase profitability.

5. **Enhance Top-Selling Product Performance**  
   - Offer limited-edition versions or premium add-ons for bestsellers.

6. **Improve Regional Sales Strategies**  
   - Expand marketing efforts in underperforming regions.

7. **Leverage Seasonal Trends**  
   - Optimize inventory and promotions based on historical sales patterns.

8. **Target High-Value Customers**  
   - Offer exclusive perks and early access to new products.

9. **Address Pricing and Product Gaps**  
   - Introduce mid-tier products to capture a broader customer base.

---

## Conclusion

This analysis provides valuable insights into customer behavior, sales performance, and product trends. By implementing the recommendations outlined above, **Adventure Works Cycles** can enhance customer retention, optimize inventory, and drive revenue growth.

---
