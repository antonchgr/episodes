/*********************************************************************************************************************

	DEGREE OF PARALLELISM (DOP) FEEDBACK
	SQL SERVER 2022
	WHAT'S NEW IN IQP

	Download the WideWorldImportersDW database backup from 
	https://github.com/Microsoft/sql-server-samples/releases/download/wide-world-importers-v1.0/WideWorldImportersDW-Full.bak.

*********************************************************************************************************************/
USE master;
GO
-- configure MAXDOP to 0 for the instance.
sp_configure 'show advanced', 1;
GO
RECONFIGURE;
GO
sp_configure 'max degree of parallelism', 0;
GO
RECONFIGURE;
GO

-- restore database
USE master;
GO
declare @datafolder nvarchar(1000) =N'D:\MSSQL16.RC1\MSSQL\DATA\';
declare @tlogfolder nvarchar(1000) =N'D:\MSSQL16.RC1\MSSQL\DATA\';
declare @df1 nvarchar(1000), @df2 nvarchar(1000), @df3 nvarchar(1000),@tlf nvarchar(1000) ;
set @df1 = @datafolder + N'WorldWideImporters2022_DOP_data.mdf';
set @df2 = @datafolder + N'WorldWideImporters2022_DOP_UserData.ndf';
set @df3 = @datafolder + N'WorldWideImporters2022_DOP_InMemory_Data_1'
set @tlf = @tlogfolder + N'WorldWideImporters2022_DOP_log.ldf';

DROP DATABASE IF EXISTS WorldWideImporters2022_DOP;
RESTORE DATABASE WorldWideImporters2022_DOP
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

USE  WorldWideImporters2022_DOP
GO
-- Add StockItems to cause a data skew in Suppliers ~25min
DECLARE @StockItemID int = 228, 
		@StockItemName varchar(100) = 'Athens Acropolis Shirt ', 
		@SupplierID int = 4;

DELETE FROM Warehouse.StockItems WHERE StockItemID >= @StockItemID;
INSERT INTO Warehouse.StockItems
			(StockItemID, StockItemName, SupplierID, UnitPackageID, OuterPackageID, LeadTimeDays,
			QuantityPerOuter, IsChillerStock, TaxRate, UnitPrice, TypicalWeightPerUnit, LastEditedBy			)
SELECT n.n, @StockItemName + +convert(varchar(10), n.n), @SupplierID, 10, 9, 12, 100, 0, 15.00, 100.00, 0.300, 1
FROM tempdb.dbo.IntNums AS n WHERE n.n >@StockItemID AND n.n<=(@StockItemID + 20000000)+1;
GO
-- Rebuild Index
ALTER INDEX FK_Warehouse_StockItems_SupplierID ON Warehouse.StockItems REBUILD;
GO

-- Create stored procedure for my demo
CREATE OR ALTER PROCEDURE [Warehouse].[GetStockItemsbySupplier]  @SupplierID int
AS
BEGIN
	SELECT StockItemID, SupplierID, StockItemName, TaxRate, LeadTimeDays
	FROM Warehouse.StockItems s
	WHERE SupplierID = @SupplierID
	ORDER BY StockItemName;
END;
GO

-- Set QDS settings and db setting for DOP feedback.
-- Make sure QS is on and set runtime collection lower than default
USE WorldWideImporters2022_DOP;
GO
ALTER DATABASE CURRENT SET QUERY_STORE = ON;
ALTER DATABASE CURRENT SET QUERY_STORE (OPERATION_MODE = READ_WRITE, DATA_FLUSH_INTERVAL_SECONDS = 60, INTERVAL_LENGTH_MINUTES = 1, QUERY_CAPTURE_MODE = ALL);
ALTER DATABASE CURRENT SET QUERY_STORE CLEAR ALL;
GO
-- You must change dbcompat to 160
ALTER DATABASE CURRENT SET COMPATIBILITY_LEVEL = 160;
GO
-- Enable DOP feedback
ALTER DATABASE SCOPED CONFIGURATION SET DOP_FEEDBACK = ON;
GO
-- Clear proc cache to start with new plans
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;
GO

-- Create an XEvent session. 
-- Use SSMS to Watch the XE session to see Live Data.
IF EXISTS (SELECT * FROM sys.server_event_sessions WHERE name = 'DOPFeedback')
	DROP EVENT SESSION [DOPFeedback] ON SERVER;
GO
CREATE EVENT SESSION [DOPFeedback] ON SERVER 
ADD EVENT sqlserver.dop_feedback_eligible_query(
    ACTION(sqlserver.query_hash_signed,sqlserver.query_plan_hash_signed,sqlserver.sql_text)),
ADD EVENT sqlserver.dop_feedback_provided(
    ACTION(sqlserver.query_hash_signed,sqlserver.query_plan_hash_signed,sqlserver.sql_text)),
ADD EVENT sqlserver.dop_feedback_reverted(
    ACTION(sqlserver.query_hash_signed,sqlserver.query_plan_hash_signed,sqlserver.sql_text)),
ADD EVENT sqlserver.dop_feedback_stabilized(
    ACTION(sqlserver.query_hash_signed,sqlserver.query_plan_hash_signed,sqlserver.sql_text)),
ADD EVENT sqlserver.dop_feedback_validation(
    ACTION(sqlserver.query_hash_signed,sqlserver.query_plan_hash_signed,sqlserver.sql_text))
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=NO_EVENT_LOSS,MAX_DISPATCH_LATENCY=1 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=OFF);
GO
-- Start XE
ALTER EVENT SESSION [DOPFeedback] ON SERVER STATE = START;
GO

-- run C:\scripts\DOPFeedback.cmd

-- see the changes in DOP and resulting stats
-- the hash value of 4128150668158729174 should be fixed for the plan from the workload
SELECT	qsp.query_plan_hash, avg_duration/1000 as avg_duration_ms, 
		avg_cpu_time/1000 as avg_cpu_ms, last_dop, min_dop, max_dop, qsrs.count_executions
FROM sys.query_store_runtime_stats AS qsrs
JOIN sys.query_store_plan AS qsp ON qsrs.plan_id = qsp.plan_id
	 and qsp.query_plan_hash = CONVERT(varbinary(8), cast(4128150668158729174 as bigint))
ORDER by qsrs.last_execution_time;
GO

-- Use Top Resource Consuming Queries report and look at Avg Duration and Avg CPU 

SELECT * from sys.query_store_plan_feedback;
GO

