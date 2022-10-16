/*********************************************************************************************************************

	SQL SERVER PARAMETER SENSITIVE PLAN OPTIMIZATION
	SQL SERVER 2022
	WHAT'S NEW IN INTELLIGENT QUERY OPTIMIZATION

*********************************************************************************************************************/

USE WideWorldImporters2022;
GO

-- Add StockItems to cause a data skew in Suppliers
DELETE FROM Warehouse.StockItems WHERE StockItemID >= 228;
INSERT INTO Warehouse.StockItems
	(
		StockItemID, StockItemName, SupplierID, UnitPackageID, OuterPackageID, LeadTimeDays,
		QuantityPerOuter, IsChillerStock, TaxRate, UnitPrice, TypicalWeightPerUnit, LastEditedBy
	)
SELECT VALUE, 'Athens Greece Shirt'+convert(varchar(10), VALUE), 4, 10, 9, 12, 100, 0, 15.00, 100.00, 0.300, 1
FROM GENERATE_SERIES(228 , 4000000, 1)
GO

DELETE FROM Warehouse.StockItems WHERE StockItemID >= 4000001;
INSERT INTO Warehouse.StockItems
	(
		StockItemID, StockItemName, SupplierID, UnitPackageID, OuterPackageID, LeadTimeDays,
		QuantityPerOuter, IsChillerStock, TaxRate, UnitPrice, TypicalWeightPerUnit, LastEditedBy
	)
SELECT VALUE, 'Athens Greece Hat'+convert(varchar(10), VALUE), 5, 10, 9, 12, 100, 0, 15.00, 100.00, 0.300, 1
FROM GENERATE_SERIES(4000001 , 8000000, 1)
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


-- Until Now!!!
USE WideWorldImporters2022;
GO
ALTER DATABASE current SET COMPATIBILITY_LEVEL = 150;
GO
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;
GO
ALTER DATABASE current SET QUERY_STORE CLEAR;
GO

--
USE WideWorldImporters2022;
SET STATISTICS TIME ON;
SET STATISTICS IO ON;
GO

-- Actual Execution Plan
-- The best plan for this parameter is an index seek
EXEC Warehouse.GetStockItemsbySupplier 2; --x2
GO
EXEC Warehouse.GetStockItemsbySupplier 4; --x2
GO
-- The best plan for this parameter is an index scan
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;
GO
EXEC Warehouse.GetStockItemsbySupplier 4; --x2
GO

EXEC Warehouse.GetStockItemsbySupplier 2; --x2
GO

SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;
GO


-- Why?

SELECT sh.*
FROM sys.stats AS s
CROSS APPLY sys.dm_db_stats_histogram (s.object_id,s.stats_id) as sh
WHERE name = 'FK_Warehouse_StockItems_SupplierID' AND s.object_id = OBJECT_ID('Warehouse.StockItems')
GO

SELECT SupplierID, count(*) as supplier_count
FROM Warehouse.StockItems
GROUP BY SupplierID;
GO


-- SQL Server 2022
ALTER DATABASE CURRENT SET COMPATIBILITY_LEVEL = 160;
GO
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;
GO
ALTER DATABASE CURRENT SET QUERY_STORE CLEAR;
GO

SET STATISTICS TIME ON;
GO
SET STATISTICS IO ON;
GO


-- Actual Execution Plan
-- The best plan for this parameter is an index seek
EXEC Warehouse.GetStockItemsbySupplier 2; --x2
GO
EXEC Warehouse.GetStockItemsbySupplier 4; --x2
GO
-- Reverse
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;
GO
EXEC Warehouse.GetStockItemsbySupplier 4; --x2
GO
EXEC Warehouse.GetStockItemsbySupplier 2; --x2
GO

SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;
GO



-- QUERY QUERY STORE

EXEC sp_query_store_flush_db;
GO


-- each query is from the same parent_query_id and the query_hash is the same
SELECT 
	qt.query_sql_text, qq.query_id, qv.query_variant_query_id, qv.parent_query_id, 
	qq.query_hash,qr.count_executions, qp.plan_id, qv.dispatcher_plan_id, qp.query_plan_hash,
	cast(qp.query_plan as XML) as xml_plan
FROM sys.query_store_query_text qt
JOIN sys.query_store_query qq ON qt.query_text_id = qq.query_text_id
JOIN sys.query_store_plan qp ON qq.query_id = qp.query_id
JOIN sys.query_store_query_variant qv ON qq.query_id = qv.query_variant_query_id
JOIN sys.query_store_runtime_stats qr ON qp.plan_id = qr.plan_id
ORDER BY qv.parent_query_id;
GO

-- the "parent" query
-- this is the SELECT statement from the procedure with no OPTION for variants.
SELECT qt.query_sql_text
FROM sys.query_store_query_text qt
JOIN sys.query_store_query qq ON qt.query_text_id = qq.query_text_id
JOIN sys.query_store_query_variant qv ON qq.query_id = qv.parent_query_id;
GO

-- the dispatcher plan
-- If you "click" on the SHOWPLAN XML output you will see a "multiple plans" operator
SELECT qp.plan_id, qp.query_plan_hash, cast (qp.query_plan as XML)
FROM sys.query_store_plan qp
JOIN sys.query_store_query_variant qv ON qp.plan_id = qv.dispatcher_plan_id;
GO