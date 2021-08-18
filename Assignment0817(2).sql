/**
1.	What is a result set?
The result set is an object that represents a set of data returned from a data source, usually as the result of a query.
The result set contains rows and columns to hold the requested data elements, and it is navigated with a cursor.

2.	What is the difference between Union and Union All?
Union extracts the rows that are being specified in the query
while Union All extracts all the rows including the duplicates (repeated values) from both the queries.


3.	What are the other Set Operators SQL Server has?
UNION , INTERSECT , and EXCEPT

4.	What is the difference between Union and Join?

JOIN	
JOIN combines data from many tables based on a matched condition between them.It combines data into new columns.
Number of columns selected from each table may not be same.	
Datatypes of corresponding columns selected from each table can be different.	
It may not return distinct columns.	

UNION
SQL combines the result-set of two or more SELECT statements.It combines data into new rows.
Number of columns selected from each table should be same.
Datatypes of corresponding columns selected from each table should be same.
It returns distinct rows.


5.	What is the difference between INNER JOIN and FULL JOIN?
An inner join will only return rows in which there is a match based on the join predicate.
A full join, the result set will retain all of the rows from both of the tables.

6.	What is difference between left join and outer join
Left Outer Join retrieves all the rows from both the tables that satisfy the join condition along with the unmatched rows of the left table.
Full Outer Join returns all the rows from both the table. 

7.	What is cross join?
A cross join returns the Cartesian product of rows from the rowsets in the join.
In other words, it will combine each row from the first rowset with each row from the second rowset.


8.	What is the difference between WHERE clause and HAVING clause?
WHERE Clause is used to filter the records from the table based on the specified condition.
HAVING Clause is used to filter record from the groups based on the specified condition.

9.	Can there be multiple group by columns?
Yes A GROUP BY clause can contain two or more columns—or, in other words, a grouping can consist of two or more columns.

*/
/*
1.	How many products can you find in the Production.Product table?
2.	Write a query that retrieves the number of products in the Production.Product table that are included in a subcategory. The rows that have NULL in column ProductSubcategoryID are considered to not be a part of any subcategory.
3.	How many Products reside in each SubCategory? Write a query to display the results with the following titles.
ProductSubcategoryID CountedProducts
*/
USE AdventureWorks2019 
GO
-- 1.	How many products can you find in the Production.Product table?
SELECT COUNT(ProductID)
FROM Production.Product

--2


SELECT  COUNT(ProductID) AS NumOfProducts
FROM Production.Product
WHERE  ProductSubcategoryID IS NOT NULL
GROUP BY  ProductSubcategoryID

--3
SELECT  ProductSubcategoryID   , COUNT(ProductID) AS CountedProducts
FROM Production.Product
GROUP BY  ProductSubcategoryID

/**
4.	How many products that do not have a product subcategory. 
5.	Write a query to list the sum of products quantity in the Production.ProductInventory table.
6.	 Write a query to list the sum of products in the Production.ProductInventory table and LocationID set to 40 and limit the result to include just summarized quantities less than 100.
              ProductID    TheSum
-----------        ----------
7.	Write a query to list the sum of products with the shelf information in the Production.ProductInventory table and LocationID set to 40 and limit the result to include just summarized quantities less than 100
Shelf      ProductID    TheSum
---------- -----------        -----------
**/
--4 
SELECT COUNT(ProductID)
FROM Production.Product
WHERE  ProductSubcategoryID IS NULL

--5
SELECT SUM(Quantity)
FROM Production.ProductInventory
--6

/*
SELECT *
FROM Production.ProductInventory
*/
SELECT ListPrice
FROM Production.Product



SELECT ProductID , SUM(Quantity) AS TheSum
FROM Production.ProductInventory 
WHERE  LocationID = 40
GROUP BY ProductID
HAVING SUM(Quantity) < 100
--7

SELECT Shelf,  ProductID , SUM(Quantity) AS TheSum
FROM Production.ProductInventory 
WHERE LocationID = 40
GROUP BY Shelf,  ProductID
HAVING SUM(Quantity) < 100

/*
8.	Write the query to list the average quantity for products where column LocationID has the value of 10 from the table Production.ProductInventory table.

*/
SELECT AVG(Quantity)
FROM Production.ProductInventory 
WHERE  LocationID = 10
/*
9.	Write query  to see the average quantity  of  products by shelf  from the table Production.ProductInventory
ProductID   Shelf      TheAvg
----------- ---------- -----------
*/
SELECT  ProductID ,Shelf ,AVG(Quantity) AS TheAvg
FROM Production.ProductInventory 
GROUP BY Shelf,  ProductID
/*
10.	Write query  to see the average quantity  of  products by shelf excluding rows that has the value of N/A in the column Shelf from the table Production.ProductInventory
ProductID   Shelf      TheAvg
----------- ---------- -----------
*/
SELECT  ProductID ,Shelf ,AVG(Quantity) AS TheAvg
FROM Production.ProductInventory 
GROUP BY Shelf,  ProductID
HAVING Shelf IS NOT NULL

/*
11.	List the members (rows) and average list price in the Production.Product table.
This should be grouped independently over the Color and the Class column. Exclude the rows where Color or Class are null.
Color           	Class 	TheCount   	 AvgPrice
--------------	- ----- 	----------- 	---------------------

*/

SELECT  Color,Class, COUNT(ListPrice) AS TheCount,AVG(ListPrice) AS AvgPrice
FROM Production.Product
GROUP BY Color,Class
HAVING Color IS NOT NULL AND Class IS NOT NULL

/*
12.	  Write a query that lists the country and province names from person. CountryRegion and person. StateProvince tables.
Join them and produce a result set similar to the following. 

Country                        Province
---------                          ----------------------
13.	Write a query that lists the country and province names from person. CountryRegion and person. StateProvince tables and list the countries filter them by Gernd Canada.
Join them and produce a result set similar to the following.

Country                        Province
---------                          ----------------------

*/
SELECT *
FROM person. CountryRegion
SELECT *
FROM person. StateProvince

SELECT c.Name AS Country , s.Name AS Province
FROM person. CountryRegion c, person. StateProvince s
WHERE c.CountryRegionCode = s.CountryRegionCode

SELECT c.Name AS Country , s.Name AS Province
FROM person. CountryRegion c INNER JOIN person. StateProvince s ON  c.CountryRegionCode = s.CountryRegionCode



SELECT c.Name AS Country , s.Name AS Province
FROM person. CountryRegion c INNER JOIN person. StateProvince s ON  c.CountryRegionCode = s.CountryRegionCode
WHERE c.Name IN ('Germany' , 'Canada')

USE Northwind
GO

/*
14.	List all Products that has been sold at least once in last 25 years.
15.	List top 5 locations (Zip Code) where the products sold most.
16.	List top 5 locations (Zip Code) where the products sold most in last 25 years.
17.	 List all city names and number of customers in that city.     
18.	List city names which have more than 2 customers, and number of customers in that city 
**/

--14 

SELECT DISTINCT  p.ProductName 
FROM[Order Details] od INNER JOIN Orders o  ON o.OrderID = od.OrderID INNER JOIN Products p On od.ProductID = p.ProductID
WHERE YEAR(GETDATE()) - YEAR(o.OrderDate) < 25

--15 

SELECT TOP 5 ShipPostalCode
FROM  dbo.Orders
WHERE ShipPostalCode IS NOT NULL
GROUP BY ShipPostalCode
ORDER BY COUNT(OrderID)

--16
SELECT TOP 5 ShipPostalCode
FROM  dbo.Orders
WHERE ShipPostalCode IS NOT NULL AND YEAR(GETDATE()) - YEAR(OrderDate) < 25
GROUP BY ShipPostalCode
ORDER BY COUNT(OrderID)

--17
SELECT * FROM Customers
SELECT City ,COUNT(CustomerID) AS 'Number of Customers'
FROM Customers
GROUP BY City


--18

SELECT City ,COUNT(CustomerID) AS 'Number of Customers'
FROM Customers
GROUP BY City
HAVING COUNT(CustomerID) > 2

/*19.	List the names of customers who placed orders after 1/1/98 with order date.
20.	List the names of all customers with most recent order dates 
21.	Display the names of all customers  along with the  count of products they bought 
22.	Display the customer ids who bought more than 100 Products with count of products.
*/
--19
SELECT DISTINCT C.ContactName
FROM Orders O INNER JOIN Customers C ON C.CustomerID = O.CustomerID
WHERE O.OrderDate > '1/1/98'

--20 ???
SELECT C.ContactName
FROM Orders O INNER JOIN Customers C ON C.CustomerID = O.CustomerID
and OrderID = (
            SELECT TOP 1 O2.OrderID
            FROM Orders O2
            WHERE O2.CustomerID= O.CustomerID 
            ORDER BY O2.OrderDate DESC
        )

--21 	Display the names of all customers  along with the  count of products they bought 
SELECT C.ContactName, COUNT(OD.Quantity) AS [Total Sale]
FROM Orders o INNER JOIN [Order Details] od ON o.OrderID = od.OrderID INNER JOIN Customers  c  ON c.CustomerID = o.CustomerID
GROUP BY C.CONTACTNAME

--22
SELECT C.CustomerID,COUNT(OD.Quantity) AS [Total Sale]
FROM Orders o INNER JOIN [Order Details] od ON o.OrderID = od.OrderID INNER JOIN Customers  c  ON c.CustomerID = o.CustomerID
GROUP BY C.CustomerID
HAVING COUNT(OD.Quantity) > 100

--23
/**
23.	List all of the possible ways that suppliers can ship their products. Display the results as below
Supplier Company Name   	Shipping Company Name
*/
SELECT s.CompanyName as [Supplier Company Name] , sh.CompanyName as [Shipping Company Name]
FROM Suppliers s CROSS JOIN Shippers sh 

--24  Display the products order each day. Show Order date and Product Name.
SELECT o.OrderDate, p.ProductName
FROM[Order Details] od INNER JOIN Orders o  ON o.OrderID = od.OrderID INNER JOIN Products p On od.ProductID = p.ProductID
ORDER BY 1

--25  	Displays pairs of employees who have the same job title.
SELECT e1.FirstName + ' ' + e1.LastName as Employee1, e2.FirstName + ' ' + e2.LastName as Employee2
FROM Employees e1 join Employees e2 on
( e1.Title = e2.Title and e1.EmployeeID != e2.EmployeeID )

--26.	Display all the Managers who have more than 2 employees reporting to them.


SELECT e.FirstName + ' ' + e.LastName as Manager, e.Title
FROM Employees e
WHERE
	(SELECT COUNT(e2.ReportsTo)
	FROM Employees e2
	WHERE e.EmployeeID = e2.ReportsTo) >=2

--27

/*
27.	Display the customers and suppliers by city. The results should have the following columns
City 
Name 
Contact Name,
Type (Customer or Supplier)

*/
SELECT City, CompanyName AS Name, ContactName AS 'Contact Name' ,'Customer' AS Type
FROM Customers
UNION 
SELECT City, CompanyName AS Name, ContactName AS 'Contact Name' ,'Supplier' AS Type
FROM Suppliers
ORDER BY City

/*28
*
SELECT 
FROM F1 INNER JOIN F2 
ON F1.T1 = F2.T2
*/

/*29 
SELECT *
FROM T1 left outer join T2 ON T1.F1= T2.F2
*/