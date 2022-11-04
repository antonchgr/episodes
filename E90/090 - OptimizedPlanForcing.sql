/*********************************************************************************************************************

	OPTIMIZED PLAN FORCING
	SQL SERVER 2022
	WHAT'S NEW IN IQP

	Download the WideWorldImportersDW database backup from 
	https://github.com/Microsoft/sql-server-samples/releases/download/wide-world-importers-v1.0/WideWorldImportersDW-Full.bak.

*********************************************************************************************************************/

-- restore database
USE master;
GO
declare @datafolder nvarchar(1000) =N'D:\MSSQL16.RC1\MSSQL\DATA\';
declare @tlogfolder nvarchar(1000) =N'D:\MSSQL16.RC1\MSSQL\DATA\';
declare @df1 nvarchar(1000), @df2 nvarchar(1000), @df3 nvarchar(1000),@tlf nvarchar(1000) ;
set @df1 = @datafolder + N'WorldWideImporters2022_OPF_data.mdf';
set @df2 = @datafolder + N'WorldWideImporters2022_OPF_UserData.ndf';
set @df3 = @datafolder + N'WorldWideImporters2022_OPF_InMemory_Data_1'
set @tlf = @tlogfolder + N'WorldWideImporters2022_OPF_log.ldf';

DROP DATABASE IF EXISTS WorldWideImporters2022_OPF;
RESTORE DATABASE WorldWideImporters2022_OPF
FROM  
	DISK = N'D:\SampleDatabases\WideWorldImporters-Full.bak' 
WITH  
	FILE = 1,  
	MOVE N'WWI_Primary' TO @df1,  
	MOVE N'WWI_UserData' TO @df2,  
	MOVE N'WWI_Log' TO @tlf,  
	MOVE N'WWI_InMemory_Data_1' TO @df3,  
	STATS = 1;
GO


-- RUN QUERY

USE WorldWideImporters2022_OPF;
GO
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;
GO

SET STATISTICS TIME ON;
GO
SELECT o.OrderID, ol.OrderLineID, c.CustomerName, cc.CustomerCategoryName, p.FullName, city.CityName, sp.StateProvinceName,	country.CountryName, si.StockItemName
FROM Sales.Orders AS o
INNER JOIN Sales.Customers AS c ON o.CustomerID = c.CustomerID
INNER JOIN Sales.CustomerCategories AS cc ON c.CustomerCategoryID = cc.CustomerCategoryID
INNER JOIN Application.People AS p ON o.ContactPersonID = p.PersonID
INNER JOIN Application.Cities AS city ON city.CityID = c.DeliveryCityID
INNER JOIN Application.StateProvinces AS sp ON city.StateProvinceID = sp.StateProvinceID
INNER JOIN Application.Countries AS country ON sp.CountryID = country.CountryID
INNER JOIN Sales.OrderLines AS ol ON ol.OrderID = o.OrderID
INNER JOIN Warehouse.StockItems si ON ol.StockItemID = si.StockItemID
INNER JOIN Warehouse.StockItemStockGroups AS sisg ON si.StockItemID = sisg.StockItemID
UNION ALL
SELECT o.OrderID, ol.OrderLineID, c.CustomerName, cc.CustomerCategoryName, p.FullName, city.CityName, sp.StateProvinceName, country.CountryName, si.StockItemName
FROM Sales.Orders o
INNER JOIN Sales.Customers AS c ON o.CustomerID = c.CustomerID
INNER JOIN Sales.CustomerCategories AS cc ON c.CustomerCategoryID = cc.CustomerCategoryID
INNER JOIN Application.People AS p ON o.ContactPersonID = p.PersonID
INNER JOIN Application.Cities AS city ON city.CityID = c.DeliveryCityID
INNER JOIN Application.StateProvinces AS sp ON city.StateProvinceID = sp.StateProvinceID
INNER JOIN Application.Countries AS country ON sp.CountryID = country.CountryID
INNER JOIN Sales.OrderLines AS ol ON ol.OrderID = o.OrderID
INNER JOIN Warehouse.StockItems AS si ON ol.StockItemID = si.StockItemID
INNER JOIN Warehouse.StockItemStockGroups AS sisg ON si.StockItemID = sisg.StockItemID
ORDER BY OrderID;
GO

--SQL Server parse and compile time: 
--   CPU time ms		= 656  
--	 Elapsed time ms	= 676 

-- FIND QUERY IN QUERY STORE
-- Notice the column has_compile_replay_script has a value = 1. 
-- This means this query is a candidate for optimized plan forcing. 
-- Take note of the numbers for compile duration.
USE WorldWideImporters2022_OPF
GO
SELECT	query_id, plan_id, 
		avg_compile_duration/1000 as avg_compile_ms, 
		last_compile_duration/1000 as last_compile_ms, 
		has_compile_replay_script, 
		cast(query_plan as xml) query_plan_xml
FROM sys.query_store_plan;
GO
-- avg_complile_ms = 496.71	
-- last compile_ms = 496

-- FORCE PLAN
EXEC sp_query_store_force_plan @query_id = 41982, @plan_id = 516;
GO

-- RUN QUERY AGAIN
USE WorldWideImporters2022_OPF;
GO
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;
GO
SET STATISTICS TIME ON;
GO
SELECT o.OrderID, ol.OrderLineID, c.CustomerName, cc.CustomerCategoryName, p.FullName, city.CityName, sp.StateProvinceName,	country.CountryName, si.StockItemName
FROM Sales.Orders AS o
INNER JOIN Sales.Customers AS c ON o.CustomerID = c.CustomerID
INNER JOIN Sales.CustomerCategories AS cc ON c.CustomerCategoryID = cc.CustomerCategoryID
INNER JOIN Application.People AS p ON o.ContactPersonID = p.PersonID
INNER JOIN Application.Cities AS city ON city.CityID = c.DeliveryCityID
INNER JOIN Application.StateProvinces AS sp ON city.StateProvinceID = sp.StateProvinceID
INNER JOIN Application.Countries AS country ON sp.CountryID = country.CountryID
INNER JOIN Sales.OrderLines AS ol ON ol.OrderID = o.OrderID
INNER JOIN Warehouse.StockItems si ON ol.StockItemID = si.StockItemID
INNER JOIN Warehouse.StockItemStockGroups AS sisg ON si.StockItemID = sisg.StockItemID
UNION ALL
SELECT o.OrderID, ol.OrderLineID, c.CustomerName, cc.CustomerCategoryName, p.FullName, city.CityName, sp.StateProvinceName, country.CountryName, si.StockItemName
FROM Sales.Orders o
INNER JOIN Sales.Customers AS c ON o.CustomerID = c.CustomerID
INNER JOIN Sales.CustomerCategories AS cc ON c.CustomerCategoryID = cc.CustomerCategoryID
INNER JOIN Application.People AS p ON o.ContactPersonID = p.PersonID
INNER JOIN Application.Cities AS city ON city.CityID = c.DeliveryCityID
INNER JOIN Application.StateProvinces AS sp ON city.StateProvinceID = sp.StateProvinceID
INNER JOIN Application.Countries AS country ON sp.CountryID = country.CountryID
INNER JOIN Sales.OrderLines AS ol ON ol.OrderID = o.OrderID
INNER JOIN Warehouse.StockItems AS si ON ol.StockItemID = si.StockItemID
INNER JOIN Warehouse.StockItemStockGroups AS sisg ON si.StockItemID = sisg.StockItemID
ORDER BY OrderID;
GO

-- FLUSH QDS

USE WorldWideImporters2022_OPF
GO
EXEC sys.sp_query_store_flush_db;
GO

-- FIND QUERY IN QUERY STORE
-- Notice the column has_compile_replay_script has a value = 1. 
-- This means this query is a candidate for optimized plan forcing. 
-- Take note of the numbers for compile duration.
USE WorldWideImporters2022_OPF
GO
SELECT	query_id, plan_id, 
		avg_compile_duration/1000 as avg_compile_ms, 
		last_compile_duration/1000 as last_compile_ms, 
		has_compile_replay_script, 
		cast(query_plan as xml) query_plan_xml
FROM sys.query_store_plan;
GO
-- avg_complile_ms = 160	
-- last compile_ms = 48
