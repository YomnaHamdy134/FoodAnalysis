USE NTI_food
SELECT
    SUM(CASE WHEN transaction_date IS NULL THEN 1 ELSE 0 END) AS Null_Transaction_Date,
    SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS Null_Customer,
    SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) AS Null_Product,
    SUM(CASE WHEN store_id IS NULL THEN 1 ELSE 0 END) AS Null_Store,
    SUM(CASE WHEN quantity IS NULL THEN 1 ELSE 0 END) AS Null_Quantity
FROM Sales;


DELETE FROM Sales
WHERE transaction_date IS NULL
   OR customer_id IS NULL
   OR product_id IS NULL
   OR store_id IS NULL;


   UPDATE Sales
SET quantity = ABS(quantity)
WHERE quantity < 0


DELETE FROM Sales
WHERE quantity = 0;


WITH Duplicates AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY transaction_date, customer_id, product_id, store_id
               ORDER BY transaction_date
           ) AS rn
    FROM Sales
)
DELETE FROM Duplicates
WHERE rn > 1;



DELETE s
FROM Sales s
LEFT JOIN Products p ON s.product_id = p.product_id
WHERE p.product_id IS NULL;



DELETE s
FROM Sales s
LEFT JOIN Customers c ON s.customer_id = c.customer_id
WHERE c.customer_id IS NULL;



DELETE s
FROM Sales s
LEFT JOIN Stores st ON s.store_id = st.store_id
WHERE st.store_id IS NULL;



UPDATE Products
SET product_brand = UPPER(LTRIM(RTRIM(product_brand)));



UPDATE Stores
SET store_type = UPPER(LTRIM(RTRIM(store_type)));



SELECT *
FROM Sales
WHERE quantity >
(
    SELECT AVG(quantity) + 3 * STDEV(quantity)
    FROM Sales
);



SELECT TOP 5 * 
FROM sales;


SELECT 
    COUNT(*) AS total_transactions,
    SUM(quantity) AS total_quantity,
    COUNT(DISTINCT customer_id) AS unique_customers,
    COUNT(DISTINCT product_id) AS unique_products,
    COUNT(DISTINCT store_id) AS unique_stores
FROM sales;



SELECT 
    YEAR(transaction_date) AS year,
    COUNT(*) AS transaction_count,
    SUM(quantity) AS total_quantity,
    COUNT(DISTINCT customer_id) AS unique_customers
FROM sales
GROUP BY YEAR(transaction_date)
ORDER BY year DESC;



SELECT
    YEAR(Transaction_Date) AS [Year],
    MONTH(Transaction_Date) AS [Month],
    COUNT(*) AS Transaction_Count,
    SUM(Quantity) AS Total_Quantity
FROM Sales
GROUP BY YEAR(Transaction_Date), MONTH(Transaction_Date)
ORDER BY [Year] DESC, [Month] DESC;



SELECT
    YEAR(Transaction_Date) AS [Year],
    CASE
        WHEN MONTH(Transaction_Date) BETWEEN 1 AND 3 THEN 'Q1'
        WHEN MONTH(Transaction_Date) BETWEEN 4 AND 6 THEN 'Q2'
        WHEN MONTH(Transaction_Date) BETWEEN 7 AND 9 THEN 'Q3'
        ELSE 'Q4'
    END AS Quarter,
    COUNT(*) AS Transaction_Count,
    SUM(Quantity) AS Total_Quantity
FROM Sales
GROUP BY
    YEAR(Transaction_Date),
    CASE
        WHEN MONTH(Transaction_Date) BETWEEN 1 AND 3 THEN 'Q1'
        WHEN MONTH(Transaction_Date) BETWEEN 4 AND 6 THEN 'Q2'
        WHEN MONTH(Transaction_Date) BETWEEN 7 AND 9 THEN 'Q3'
        ELSE 'Q4'
    END
ORDER BY [Year] DESC, Quarter;



SELECT TOP 20
    Product_Id,
    SUM(Quantity) AS Total_Quantity,
    COUNT(*) AS Transactions
FROM Sales
GROUP BY Product_Id
ORDER BY Total_Quantity DESC;


SELECT TOP 10
    Product_Id,
    SUM(Quantity) AS Total_Quantity
FROM Sales
GROUP BY Product_Id
ORDER BY Total_Quantity ASC;



SELECT TOP 50
    Customer_Id,
    SUM(Quantity) AS Total_Units,
    COUNT(*) AS Transactions,
    COUNT(DISTINCT Store_Id) AS Stores_Visited
FROM Sales
GROUP BY Customer_Id
ORDER BY Total_Units DESC;



SELECT
    CASE
        WHEN COUNT(*) >= 50 THEN 'Very Active'
        WHEN COUNT(*) >= 20 THEN 'Active'
        WHEN COUNT(*) >= 5 THEN 'Occasional'
        ELSE 'Rare'
    END AS Customer_Segment,
    COUNT(*) AS Customers
FROM (
    SELECT Customer_Id, COUNT(*) AS Cnt
    FROM Sales
    GROUP BY Customer_Id
) x
GROUP BY
    CASE
        WHEN Cnt >= 50 THEN 'Very Active'
        WHEN Cnt >= 20 THEN 'Active'
        WHEN Cnt >= 5 THEN 'Occasional'
        ELSE 'Rare'
    END;





    SELECT
    Store_Id,
    SUM(Quantity) AS Total_Units,
    COUNT(*) AS Transactions,
    COUNT(DISTINCT Customer_Id) AS Unique_Customers
FROM Sales
GROUP BY Store_Id
ORDER BY Total_Units DESC;



SELECT TOP 30
    s1.Product_Id AS Product_1,
    s2.Product_Id AS Product_2,
    COUNT(*) AS Co_Purchase_Count
FROM Sales s1
JOIN Sales s2
    ON s1.Customer_Id = s2.Customer_Id
    AND s1.Transaction_Date = s2.Transaction_Date
    AND s1.Product_Id < s2.Product_Id
GROUP BY s1.Product_Id, s2.Product_Id
ORDER BY Co_Purchase_Count DESC;




SELECT
    MONTH(Transaction_Date) AS [Month],
    SUM(Quantity) AS Total_Units,
    COUNT(*) AS Transactions
FROM Sales
GROUP BY MONTH(Transaction_Date)
ORDER BY [Month];



SELECT
    DATENAME(WEEKDAY, Transaction_Date) AS Day_Name,
    SUM(Quantity) AS Total_Units
FROM Sales
GROUP BY DATENAME(WEEKDAY, Transaction_Date)
ORDER BY Total_Units DESC;




SELECT
    Customer_Id,
    DATEDIFF(DAY, MAX(Transaction_Date), (SELECT MAX(Transaction_Date) FROM Sales)) AS Recency_Days,
    COUNT(*) AS Frequency,
    SUM(Quantity) AS Monetary_Units
FROM Sales
GROUP BY Customer_Id
ORDER BY Monetary_Units DESC;




SELECT 
    p.product_brand,
    SUM(s.quantity * p.product_retail_price) AS Total_Revenue,
    SUM(s.quantity * p.product_cost) AS Total_Cost,
    SUM(s.quantity * (p.product_retail_price - p.product_cost)) AS Total_Profit,
    (SUM(s.quantity * (p.product_retail_price - p.product_cost)) / SUM(s.quantity * p.product_retail_price)) * 100 AS Profit_Margin_Percentage
FROM Sales s
JOIN Products p ON s.product_id = p.product_id
GROUP BY p.product_brand
ORDER BY Total_Profit DESC;




SELECT 
    r.sales_region,
    r.sales_district,
    COUNT(s.transaction_date) AS Total_Transactions,
    SUM(s.quantity) AS Total_Units_Sold,
    COUNT(DISTINCT s.store_id) AS Number_of_Stores
FROM Sales s
JOIN Stores st ON s.store_id = st.store_id
JOIN Region r ON st.region_id = r.region_id
GROUP BY r.sales_region, r.sales_district
ORDER BY Total_Units_Sold DESC;





SELECT 
    p.product_name,
    p.product_brand,
    SUM(r.quantity) AS Total_Returned_Quantity,
    COUNT(*) AS Return_Transactions
FROM Returns r
JOIN Products p ON r.product_id = p.product_id
GROUP BY p.product_name, p.product_brand
ORDER BY Total_Returned_Quantity DESC;




SELECT 
    c.yearly_income,
    c.education,
    COUNT(DISTINCT s.customer_id) AS Unique_Customers,
    SUM(s.quantity) AS Total_Quantity_Purchased,
    SUM(s.quantity * (p.product_retail_price - p.product_cost)) AS Total_Profit_Contribution
FROM Sales s
JOIN Customers c ON s.customer_id = c.customer_id
JOIN Products p ON s.product_id = p.product_id
GROUP BY c.yearly_income, c.education
ORDER BY Total_Profit_Contribution DESC;




SELECT 
    st.store_type,
    COUNT(DISTINCT st.store_id) AS Store_Count,
    SUM(s.quantity) AS Total_Units,
    AVG(s.quantity) AS Avg_Units_Per_Transaction
FROM Sales s
JOIN Stores st ON s.store_id = st.store_id
GROUP BY st.store_type
ORDER BY Total_Units DESC;




SELECT 
    CASE WHEN p.low_fat = 1 THEN 'Low Fat' ELSE 'Regular' END AS Product_Type,
    SUM(s.quantity) AS Total_Units_Sold,
    COUNT(DISTINCT s.product_id) AS Product_Count
FROM Sales s
JOIN Products p ON s.product_id = p.product_id
GROUP BY p.low_fat;




WITH CustomerMetrics AS (
    SELECT 
        customer_id,
        DATEDIFF(DAY, MAX(transaction_date), (SELECT MAX(transaction_date) FROM Sales)) AS Recency,
        COUNT(*) AS Frequency,
        SUM(quantity) AS Monetary -- Using quantity as a proxy for monetary if price is not in Sales table
    FROM Sales
    GROUP BY customer_id
)
SELECT 
    customer_id,
    Recency,
    Frequency,
    Monetary,
    NTILE(4) OVER (ORDER BY Recency DESC) AS R_Score, -- 4 is best (most recent)
    NTILE(4) OVER (ORDER BY Frequency ASC) AS F_Score, -- 4 is best (most frequent)
    NTILE(4) OVER (ORDER BY Monetary ASC) AS M_Score  -- 4 is best (highest quantity)
FROM CustomerMetrics
ORDER BY Frequency DESC;




WITH MonthlySales AS (
    SELECT 
        YEAR(transaction_date) AS SalesYear,
        MONTH(transaction_date) AS SalesMonth,
        SUM(quantity) AS TotalUnits
    FROM Sales
    GROUP BY YEAR(transaction_date), MONTH(transaction_date)
)
SELECT 
    SalesYear,
    SalesMonth,
    TotalUnits,
    LAG(TotalUnits) OVER (ORDER BY SalesYear, SalesMonth) AS PreviousMonthUnits,
    CAST((TotalUnits - LAG(TotalUnits) OVER (ORDER BY SalesYear, SalesMonth)) * 100.0 / 
         NULLIF(LAG(TotalUnits) OVER (ORDER BY SalesYear, SalesMonth), 0) AS DECIMAL(10,2)) AS Growth_Percentage
FROM MonthlySales;



SELECT 
    st.store_name,
    st.total_sqft,
    SUM(s.quantity * (p.product_retail_price - p.product_cost)) AS Total_Profit,
    SUM(s.quantity * (p.product_retail_price - p.product_cost)) / st.total_sqft AS Profit_per_Sqft
FROM Sales s
JOIN Stores st ON s.store_id = st.store_id
JOIN Products p ON s.product_id = p.product_id
GROUP BY st.store_name, st.total_sqft
ORDER BY Profit_per_Sqft DESC;




WITH RegionalBrandSales AS (
    SELECT 
        r.sales_region,
        p.product_brand,
        SUM(s.quantity) AS TotalUnits,
        ROW_NUMBER() OVER (PARTITION BY r.sales_region ORDER BY SUM(s.quantity) DESC) AS Rank
    FROM Sales s
    JOIN Stores st ON s.store_id = st.store_id
    JOIN Region r ON st.region_id = r.region_id
    JOIN Products p ON s.product_id = p.product_id
    GROUP BY r.sales_region, p.product_brand
)
SELECT sales_region, product_brand, TotalUnits
FROM RegionalBrandSales
WHERE Rank = 1;




SELECT 
    p.product_brand,
    SUM(s.quantity) AS Total_Sold,
    ISNULL(ret.Total_Returned, 0) AS Total_Returned,
    CAST(ISNULL(ret.Total_Returned, 0) * 100.0 / SUM(s.quantity) AS DECIMAL(10,2)) AS Return_Rate_Percentage
FROM Sales s
JOIN Products p ON s.product_id = p.product_id
LEFT JOIN (
    SELECT product_id, SUM(quantity) AS Total_Returned
    FROM Returns
    GROUP BY product_id
) ret ON s.product_id = ret.product_id
GROUP BY p.product_brand, ret.Total_Returned
HAVING SUM(s.quantity) > 100 -- Only brands with significant sales
ORDER BY Return_Rate_Percentage DESC;