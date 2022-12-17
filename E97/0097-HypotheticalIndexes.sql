USE HellasGate2022;
GO

DECLARE @od DATE = '20220101';
SELECT * FROM sales.OrdersHeader WHERE orderdate = @od;
GO

CREATE NONCLUSTERED INDEX hypoindex
ON sales.OrdersHeader (orderdate) with statistics_only;
GO

--------

DBCC TRACEON (2588);
DBCC HELP ( 'AUTOPILOT' );
GO

-------

SELECT   DB_ID() as dbid
    ,    OBJECT_ID('sales.OrdersHeader') as tabid
    ,    INDEXPROPERTY(OBJECT_ID('sales.OrdersHeader'), 'hypoindex', 'IndexID') as indid;
GO

-- dbcc AUTOPILOT (typeid [, dbid [, {maxQueryCost | tabid [, indid [, pages [, flag [, rowcounts]]]]} ]])
DBCC AUTOPILOT (5,13);
DBCC AUTOPILOT (0,13,1461580245,6);
GO

--------
SET AUTOPILOT ON;
GO

DECLARE @od DATE = '20220101';
SELECT * FROM sales.OrdersHeader WHERE orderdate = @od;
GO

SET AUTOPILOT OFF;
GO

SELECT  SCHEMA_NAME(o.schema_id) as schema_name
    ,   o.name as table_name
    ,   i.name as index_name
	,	CONCAT('DROP INDEX ', QUOTENAME(i.name),' ON ',QUOTENAME(SCHEMA_NAME(o.schema_id)),'.',QUOTENAME(o.name)) AS drop_index
FROM sys.indexes as i
INNER JOIN sys.objects as o ON o.object_id = i.object_id
WHERE is_hypothetical=1

DROP INDEX [hypoindex] ON [sales].[OrdersHeader]