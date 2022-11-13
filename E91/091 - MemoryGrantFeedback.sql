/*********************************************************************************************************************

	MEMORY GRANT FEEDBACK
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
set @df1 = @datafolder + N'WorldWideImporters2022_MGF_data.mdf';
set @df2 = @datafolder + N'WorldWideImporters2022_MGF_UserData.ndf';
set @df3 = @datafolder + N'WorldWideImporters2022_MGF_InMemory_Data_1'
set @tlf = @tlogfolder + N'WorldWideImporters2022_MGF_log.ldf';

DROP DATABASE IF EXISTS WorldWideImporters2022_MGF;
RESTORE DATABASE WorldWideImporters2022_MGF
FROM  
	DISK = N'D:\SampleDatabases\WideWorldImportersDW-Full.bak' 
WITH  
	FILE = 1,  
	MOVE N'WWI_Primary' TO @df1,  
	MOVE N'WWI_UserData' TO @df2,  
	MOVE N'WWIDW_InMemory_Data_1' TO @df3,  
	MOVE N'WWI_Log' TO @tlf,  
	STATS = 1;
GO

-- EXTEND TABLES

USE WorldWideImporters2022_MGF;
GO

DROP TABLE IF EXISTS Fact.OrderHistory;
GO

SELECT [Order Key], [City Key], [Customer Key], [Stock Item Key], [Order Date Key], [Picked Date Key], [Salesperson Key], [Picker Key], [WWI Order ID], [WWI Backorder ID], Description, Package, Quantity, [Unit Price], [Tax Rate], [Total Excluding Tax], [Tax Amount], [Total Including Tax], [Lineage Key]
INTO Fact.OrderHistory
FROM Fact.[Order];
GO

ALTER TABLE Fact.OrderHistory
ADD CONSTRAINT PK_Fact_OrderHistory PRIMARY KEY NONCLUSTERED([Order Key] ASC, [Order Date Key] ASC)WITH(DATA_COMPRESSION=PAGE);
GO

CREATE INDEX IX_Stock_Item_Key
ON Fact.OrderHistory([Stock Item Key])
INCLUDE(Quantity)
WITH(DATA_COMPRESSION=PAGE);
GO

CREATE INDEX IX_OrderHistory_Quantity
ON Fact.OrderHistory([Quantity])
INCLUDE([Order Key])
WITH(DATA_COMPRESSION=PAGE);
GO

-- Make the table bigger
INSERT Fact.OrderHistory([City Key], [Customer Key], [Stock Item Key], [Order Date Key], [Picked Date Key], [Salesperson Key], [Picker Key], [WWI Order ID], [WWI Backorder ID], Description, Package, Quantity, [Unit Price], [Tax Rate], [Total Excluding Tax], [Tax Amount], [Total Including Tax], [Lineage Key])
SELECT [City Key], [Customer Key], [Stock Item Key], [Order Date Key], [Picked Date Key], [Salesperson Key], [Picker Key], [WWI Order ID], [WWI Backorder ID], Description, Package, Quantity, [Unit Price], [Tax Rate], [Total Excluding Tax], [Tax Amount], [Total Including Tax], [Lineage Key]
FROM Fact.OrderHistory;
GO 4


-- INIT DEMO
USE WorldWideImporters2022_MGF
GO
ALTER DATABASE WorldWideImporters2022_MGF SET COMPATIBILITY_LEVEL = 150;
GO
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;
GO
ALTER DATABASE WorldWideImporters2022_MGF SET QUERY_STORE CLEAR ALL;
GO

-- make out of date statistics
UPDATE STATISTICS Fact.OrderHistory 
WITH ROWCOUNT = 1000;
GO

-- QUERY ACTUAL PLAN
USE WorldWideImporters2022_MGF
GO
SELECT	fo.[Order Key], fo.Description, si.[Lead Time Days]
FROM	Fact.OrderHistory AS fo
INNER HASH JOIN 
		Dimension.[Stock Item] AS si ON fo.[Stock Item Key] = si.[Stock Item Key]
WHERE	fo.[Lineage Key] = 9 
		AND 
		si.[Lead Time Days] > 19;
GO

-- CHECK MEMORY FEEDBACK
USE WorldWideImporters2022_MGF
GO
SELECT	qpf.feature_desc, qpf.feedback_data, qpf.state_desc, qt.query_sql_text, 
		(qrs.last_query_max_used_memory * 8192)/1024 as last_query_memory_kb
FROM sys.query_store_plan_feedback AS qpf 
INNER JOIN sys.query_store_plan AS qp ON qpf.plan_id = qp.plan_id
INNER JOIN sys.query_store_query AS qq ON qp.query_id = qq.query_id
INNER JOIN sys.query_store_query_text AS qt ON qq.query_text_id = qt.query_text_id
INNER JOIN sys.query_store_runtime_stats AS qrs ON qp.plan_id = qrs.plan_id;
GO

-- RE-RUN QUERY ACTUAL PLAN
USE WorldWideImporters2022_MGF
GO
SELECT	fo.[Order Key], fo.Description, si.[Lead Time Days]
FROM	Fact.OrderHistory AS fo
INNER HASH JOIN 
		Dimension.[Stock Item] AS si ON fo.[Stock Item Key] = si.[Stock Item Key]
WHERE	fo.[Lineage Key] = 9 
		AND 
		si.[Lead Time Days] > 19;
GO

-- CHECK MEMORY FEEDBACK
USE WorldWideImporters2022_MGF
GO
SELECT	qpf.feature_desc, qpf.feedback_data, qpf.state_desc, qt.query_sql_text, 
		(qrs.last_query_max_used_memory * 8192)/1024 as last_query_memory_kb
FROM sys.query_store_plan_feedback AS qpf 
INNER JOIN sys.query_store_plan AS qp ON qpf.plan_id = qp.plan_id
INNER JOIN sys.query_store_query AS qq ON qp.query_id = qq.query_id
INNER JOIN sys.query_store_query_text AS qt ON qq.query_text_id = qt.query_text_id
INNER JOIN sys.query_store_runtime_stats AS qrs ON qp.plan_id = qrs.plan_id;
GO

-- CLEAR BUFFER CACHE
USE WorldWideImporters2022_MGF
GO
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;
GO

-- RE-RUN QUERY
USE WorldWideImporters2022_MGF
GO
SELECT	fo.[Order Key], fo.Description, si.[Lead Time Days]
FROM	Fact.OrderHistory AS fo
INNER HASH JOIN 
		Dimension.[Stock Item] AS si ON fo.[Stock Item Key] = si.[Stock Item Key]
WHERE	fo.[Lineage Key] = 9 
		AND 
		si.[Lead Time Days] > 19;
GO

-- CHECK MEMORY FEEDBACK
-- IN PREVIOUS VERSIONS OF SQL SERVER THIS WOULD HAVE LOST MGF
USE WorldWideImporters2022_MGF
GO
SELECT	qpf.feature_desc, qpf.feedback_data, qpf.state_desc, qt.query_sql_text, 
		(qrs.last_query_max_used_memory * 8192)/1024 as last_query_memory_kb
FROM sys.query_store_plan_feedback AS qpf 
INNER JOIN sys.query_store_plan AS qp ON qpf.plan_id = qp.plan_id
INNER JOIN sys.query_store_query AS qq ON qp.query_id = qq.query_id
INNER JOIN sys.query_store_query_text AS qt ON qq.query_text_id = qt.query_text_id
INNER JOIN sys.query_store_runtime_stats AS qrs ON qp.plan_id = qrs.plan_id;
GO