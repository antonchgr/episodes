/**************************************************************************************************

	EPISODE #78 BY ANTONIOS CHATZIPAVLIS - SQLSCHOOL.GR
	SQL SERVER 2022 - WHAT'S NEW 
	SUBJECT : ASYNC_STATS_UPDATE_WAIT_AT_LOW_PRIORITY

***************************************************************************************************/

----------------------------------------------------------------------------------------------------
-- DEMO SETUP (~10min)
----------------------------------------------------------------------------------------------------

USE master;
GO
DROP DATABASE IF EXISTS SampleDB;
GO
CREATE DATABASE SampleDB;
GO

USE SampleDB;
CREATE TABLE dbo.T 
(
	col1 INT IDENTITY NOT NULL CONSTRAINT PK_T PRIMARY KEY , 
	col2 DATETIME2(7) DEFAULT (SYSDATETIME()),
	col3 INT NOT NULL,
	col4 CHAR(8000) NOT NULL

)
GO

CREATE INDEX T_IDX_COL3 ON dbo.T(col3);
GO

INSERT INTO dbo.T (col3,col4)
SELECT value % 1000,CAST(value as char) FROM GENERATE_SERIES(1,500000)
GO


----------------------------------------------------------------------------------------------------
-- STATMAN
----------------------------------------------------------------------------------------------------
USE SampleDB;
SELECT col1,col3 FROM dbo.T
WHERE col3 = 665;
GO

SELECT session_id,command,text,MIN(capture_datetime),MAX(capture_datetime)
FROM tempdb.dbo.dm_exec_requests_history
WHERE command = 'SELECT (STATMAN)'
	  AND 
	  text like 'SELECT col1,col3 FROM dbo.T%'  
GROUP BY session_id,command,text;

DBCC SHOW_STATISTICS ('dbo.T','T_IDX_COL3');
GO



----------------------------------------------------------------------------------------------------
-- CHECK STATISTICS
----------------------------------------------------------------------------------------------------

select
        OBJECT_NAME(s.[object_id]) as table_name
    ,    p.stats_id as statistic_id
    ,    s.[name] AS statistic_name
    ,    p.last_updated 
    ,    p.[rows]
    ,    p.rows_sampled
    ,    p.unfiltered_rows
    ,    p.modification_counter
	,	 sqrt(p.[rows] * 1000)
from sys.stats as s
outer apply sys.dm_db_stats_properties (s.[object_id],s.stats_id) as p
where OBJECTPROPERTY(p.[object_id],'IsUserTable')=1


DBCC SHOW_STATISTICS ('dbo.T','T_IDX_COL3');
GO


----------------------------------------------------------------------------------------------------
-- SETTINGS
----------------------------------------------------------------------------------------------------

USE [master]
GO
ALTER DATABASE [SampleDB] SET AUTO_UPDATE_STATISTICS_ASYNC ON WITH NO_WAIT
GO

ALTER DATABASE SCOPED CONFIGURATION 
SET ASYNC_STATS_UPDATE_WAIT_AT_LOW_PRIORITY  = ON;
GO

