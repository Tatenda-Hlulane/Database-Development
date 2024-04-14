-- Question1
 
USE AdventureWorks2019
SELECT 
	E.BusinessEntityID AS BusEntityID,
	E.NationalIDNumber,
	P.FirstName,
    P.LastName,
    D.Name AS DepartmentName,
    E.JobTitle
FROM HumanResources.Employee E
JOIN HumanResources.EmployeeDepartmentHistory EDH 
ON E.BusinessEntityID = EDH.BusinessEntityID
JOIN HumanResources.Department D
ON EDH.DepartmentID = D.DepartmentID
JOIN Person.Person P 
ON E.BusinessEntityID = P.BusinessEntityID
WHERE E.OrganizationLevel = 1 AND EDH.StartDate = (SELECT MAX(StartDate) FROM HumanResources.EmployeeDepartmentHistory WHERE BusinessEntityID = E.BusinessEntityID)
ORDER BY e.BusinessEntityID;


--Question 2
--a. OUTER JOIN

USE AdventureWorks2019
SELECT 
	V.AccountNumber, 
	V.Name AS VendorName, 
	V.CreditRating
FROM Purchasing.Vendor AS V
LEFT JOIN Purchasing.ProductVendor AS P 
ON V.BusinessEntityID = P.BusinessEntityID
WHERE P.ProductID IS NULL
ORDER BY V.Name; -- ORDER Alphabetically


--Question 3

USE AdventureWorks2019;

WITH sales_orders AS (
    SELECT
        ShipMethodID,
        SUM(TotalDue) AS TotalSales
    FROM Sales.SalesOrderHeader
    GROUP BY ShipMethodID
),
purchase_orders AS (
    SELECT
        ShipMethodID,
        SUM(TotalDue) AS TotalPurchases
    FROM Purchasing.PurchaseOrderHeader
    GROUP BY ShipMethodID
)
SELECT
    s.ShipMethodID,
    s.Name,
    COALESCE(p.TotalPurchases, 0.00) AS TotalPurchases
FROM Purchasing.ShipMethod s
LEFT JOIN sales_orders ON s.ShipMethodID = s.ShipMethodID
LEFT JOIN purchase_orders p ON s.ShipMethodID = p.ShipMethodID
ORDER BY s.Name;

SELECT
    sm.ShipMethodID,
    sm.Name AS ShippingMethodName,
    ROUND(SUM(CASE WHEN so.TotalDue IS NOT NULL THEN so.TotalDue ELSE 0 END), 2) AS SalesOrdersTotal,
    ROUND(SUM(CASE WHEN po.TotalDue IS NOT NULL THEN po.TotalDue ELSE 0 END), 2) AS PurchaseOrdersTotal
FROM
    Purchasing.ShipMethod sm
LEFT JOIN
    Sales.SalesOrderHeader so
ON
    sm.ShipMethodID = so.ShipMethodID
LEFT JOIN
    Purchasing.PurchaseOrderHeader po
ON
    sm.ShipMethodID = po.ShipMethodID
GROUP BY
    sm.ShipMethodID,
    sm.Name
ORDER BY
    sm.ShipMethodID;


-- Question 4

SELECT Production.Product.ProductNumber, Production.Product.Name, Production.ProductSubcategory.Name AS Subcategory,
    CASE Production.Product.Class
        WHEN 'H' THEN 'High'
        WHEN 'M' THEN 'Medium'
        WHEN 'L' THEN 'Low'
        ELSE 'Other'
    END AS Class
FROM Production.Product
JOIN Production.ProductSubcategory ON Production.Product.ProductSubcategoryID = Production.ProductSubcategory.ProductSubcategoryID
WHERE Production.Product.MakeFlag = 1 AND Production.Product.SellEndDate IS NULL;


--Question5

SELECT
  CustomerID,
  [Store Name],
  Year,
  YearSales
FROM (
  SELECT 
    C.CustomerID, 
    S.Name AS 'Store Name', 
    YEAR(SOH.OrderDate) AS 'Year', 
    ROUND(SUM(SOH.TotalDue), 2) AS 'YearSales'
  FROM 
    Sales.Customer C
  INNER JOIN 
    Sales.SalesOrderHeader SOH ON C.CustomerID = SOH.CustomerID
  INNER JOIN 
    Sales.Store S ON SOH.SalesPersonID = S.SalesPersonID
  GROUP BY 
    C.CustomerID, S.Name, YEAR(SOH.OrderDate)
) vwStoreSales
WHERE 
  YearSales > 100000
ORDER BY 
  CustomerID ASC, Year DESC;






