/**
1.	In SQL Server, assuming you can find the result by using both joins and subqueries, which one would you prefer to use and why?
I prefer to use joins
The advantage of a join includes that it executes faster.
The retrieval time of the query using joins almost always will be faster than that of a subquery.
By using joins, you can maximize the calculation burden on the database

2.	What is CTE and when to use it?
The Common Table Expressions or CTE�s for short are used within SQL Server to simplify complex joins and subqueries,
and to provide a means to query hierarchical data such as an organizational chart.

A CTE can be used to:

Create a recursive query. For more information, see Recursive Queries Using Common Table Expressions.

Substitute for a view when the general use of a view is not required; that is, you do not have to store the definition in metadata.

Enable grouping by a column that is derived from a scalar subselect, or a function that is either not deterministic or has external access.

Reference the resulting table multiple times in the same statement.

3.	What are Table Variables? What is their scope and where are they created in SQL Server?
A table variable is a local variable that has some similarities to temp tables.  Table variables are created via a declaration statement like other local variables. 
Like other local variables, a table variable name begins with an @ sign.  However, its declaration statement has a type of table.

The table variable scope is within the batch. 


Table variables are alternatives of temporary tables which store a set of records.

Table variable (@emp) is created in the memory. Whereas, a Temporary table (#temp) is created in the tempdb database.
Note:- if there is a memory pressure the pages belonging to a table variable may be pushed to tempdb.


4.	What is the difference between DELETE and TRUNCATE? Which one will have better performance and why?
DELETE is a DML(Data Manipulation Language) command and is used when we specify the row(tuple) that we want to remove or delete from the table or relation.
The DELETE command can contain a WHERE clause.
If WHERE clause is used with DELETE command then it remove or delete only those rows(tuple) that satisfy the condition otherwise by default it removes all the tuples(rows) from the table. 

TRUNCATE is a DDL(Data Definition Language) command and is used to delete all the rows or tuples from a table. Unlike the DELETE command,
TRUNCATE command does not contain a WHERE clause. In the TRUNCATE command, the transaction log for each deleted data page is recorded. 
Unlike the DELETE command, the TRUNCATE command is fast. We cannot rollback the data after using the TRUNCATE command. 

TRUNCATE
TRUNCATE is faster than DELETE , as it doesn't scan every record before removing it.

5.	What is Identity column? How does DELETE and TRUNCATE affect it?

An identity column is a column (also known as a field) in a database table that is made up of values generated by the database. 

6.	What is difference between �delete from table_name� and �truncate table table_name�?
TRUNCATE always removes all the rows from a table, leaving the table empty and the table structure intact whereas DELETE may remove conditionally if the where clause is used.

*/



/*



5.	List all Customer Cities that have at least two customers.
a.	Use union
b.	Use sub-query and no union
**/
USE Northwind
GO
/*
1.	List all cities that have both Employees and Customers.
*/
SELECT DISTINCT  City
FROM Customers WHERE City IN(
SELECT   City
FROM Employees) 
/**
2.	List all cities that have Customers but no Employee.
a.	Use sub-query
b.	Do not use sub-query
*/
--a
SELECT  DISTINCT City
FROM Customers WHERE City NOT IN(
SELECT   City
FROM Employees) 
--b

-- https://www.cnblogs.com/phoenixfling/archive/2012/05/09/2492006.html
SELECT DISTINCT C.City
FROM Customers C  LEFT  JOIN Employees E ON C.City = E.City WHERE E.City IS  NULL

select distinct city from Customers  
except 
select distinct city from Employees

-- 3.	List all products and their total order quantities throughout all orders.

SELECT P.ProductName,SUM(OD.Quantity)AS SumOfQuanity
FROM [Order Details] OD JOIN Products P ON OD.ProductID = P.ProductID
GROUP BY P.ProductName
ORDER BY SUM(OD.Quantity)

select ProductID,SUM(Quantity) as QunatityOrdered 
from [order details]
group by ProductID
ORDER BY SUM(Quantity)

-- 4.	List all Customer Cities and total products ordered by that city.
SELECT C.City, SUM(OD.Quantity) AS SumOfQuanity
FROM [Order Details] OD JOIN Orders O ON OD.OrderID = O.OrderID JOIN Customers C ON C.CustomerID = O.CustomerID
GROUP BY C.City

/*

5.	List all Customer Cities that have at least two customers.
a.	Use union
b.	Use sub-query and no union
*/
--a



--b

SELECT City,COUNT(CustomerID) AS NumOfCustomers
FROM Customers
GROUP BY City
HAVING COUNT(CustomerID) >= 2


/**6.	List all Customer Cities that have ordered at least two different kinds of products.*/


SELECT C.City,COUNT(Distinct OD.ProductID) KindsOfProduct
FROM [Order Details] OD  JOIN Orders O on OD.OrderID = O.OrderID  JOIN Customers C on C.CustomerID = O.CustomerID
GROUP BY C.City
HAVING COUNT(DISTINCT  OD.ProductID) >=2


/*7.	List all Customers who have ordered products, but have the �ship city� on the order different from their own customer cities.*/



SELECT DISTINCT C.CustomerID 
FROM Orders O  JOIN Customers C ON C.CustomerID = O.CustomerID
WHERE C.City<>O.ShipCity

/*8.	List 5 most popular products, their average price, and the customer city that ordered most quantity of it.*/

SELECT TOP 5 ProductID,AVG(UnitPrice) as AvgPrice,
	(SELECT TOP 1 City 
	FROM Customers c join Orders o ON o.CustomerID=c.CustomerID JOIN [Order Details] od2 ON od2.OrderID=o.OrderID 
	WHERE od2.ProductID=od1.ProductID 
	GROUP BY city 
	ORDER BY SUM(OD1.Quantity) DESC) AS City
FROM [Order Details] od1
GROUP BY ProductID 
--order by sum(Quantity) desc


/*9.	List all cities that have never ordered something but we have employees there.
a.	Use sub-query
b.	Do not use sub-query*/

--a
SELECT DISTINCT City 
FROM Employees 
WHERE city  NOT IN 
	(SELECT ShipCity 
	FROM Orders 
	WHERE ShipCity is NOT null)-- Subquery : the city that have ordered something, we do not want this kind of city , So NOT IN

--b
SELECT DISTINCT City FROM  Employees WHERE City IS NOT NULL
EXCEPT 
(SELECT ShipCity FROM Orders WHERE ShipCity IS NOT NULL)


/*
10.	List one city, if exists, that is the city from where the employee sold most orders (not the product quantity) is, 
	and also the city of most total quantity of products ordered from. (tip: join  sub-query)
*/
SELECT TOP 1 City 
FROM Orders O  JOIN Customers C ON O.CustomerID = C.CustomerID 
GROUP BY City 
ORDER BY COUNT(O.OrderID) DESC
-- London

SELECT TOP 1 City 
FROM Orders O  JOIN Customers C ON O.CustomerID = C.CustomerID  JOIN [Order Details] OD ON O.OrderID = OD.OrderID
GROUP BY City 
ORDER BY COUNT(OD.Quantity) DESC 
--Boise

--11. How do you remove the duplicates record of a table?
--DISTINCT
/***
12. Sample table to be used for solutions below- Employee (empid integer, mgrid integer, deptid integer, salary money) Dept (deptid integer, deptname varchar(20))
 Find employees who do not manage anybody.
13. Find departments that have maximum number of employees. (solution should consider scenario having more than 1 departments that have maximum number of employees). Result should only have - deptname, count of employees sorted by deptname.
14. Find top 3 employees (salary based) in every department. Result should have deptname, empid, salary sorted by deptname and then employee with high to low salary.
*/
--12
CREATE TABLE Employee3 (
empid int,
mgrid int, 
deptid int,
salary money)

CREATE TABLE Dept (
deptid int,
deptname varchar(20))

--13
SELECT Dept.deptname
FROM Employee3
INNER JOIN Dept ON Employee3.deptid = Dept.deptid
GROUP BY Dept.deptname
ORDER BY COUNT(Dept.deptname)

--14
SELECT Dept.deptname, Employee3.deptid, Employee3.empid, Employee3.salary
FROM Employee3
INNER JOIN Dept ON Employee3.deptid = Dept.deptid