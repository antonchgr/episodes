/*********************************************************************************************************************

	CARDINALITY ESTIMATION (CE) FEEDBACK
	SQL SERVER 2022
	WHAT'S NEW IN IQP

	Download the AdventureWorks2016_EXT sample backup from 
	https://github.com/Microsoft/sql-server-samples/releases/download/adventureworks/AdventureWorks2016_EXT.bak


*********************************************************************************************************************/

-- Restore Database

USE master;
GO

DROP DATABASE IF EXISTS AdventureWorks2022_EXT;
GO
RESTORE DATABASE AdventureWorks2022_EXT FROM DISK = 'D:\SampleDatabases\AdventureWorks2016_EXT.bak'
WITH MOVE 'AdventureWorks2016_EXT_Data' TO 'D:\MSSQL16.RC1\MSSQL\DATA\AdventureWorks2022_EXT_Data.mdf',
MOVE 'AdventureWorks2016_EXT_Log' TO 'D:\MSSQL16.RC1\MSSQL\DATA\AdventureWorks2022_EXT_log.ldf',
MOVE 'AdventureWorks2016_EXT_Mod' TO 'D:\MSSQL16.RC1\MSSQL\DATA\AdventureWorks2022_EXT_mod'
GO

-- Create and start an Extended Events session to view feedback events. 
-- Use SSMS in Object Explorer to view the session with Watch Live Data.
IF EXISTS (SELECT * FROM sys.server_event_sessions WHERE name = 'CEFeedback')
	DROP EVENT SESSION [CEFeedback] ON SERVER;
GO
CREATE EVENT SESSION [CEFeedback] ON SERVER 
ADD EVENT sqlserver.query_feedback_analysis(
    ACTION(sqlserver.query_hash_signed,sqlserver.query_plan_hash_signed,sqlserver.sql_text)),
ADD EVENT sqlserver.query_feedback_validation(
    ACTION(sqlserver.query_hash_signed,sqlserver.query_plan_hash_signed,sqlserver.sql_text))
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=NO_EVENT_LOSS,MAX_DISPATCH_LATENCY=1 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=OFF);
GO
ALTER EVENT SESSION [CEFeedback] ON SERVER STATE = START;
GO

-- Add an ncl index on City column for Person.Address 
USE AdventureWorks2022_EXT;
CREATE NONCLUSTERED INDEX [IX_Address_City] ON [Person].[Address] ([City] ASC);
GO

-- Set dbcompat to 160 and turn on query store and clear buffer cache
USE master;
ALTER DATABASE AdventureWorks2022_EXT SET COMPATIBILITY_LEVEL = 160;
ALTER DATABASE AdventureWorks2022_EXT SET QUERY_STORE CLEAR ALL;
GO
USE AdventureWorks2022_EXT;
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;
GO

-- Run a batch to prime CE feedback 
USE AdventureWorks2022_EXT;
GO
SELECT AddressLine1, City, PostalCode FROM Person.Address
WHERE StateProvinceID = 79
AND City = 'Redmond';
GO 15

-- Run the query a single time to active CE feedback 
USE AdventureWorks2022_EXT;
GO
SELECT AddressLine1, City, PostalCode FROM Person.Address
WHERE StateProvinceID = 79
AND City = 'Redmond';
GO

-- Run the queries to see if CE feedback is initiated. 
-- You should see a statement of PENDING_VALIDATION from the 2nd DMV query.
USE AdventureWorks2022_EXT;
SELECT * from sys.query_store_query_hints;
SELECT * from sys.query_store_plan_feedback;
GO

-- Re-Run the query a single time to active CE feedback 
USE AdventureWorks2022_EXT;
GO
SELECT AddressLine1, City, PostalCode FROM Person.Address
WHERE StateProvinceID = 79
AND City = 'Redmond';
GO

-- Re-Run the queries to see if CE feedback is initiated. 
-- You should see a statement of VERIFICATION_PASSED from the 2nd DMV query.
USE AdventureWorks2022_EXT;
SELECT * from sys.query_store_query_hints;
SELECT * from sys.query_store_plan_feedback;
GO

-- View the XEvent session data to see how feedback was provided and then verified to be faster. 
-- The query_feedback_validation event shows the feedback_validation_cpu_time is less than 
-- original_cpu_time.

-- Re-Run a batch to prime CE feedback 
USE AdventureWorks2022_EXT;
GO
SELECT AddressLine1, City, PostalCode FROM Person.Address
WHERE StateProvinceID = 79
AND City = 'Redmond';
GO 15

/*
	Using Query Store Reports for Top Resource Consuming Queries to compare the query 
	with different plans with and without the hint. 
	The plan with the hint (now using an Index Scan should be overall faster and consume less CPU). 
	This includes Total and Avg Duration and CPU.
*/

-- drop XE session
IF EXISTS (SELECT * FROM sys.server_event_sessions WHERE name = 'CEFeedback')
	DROP EVENT SESSION [CEFeedback] ON SERVER;
GO