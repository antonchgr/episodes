/*********************************************************************************************************************

	QUERY STORE HINTS
	SQL SERVER 2022
	WHAT'S NEW IN QUERY STORE

	Download the WideWorldImportersDW database backup from 
	https://github.com/Microsoft/sql-server-samples/releases/download/wide-world-importers-v1.0/WideWorldImportersDW-Full.bak.

	
*********************************************************************************************************************/

-- Setup Demo Start

-- restore database
USE master;
GO
declare @datafolder nvarchar(1000) =N'D:\MSSQL16.RC1\MSSQL\DATA\';
declare @tlogfolder nvarchar(1000) =N'D:\MSSQL16.RC1\MSSQL\DATA\';
declare @df1 nvarchar(1000), @df2 nvarchar(1000), @df3 nvarchar(1000),@tlf nvarchar(1000) ;
set @df1 = @datafolder + N'WorldWideImporters2022_QSH_data.mdf';
set @df2 = @datafolder + N'WorldWideImporters2022_QSH_UserData.ndf';
set @df3 = @datafolder + N'WorldWideImporters2022_QSH_InMemory_Data_1'
set @tlf = @tlogfolder + N'WorldWideImporters2022_QSH_log.ldf';

DROP DATABASE IF EXISTS WorldWideImporters2022_QSH;
RESTORE DATABASE WorldWideImporters2022_QSH
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

USE WorldWideImporters2022_QSH
GO
-- Add StockItems to cause a data skew in Suppliers
DECLARE @StockItemID int = 228, 
		@StockItemName varchar(100) = 'Athens Acropolis Shirt ', 
		@SupplierID int = 4;
DELETE FROM Warehouse.StockItems WHERE StockItemID >= @StockItemID;
INSERT INTO Warehouse.StockItems
			(StockItemID, StockItemName, SupplierID, UnitPackageID, OuterPackageID, LeadTimeDays,
			QuantityPerOuter, IsChillerStock, TaxRate, UnitPrice, TypicalWeightPerUnit, LastEditedBy			)
SELECT n.n, @StockItemName + +convert(varchar(10), n.n), @SupplierID, 10, 9, 12, 100, 0, 15.00, 100.00, 0.300, 1
FROM tempdb.dbo.IntNums AS n WHERE n.n >@StockItemID AND n.n<=(@StockItemID + 8000000)+1;
GO
-- Rebuild Index
ALTER INDEX FK_Warehouse_StockItems_SupplierID ON Warehouse.StockItems REBUILD;
GO -- Setup Demo End

-- Demo stored procedure
CREATE OR ALTER PROCEDURE [Warehouse].[GetStockItemsbySupplier]  @SupplierID int
AS
BEGIN
	SELECT	 StockItemID, SupplierID, StockItemName, TaxRate, LeadTimeDays
	FROM	 Warehouse.StockItems AS s
	WHERE  	 SupplierID = @SupplierID
	ORDER BY StockItemName;
END;
GO

-- setup database 
USE WorldWideImporters2022_QSH
GO
ALTER DATABASE CURRENT SET COMPATIBILITY_LEVEL = 150; --110
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;
ALTER DATABASE CURRENT SET QUERY_STORE CLEAR;
ALTER DATABASE CURRENT SET QUERY_STORE = ON;
ALTER DATABASE CURRENT SET QUERY_STORE (QUERY_CAPTURE_MODE= ALL);
SELECT actual_state_desc FROM sys.database_query_store_options;
GO


-- Display Actual Execution Plan
USE WorldWideImporters2022_QSH
GO
EXEC Warehouse.GetStockItemsbySupplier 2;
EXEC Warehouse.GetStockItemsbySupplier 4;
GO

-- Why?

SELECT		sh.*
FROM		sys.stats AS s
CROSS APPLY sys.dm_db_stats_histogram (s.object_id,s.stats_id) as sh
WHERE		name = 'FK_Warehouse_StockItems_SupplierID' AND s.object_id = OBJECT_ID('Warehouse.StockItems')
GO


-- find query id
SELECT		query_sql_text, q.query_id
FROM 		sys.query_store_query_text AS qt 
INNER JOIN	sys.query_store_query AS q ON qt.query_text_id = q.query_text_id 
WHERE		query_sql_text like N'%ORDER BY StockItemName%' 
			and 
			query_sql_text not like N'%query_store%';
GO

-- add hint
EXEC sp_query_store_set_hints @query_id=1, @value = N'OPTION(RECOMPILE)';
GO
-- remove hind
EXEC sp_query_store_clear_hints @query_id =1;
GO

/*
  Returns query hints from Query Store hints.
  
  Column name							Data type		Description
  -----------------------------------	--------------- --------------------------------------------------------------------------------------
  query_hint_id							bigint			Unique identifier of a query hint.
  query_id								bigint			Unique identifier of a query in the Query Store. (FK->sys.query_store_query.query_id.)
  query_hint_text						nvarchar(MAX)	Hint definition in form of N'OPTION (…)
  last_query_hint_failure_reason		int				Error code (message_id) returned when if applying hints failed. 
  last_query_hint_failure_reason_desc	nvarchar(128)	Will include the error description of the error message.
  query_hint_failure_count				bigint			Number of times that the query hint application
  source								int				Source of QS hint= 0:user, <>0:system-generated
  source_desc							nvarchar(128)	Description of source of Query Store hint.
  comment								nvarchar(max)	Internal use only.
*/
SELECT	query_hint_id, query_id, query_hint_text, last_query_hint_failure_reason, 
		last_query_hint_failure_reason_desc, query_hint_failure_count, source, source_desc
FROM	sys.query_store_query_hints;
GO

-- show execution plan
EXEC Warehouse.GetStockItemsbySupplier 2;
EXEC Warehouse.GetStockItemsbySupplier 4;
GO


