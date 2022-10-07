/*********************************************************************************************************************

	LEDGER - DEMO 01
	SQL SERVER 2022 - WHAT'S NEW IN SECURITY

*********************************************************************************************************************/

-- SETUP

USE master;
GO

IF EXISTS (SELECT * FROM sys.server_principals WHERE NAME = 'HRUser')
	DROP LOGIN HRUser;
GO
CREATE LOGIN HRUser WITH PASSWORD = N'Pa55w.rd';
GO

-- CREATE LEDEGER DEMO DATABASE
IF EXISTS (SELECT * FROM sys.databases WHERE NAME = 'SQLschoolHR')
	ALTER DATABASE SQLschoolHR SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO
DROP DATABASE IF EXISTS SQLschoolHR;
CREATE DATABASE SQLschoolHR; -- WITH LEDGER=ON;
ALTER DATABASE SQLschoolHR SET ALLOW_SNAPSHOT_ISOLATION ON; -- Enable snapshot isolation to allow ledger to be verified
GO

-- SIMULATE EXISTING DATA
SELECT * 
INTO SQLschoolHR.dbo.Employees_NoLedger
FROM TSQLV6.HR.Employees
GO

-- ADD HRUser in SQLschoolHR 
USE SQLschoolHR;
CREATE USER HRUser FROM LOGIN HRUser;
EXEC sp_addrolemember 'db_owner', 'HRUser';
GO

-- ENABLE AUTOMATIC DIGEST STORAGE
USE master;
IF EXISTS (SELECT * FROM SYS.credentials WHERE NAME ='https://sql2022ledger.blob.core.windows.net/sqldbledgerdigests')
	DROP CREDENTIAL [https://sql2022ledger.blob.core.windows.net/sqldbledgerdigests]
GO

CREATE CREDENTIAL [https://sql2022ledger.blob.core.windows.net/sqldbledgerdigests]
WITH 
	IDENTITY ='SHARED ACCESS SIGNATURE'
,	SECRET = '....';
GO

USE SQLschoolHR;
SELECT * FROM sys.database_ledger_blocks;
SELECT * FROM sys.database_ledger_digest_locations
GO

USE SQLschoolHR;
SELECT * FROM sys.database_scoped_configurations;
GO

USE SQLschoolHR;
ALTER DATABASE SCOPED CONFIGURATION
 SET LEDGER_DIGEST_STORAGE_ENDPOINT = 'https://sql2022ledger.blob.core.windows.net';
GO
--ALTER DATABASE SCOPED CONFIGURATION SET LEDGER_DIGEST_STORAGE_ENDPOINT = OFF;

USE SQLschoolHR;
SELECT * FROM sys.database_scoped_configurations;
GO

USE SQLschoolHR;
SELECT * FROM sys.database_ledger_digest_locations
GO

-- CREATE TABLE SQLschoolHR.[dbo].[Employees]

USE SQLschoolHR
CREATE TABLE [dbo].[Employees](
	[empid] [int] IDENTITY(1,1) NOT NULL,
	[lastname] [nvarchar](20) NOT NULL,
	[firstname] [nvarchar](10) NOT NULL,
	[title] [nvarchar](30) NOT NULL,
	[titleofcourtesy] [nvarchar](25) NOT NULL,
	[birthdate] [date] NOT NULL,
	[hiredate] [date] NOT NULL,
	[address] [nvarchar](60) NOT NULL,
	[city] [nvarchar](15) NOT NULL,
	[region] [nvarchar](15) NULL,
	[postalcode] [nvarchar](10) NULL,
	[country] [nvarchar](15) NOT NULL,
	[phone] [nvarchar](24) NOT NULL,
	[mgrid] [int] NULL,
	[salary] [money] NOT NULL,
 CONSTRAINT [PK_Employees] PRIMARY KEY CLUSTERED 
(
	[empid] ASC
))
WITH 
(
  SYSTEM_VERSIONING = ON,
  LEDGER = ON
); 
GO

-- GET LEDGER OBJECTS & SSMS

USE SQLschoolHR
SELECT * FROM sys.ledger_table_history;
SELECT * FROM sys.ledger_column_history;
GO
-- VIEW CODE
EXEC sp_helptext 'dbo.Employees_ledger';
GO

-- MIGRATE TABLE DATA 

USE SQLschoolHR
EXEC sp_copy_data_in_batches 
		@source_table_name = N'dbo.Employees_NoLedger' , 
		@target_table_name = N'dbo.Employees'
GO

-- CHECK DATA
USE SQLschoolHR
SELECT * FROM dbo.Employees;
GO

USE SQLschoolHR
SELECT 
	[empid], [lastname], [firstname], [title], [titleofcourtesy], 
	[birthdate], [hiredate], [address], [city], [region], 
	[postalcode], [country], [phone], [mgrid], [salary], 
	[ledger_start_transaction_id], 
	[ledger_end_transaction_id], 
	[ledger_start_sequence_number], 
	[ledger_end_sequence_number]
FROM dbo.Employees;
GO


-- EXAMINE LEDGER HISTORY USING VIEW
USE SQLschoolHR
SELECT * FROM dbo.Employees_Ledger;
GO


-- COMBINE THE LEDGER VIEW WITH A SYSTEM TABLE TO GET MORE AUDITING INFORMATION. 
USE SQLschoolHR
SELECT	
	e.empid, e.lastname, e.firstname, e.title, e.titleofcourtesy, 
	e.birthdate, e.hiredate, e.[address], e.city, e.region, e.postalcode, 
	e.country, e.phone, e.mgrid, e.salary,
	dlt.transaction_id, 
	dlt.commit_time, 
	dlt.principal_name, 
	e.ledger_operation_type_desc, 
	dlt.table_hashes
FROM 
	sys.database_ledger_transactions AS dlt
JOIN 
	dbo.Employees_Ledger AS e ON e.ledger_transaction_id = dlt.transaction_id
ORDER BY 
	dlt.commit_time DESC;
GO

-- VERIFY THE INTEGRITY OF THE LEDGER
USE SQLschoolHR;
DECLARE @digest_locations NVARCHAR(MAX) = (SELECT * FROM sys.database_ledger_digest_locations FOR JSON AUTO, INCLUDE_NULL_VALUES);
SELECT @digest_locations as digest_locations;
BEGIN TRY
    EXEC sys.sp_verify_database_ledger_from_digest_storage @digest_locations;
    SELECT 'Ledger verification succeeded.' AS Result;
END TRY
BEGIN CATCH
    THROW;
END CATCH


USE SQLschoolHR;
EXEC sp_generate_database_ledger_digest;
GO
USE SQLschoolHR;
EXECUTE sp_verify_database_ledger N'{"database_name":"SQLschoolHR","block_id":1,"hash":"0xBBB104D3838C408130661A86FA47CD76FB82ECC43A671E6AE92E040A2CDE1B01","last_transaction_commit_time":"2022-10-06T23:12:45","digest_time":"2022-10-06T20:25:10.8243577"}'
GO

-- UPDATE ROW
USE SQLschoolHR;
SELECT empid,lastname,firstname,salary FROM dbo.Employees WHERE empid=8;
UPDATE DBO.Employees SET salary += 10000 WHERE empid=8;
SELECT empid,lastname,firstname,salary FROM dbo.Employees WHERE empid=8;
GO

-- AUDIT DATA
USE SQLschoolHR
SELECT	
	e.empid, e.lastname, e.firstname, e.title, e.titleofcourtesy, 
	e.birthdate, e.hiredate, e.[address], e.city, e.region, e.postalcode, 
	e.country, e.phone, e.mgrid, e.salary,
	dlt.transaction_id, 
	dlt.commit_time, 
	dlt.principal_name, 
	e.ledger_operation_type_desc, 
	dlt.table_hashes
FROM 
	sys.database_ledger_transactions AS dlt
JOIN 
	dbo.Employees_Ledger AS e ON e.ledger_transaction_id = dlt.transaction_id
ORDER BY 
	e.empid,dlt.commit_time DESC;
GO

-- VERIFY THE INTEGRITY OF THE LEDGER
USE SQLschoolHR;
DECLARE @digest_locations NVARCHAR(MAX) = (SELECT * FROM sys.database_ledger_digest_locations FOR JSON AUTO, INCLUDE_NULL_VALUES);
SELECT @digest_locations as digest_locations;
BEGIN TRY
    EXEC sys.sp_verify_database_ledger_from_digest_storage @digest_locations;
    SELECT 'Ledger verification succeeded.' AS Result;
END TRY
BEGIN CATCH
    THROW;
END CATCH
