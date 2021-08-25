use Northwind;
/*1.
1.	Lock tables Region, Territories, EmployeeTerritories and Employees. 
Insert following information into the database. In case of an error, no changes should be made to DB.
a.	A new region called “Middle Earth”;
b.	A new territory called “Gondor”, belongs to region “Middle Earth”;
c.	A new employee “Aragorn King” who's territory is “Gondor”.
*/
--1
--a
BEGIN TRAN

select * from Region
select * from Territories
select * from Employees
select * from EmployeeTerritories

INSERT INTO Region VALUES(5,'Middel Earth')
IF @@ERROR <>0
ROLLBACK
ELSE BEGIN


--b

INSERT INTO Territories VALUES(98105,'Gondor',5)
DECLARE @error INT  = @@ERROR 
IF @error <>0
BEGIN
PRINT @error
ROLLBACK
END
ELSE BEGIN

--c

INSERT INTO Employees VALUES('Aragorn',	'King'	,'Sales Representative',	'Ms.'	,
'1966-01-27 00:00:00.000','1994-11-15 00:00:00.000', 'Houndstooth Rd.',	'London',	NULL	
,'WG2 7LT',	'UK',	'(71) 555-4444'	,452,NULL,
'Anne has a BA degree in English from St. Lawrence College.  She is fluent in French and German.',	5,	'http://accweb/emmployees/davolio.bmp/')
INSERT INTO EmployeeTerritories VALUES(@@IDENTITY,98105)
DECLARE @error2 INT  = @@ERROR 
IF @error2 <>0
BEGIN
PRINT @error2
ROLLBACK
END
ELSE BEGIN

/*2. Change territory “Gondor” to “Arnor”.
*/


UPDATE Territories
SET TerritoryDescription = 'Arnor'
WHERE TerritoryDescription = 'Gondor'
IF @@ERROR<>0
ROLLBACK
ELSE BEGIN

/*3.Delete Region “Middle Earth”. (tip: remove referenced data first) 
(Caution: do not forget WHERE or you will delete everything.) 
In case of an error, no changes should be made to DB. Unlock the tables mentioned 
in question 1.*/
DELETE from Territories where RegionID = 5;
DELETE from Region where RegionID = 5;
UNLOCK TABLE Region,Territories,EmployeeTerritories,Employees;


DELETE FROM EmployeeTerritories 
WHERE TerritoryID = (SELECT TerritoryID FROM Territories WHERE TerritoryDescription = 'Arnor')
DELETE FROM Territories
WHERE TerritoryDescription = 'Arnor'
DELETE FROM Region
WHERE RegionDescription = 'Middel Earth'
IF @@ERROR <>0
ROLLBACK
ELSE BEGIN
COMMIT
END
END
END
END
END



/*4.Create a view named “view_product_order_[your_last_name]”, list all products 
and total ordered quantity for that product.*/
CREATE VIEW View_Product_Order_Liang
AS
SELECT ProductName,SUM(Quantity) As TotalOrderQty FROM [Order Details] OD	INNER JOIN Products P ON P.ProductID = OD.ProductID
GROUP BY ProductName

/*5.Create a stored procedure “sp_product_order_quantity_[your_last_name]” that accept 
product id as an input and total quantities of order as output parameter.*/

ALTER PROC sp_Product_Order_Quantity_LIANG
@ProductID INT,
@TotalOrderQty INT OUT
AS
BEGIN
SELECT @TotalOrderQty = SUM(Quantity)  FROM [Order Details] OD JOIN Products P ON P.ProductID = OD.ProductID
WHERE P.ProductID = @ProductID
GROUP BY ProductName
END

DECLARE @Tot INT
EXEC sp_Product_Order_Quantity_LIANG 11,@Tot OUT
PRINT @Tot 


/*6. Create a stored procedure “sp_product_order_city_[your_last_name]” that accept 
product name as an input and top 5 cities that ordered most that product combined with 
the total quantity of that product ordered from that city as output.*/
ALTER PROC sp_Product_Order_City_LIANG
@ProductName NVARCHAR(50)
AS
BEGIN
SELECT TOP 5 ShipCity,SUM(Quantity) FROM [Order Details] OD JOIN Products P ON P.ProductID = OD.ProductID JOIN Orders O ON O.OrderID = OD.OrderID
WHERE ProductName=@ProductName
GROUP BY ProductName,ShipCity
ORDER BY SUM(Quantity) DESC
END
EXEC sp_Product_Order_City_LIANG 'Queso Cabrales'
--7
/*Lock tables Region, Territories, EmployeeTerritories and Employees. Create a stored 
procedure “sp_move_employees_[your_last_name]” that automatically find all 
employees in territory “Tory”; if more than 0 found, insert a new territory “Stevens 
Point” of region “North” to the database, and then move those employees to “Stevens 
Point”.*/
BEGIN TRAN
select * from Region
select * from Territories
select * from Employees
select * from EmployeeTerritories
GO
ALTER PROC sp_move_employees_liang
AS
BEGIN

IF EXISTS(SELECT EmployeeID 
FROM EmployeeTerritories WHERE TerritoryID = (SELECT TerritoryID FROM Territories WHERE TerritoryDescription ='Troy'))
BEGIN
DECLARE @TerritotyID INT
SELECT @TerritotyID = MAX(TerritoryID) FROM Territories
BEGIN TRAN
INSERT INTO Territories VALUES(@TerritotyID+1 ,'Stevens Point',3)
UPDATE EmployeeTerritories
SET TerritoryID = @TerritotyID+1
WHERE EmployeeID IN (SELECT EmployeeID FROM EmployeeTerritories WHERE TerritoryID = (SELECT TerritoryID FROM Territories WHERE TerritoryDescription ='Troy'))
IF @@ERROR <> 0
BEGIN
ROLLBACK
END
ELSE
COMMIT
END

END

EXEC sp_move_employees_liang

 /*8. Create a trigger that when there are more than 100 employees in territory 
 “Stevens Point”, move them back to Troy. (After test your code,) remove the trigger. 
 Move those employees back to “Troy”, if any. Unlock the tables.
 */
 CREATE TRIGGER tr_move_emp_liang
ON EmployeeTerritories
AFTER INSERT
AS
DECLARE @EmpCount INT
SELECT @EmpCount = COUNT(*) FROM EmployeeTerritories WHERE TerritoryID = (SELECT TerritoryID FROM Territories WHERE TerritoryDescription = 'Stevens Point' AND RegionID=3) GROUP BY EmployeeID
IF (@EmpCount>100)
BEGIN
UPDATE EmployeeTerritories
SET TerritoryID = (SELECT TerritoryID FROM Territories WHERE TerritoryDescription ='Troy')
WHERE EmployeeID IN (SELECT EmployeeID FROM EmployeeTerritories WHERE TerritoryID = (SELECT TerritoryID FROM Territories WHERE TerritoryDescription ='Stevens Point' AND RegionID=3))
END

DROP TRIGGER tr_move_emp_liang

COMMIT
	

/*9.Create 2 new tables “people_your_last_name” “city_your_last_name”. 
City table has two records: {Id:1, City: Seattle}, {Id:2, City: Green Bay}. 
People has three records: {id:1, Name: Aaron Rodgers, City: 2}, 
{id:2, Name: Russell Wilson, City:1}, {Id: 3, Name: Jody Nelson, City:2}. 
Remove city of Seattle. If there was anyone from Seattle, put them into 
a new city “Madison”. Create a view “Packers_your_name” lists all people 
from Green Bay. If any error occurred, no changes should be made to DB. 
(after test) Drop both tables and view.*/
CREATE TABLE People_LIANG
(
id int ,
name nvarchar(100),
city int
)

create table City_LIANG
(
id int,
city nvarchar(100)
)
BEGIN TRAN 
insert into City_LIANG values(1,'Seattle')
insert into City_LIANG values(2,'Green Bay')

insert into People_LIANG values(1,'Aaron Rodgers',1)
insert into People_LIANG values(2,'Russell Wilson',2)
insert into People_LIANG values(3,'Jody Nelson',2)

if exists(select id from People_LIANG where city = (select id from City_LIANG where city = 'Seatle'))
begin
insert into City_LIANG values(3,'Madison')
update People_LIANG
set city = 'Madison'
where id in (select id from People_LIANG where city = (select id from City_LIANG where city = 'Seatle'))
end
delete from City_LIANG where city = 'Seattle'

CREATE VIEW Packers_LIANG
AS
SELECT name FROM People_LIANG WHERE city = 'Green Bay'

select * from Packers_LIANG
commit
drop table People_LIANG
drop table City_LIANG
drop view Packers_LIANG

/*10. Create a stored procedure “sp_birthday_employees_[you_last_name]” 
that creates a new table “birthday_employees_your_last_name” and fill it 
with all employees that have a birthday on Feb. (Make a screen shot) drop the table. 
Employee table should not be affected.*/

ALTER PROC sp_birthday_employee_LIANG
AS
BEGIN
SELECT * INTO #EmployeeTemp
FROM Employees WHERE DATEPART(MM,BirthDate) = 02
SELECT * FROM #EmployeeTemp
END


/*11. Create a stored procedure named “sp_your_last_name_1” that returns all cites 
that have at least 2 customers who have bought no or only one kind of product. 
Create a stored procedure named “sp_your_last_name_2” that returns the same but 
using a different approach. (sub-query and no-sub-query).*/

CREATE PROC sp_liang_1
AS
BEGIN
SELECT City FROM CUSTOMERS
GROUP BY City
HAVING COUNT(*)>2
INTERSECT
SELECT City FROM Customers C JOIN Orders O ON O.CustomerID=C.CustomerID JOIN [Order Details] OD ON O.OrderID = OD.OrderID
GROUP BY OD.ProductID,C.CustomerID,City
HAVING COUNT(*) BETWEEN 0 AND 1
END
GO
EXEC sp_liang_1
GO
CREATE PROC sp_liang_2
AS
BEGIN
SELECT City FROM CUSTOMERS
WHERE CITY IN (SELECT City FROM Customers C JOIN Orders O ON O.CustomerID=C.CustomerID JOIN [Order Details] OD ON O.OrderID = OD.OrderID
GROUP BY OD.ProductID,C.CustomerID,City
HAVING COUNT(*) BETWEEN 0 AND 1)
GROUP BY City
HAVING COUNT(*)>2
END
GO
EXEC sp_liang_2
GO


/*12.	How do you make sure two tables have the same data?

*/
--12 USE EXCEPT KEYWORD

SELECT * FROM Customers
EXCEPT
SELECT * FROM Customers

/*14*/
select [First Name] +' '+[Last Name]+' '+ [Middle Name] + '.' as 'Full Name' from NAMETable;

--15
select top 1 Marks from MarkTable where Sex = 'F' order by Marks;

--16
select * from MarkTable order by Sex,Marks desc;

--14 SELECT firstName+' '+lastName from Person where middleName is null UNION 
--SELECT firstName+' '+lastName+' '+middelName+'.' from Person where middleName is not null

--15 select top 1 marks from student where sex = 'F' order by marks desc

--16 select * from students order by sex,marks