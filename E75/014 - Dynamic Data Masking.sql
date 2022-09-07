/***********************************************************************************************************

	DYNAMIC DATA MASKING IN SQL SERVER 2022

	- Granular permissions using UMASK at
		- 	Database	GRANT UNMASK TO <principal>
		-	Schema		GRANT UNMASK ON SCHEMA::<schemaname> TO <principal>
		-	Table		GRANT UNMASK ON <schemaname>.<tablename> TO <principal>
		-	Column		GRANT UNMASK ON <schemaname>.<tablename> (<column>,<...>) TO <principal>

	- Date Masking
	  
	  Masking method for column defined with data type 

	   -	datetime
	   -	datetime2
	   -	date
	   -	time
	   -	datetimeoffset
	   -	smalldatetime
	   
	   Samples

	   -	masking the year    => datetime("Y")
	   -	masking the month   => datetime("M") 
	   -	masking the day     => datetime("D")
	   -	masking the hour    => datetime("h")
	   -	masking the minute  => datetime("m")
	   -	masking seconds     => datetime("s") 
	   -	masking combination => datetime("YMD")
	   -	masking combination => datetime("Yh")

***********************************************************************************************************/

	USE TSQLV6
	GO

------------------------------------------------------------------------------------------------------------
-- EMPLOYEES
------------------------------------------------------------------------------------------------------------
	DROP TABLE IF EXISTS HR.EmployeesDDM;
	GO

	CREATE TABLE HR.EmployeesDDM
	(
		empid			int NOT NULL CONSTRAINT PK_EmployeesDDM PRIMARY KEY CLUSTERED ,
		lastname		nvarchar(20) NOT NULL,
		firstname		nvarchar(10) NOT NULL,
		title			nvarchar(30) NOT NULL,
		titleofcourtesy nvarchar(25) NOT NULL,
		birthdate		date NOT NULL,
		hiredate		date NOT NULL,
		address			nvarchar(60) NOT NULL,
		city			nvarchar(15) NOT NULL,
		region			nvarchar(15) NULL,
		postalcode		nvarchar(10) NULL,
		country			nvarchar(15) NOT NULL,
		phone			nvarchar(24) NOT NULL,
		salary			money NOT NULL,
		email			nvarchar(256) NOT NULL,
		creditcard		nvarchar(20) NOT NULL,
		mgrid			int NULL
	);
	GO

	INSERT INTO HR.EmployeesDDM
	SELECT 
			empid, lastname, firstname, title, titleofcourtesy, birthdate, hiredate, address, city, region, 
			postalcode, country, phone, 200000/empid, CONCAT(firstname,'.',lastname,'@company.com'),
			'5100-5302-2000-'+REPLICATE(CAST(empid as nvarchar(1)),4), [mgrid]
	FROM HR.Employees
	GO

--
--	ADD MASK
--
	ALTER TABLE HR.EmployeesDDM ALTER COLUMN lastname ADD MASKED WITH (FUNCTION='partial(1,"****",0)');
	ALTER TABLE HR.EmployeesDDM ALTER COLUMN birthdate ADD MASKED WITH (FUNCTION='datetime("Y")');
	ALTER TABLE HR.EmployeesDDM ALTER COLUMN hiredate ADD MASKED WITH (FUNCTION='datetime("MD")');
	ALTER TABLE HR.EmployeesDDM ALTER COLUMN salary ADD MASKED WITH (FUNCTION='default()');
	ALTER TABLE HR.EmployeesDDM ALTER COLUMN email ADD MASKED WITH (FUNCTION='email()');
	ALTER TABLE HR.EmployeesDDM ALTER COLUMN creditcard ADD MASKED WITH (FUNCTION='partial(0,"XXXX-XXXX-XXXX-",4)');
	GO


------------------------------------------------------------------------------------------------------------
--	ORDERS
------------------------------------------------------------------------------------------------------------

	DROP TABLE IF EXISTS Sales.OrdersDDM;
	GO

	CREATE TABLE Sales.OrdersDDM
	(
		orderid			int NOT NULL CONSTRAINT PK_OrdersDDM PRIMARY KEY CLUSTERED ,
		custid			int NULL,
		empid			int NOT NULL,
		orderdate		date NOT NULL,
		requireddate	date NOT NULL,
		shippeddate		date NULL,
		shipperid		int NOT NULL,
		freight			money NOT NULL,
		shipname		nvarchar(40) NOT NULL,
		shipaddress		nvarchar(60) NOT NULL,
		shipcity		nvarchar(15) NOT NULL,
		shipregion		nvarchar(15) NULL,
		shippostalcode	nvarchar(10) NULL,
		shipcountry		nvarchar(15) NOT NULL
	);
	GO

	INSERT INTO Sales.OrdersDDM
	SELECT * FROM Sales.Orders
	GO

--
-- ADD MASK
--
	ALTER TABLE Sales.OrdersDDM ALTER COLUMN orderdate ADD MASKED WITH (FUNCTION='datetime("YMD")');
	ALTER TABLE Sales.OrdersDDM ALTER COLUMN requireddate ADD MASKED WITH (FUNCTION='datetime("YMD")');
	ALTER TABLE Sales.OrdersDDM ALTER COLUMN shippeddate ADD MASKED WITH (FUNCTION='datetime("YMD")');
	GO


------------------------------------------------------------------------------------------------------------
-- QUERY MASKED COLUMNS
------------------------------------------------------------------------------------------------------------

	SELECT c.name, tbl.name as table_name, c.is_masked, c.masking_function  
	FROM sys.masked_columns AS c  
	JOIN sys.tables AS tbl   
		ON c.[object_id] = tbl.[object_id]  
	WHERE is_masked = 1;  

------------------------------------------------------------------------------------------------------------
-- USERS
------------------------------------------------------------------------------------------------------------

	DROP USER IF EXISTS HRManager;
	CREATE USER HRManager WITHOUT LOGIN;
	GO

	DROP USER IF EXISTS HRPayrollHead;
	CREATE USER HRPayrollHead WITHOUT LOGIN;
	GO

	DROP USER IF EXISTS HRStaff;
	CREATE USER HRStaff WITHOUT LOGIN;
	GO

	DROP USER IF EXISTS Salesperson;
	CREATE USER Salesperson WITHOUT LOGIN;
	GO

	ALTER ROLE db_datareader ADD MEMBER HRManager;
	ALTER ROLE db_datareader ADD MEMBER HRPayrollHead;
	ALTER ROLE db_datareader ADD MEMBER HRStaff;
	ALTER ROLE db_datareader ADD MEMBER Salesperson;
	GO

---------------------------------------------------------------------------------------
-- VIEW DATA
---------------------------------------------------------------------------------------

--	VIEW AS ME
	SELECT *, DATEDIFF(year,birthdate,getdate()) AS Age FROM HR.EmployeesDDM;
	SELECT * FROM Sales.OrdersDDM;

--	VIEW AS 
	EXECUTE AS USER ='HRManager';
	SELECT *, DATEDIFF(year,birthdate,getdate()) AS Age FROM HR.EmployeesDDM
	SELECT * FROM Sales.OrdersDDM;
	REVERT;

--	VIEW AS 
	EXECUTE AS USER ='HRPayrollHead';
	SELECT *, DATEDIFF(year,birthdate,getdate()) AS Age FROM HR.EmployeesDDM
	SELECT * FROM Sales.OrdersDDM;
	REVERT;

--	VIEW AS 
	EXECUTE AS USER ='HRStaff';
	SELECT *, DATEDIFF(year,birthdate,getdate()) AS Age FROM HR.EmployeesDDM
	SELECT * FROM Sales.OrdersDDM;
	REVERT;

--	VIEW AS 
	EXECUTE AS USER ='Salesperson';
	SELECT *, DATEDIFF(year,birthdate,getdate()) AS Age FROM HR.EmployeesDDM
	SELECT * FROM Sales.OrdersDDM;
	REVERT;

-------------------------------------------------------------------------------------
--	VIEW DATA
-------------------------------------------------------------------------------------

--	BEFORE SQL SERVER 2022
	
	GRANT UNMASK TO HRManager; -- in 2022 is the database level
	GO

	EXECUTE AS USER ='HRManager';
	SELECT *, DATEDIFF(year,birthdate,getdate()) AS Age FROM HR.EmployeesDDM
	SELECT * FROM Sales.OrdersDDM;
	REVERT;

	REVOKE UNMASK TO HRManager;
	GO

--	IN SQL SERVER 2022

	GRANT UNMASK ON HR.EmployeesDDM TO HRManager;
	GO

	EXECUTE AS USER ='HRManager';
	SELECT *, DATEDIFF(year,birthdate,getdate()) AS Age FROM HR.EmployeesDDM
	SELECT * FROM Sales.OrdersDDM;
	REVERT;
	


	GRANT UNMASK ON Sales.OrdersDDM TO Salesperson;
	GO

	EXECUTE AS USER ='Salesperson';
	SELECT *, DATEDIFF(year,birthdate,getdate()) AS Age FROM HR.EmployeesDDM
	SELECT * FROM Sales.OrdersDDM;
	REVERT;

	

	GRANT UNMASK ON HR.EmployeesDDM(salary,creditcard) TO HRPayrollHead;
	GO

	EXECUTE AS USER ='HRPayrollHead';
	SELECT *, DATEDIFF(year,birthdate,getdate()) AS Age FROM HR.EmployeesDDM
	SELECT * FROM Sales.OrdersDDM;
	REVERT;

	

	GRANT UNMASK ON HR.EmployeesDDM(lastname,birthdate,hiredate,email) TO HRStaff;
	GO

	EXECUTE AS USER ='HRStaff';
	SELECT *, DATEDIFF(year,birthdate,getdate()) AS Age FROM HR.EmployeesDDM
	SELECT * FROM Sales.OrdersDDM;
	REVERT;
	


-------------------------------------------------------------------------------------
--	JOINS
-------------------------------------------------------------------------------------

	SELECT *
	FROM Sales.OrdersDDM AS O 
	INNER JOIN HR.EmployeesDDM as E ON E.empid = O.empid;

	EXECUTE AS USER ='HRManager';
	SELECT *
	FROM Sales.OrdersDDM AS O 
	INNER JOIN HR.EmployeesDDM as E ON E.empid = O.empid;
	REVERT;
	
	EXECUTE AS USER ='Salesperson';
	SELECT *
	FROM Sales.OrdersDDM AS O 
	INNER JOIN HR.EmployeesDDM as E ON E.empid = O.empid;
	REVERT;

	ALTER TABLE Sales.OrdersDDM ALTER COLUMN empid ADD MASKED WITH (FUNCTION='default()');
	ALTER TABLE HR.EmployeesDDM ALTER COLUMN empid ADD MASKED WITH (FUNCTION='default()');

	EXECUTE AS USER ='HRManager';
	SELECT *
	FROM Sales.OrdersDDM AS O 
	INNER JOIN HR.EmployeesDDM as E ON E.empid = O.empid;
	REVERT;
	
	EXECUTE AS USER ='Salesperson';
	SELECT *
	FROM Sales.OrdersDDM AS O 
	INNER JOIN HR.EmployeesDDM as E ON E.empid = O.empid;
	REVERT;

	EXECUTE AS USER ='HRPayrollHead';
	SELECT *
	FROM Sales.OrdersDDM AS O 
	INNER JOIN HR.EmployeesDDM as E ON E.empid = O.empid;
	REVERT;