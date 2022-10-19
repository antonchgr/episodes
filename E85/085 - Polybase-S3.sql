/*********************************************************************************************************************

	DATA LAKE VIRTUALIZATION WITH S3 COMPATIBLE OBJECT STORAGE
	SQL SERVER 2022
	WHAT'S NEW IN ANALYTICS - POLYBASE

*********************************************************************************************************************/

-- enable polybase
EXEC sp_configure 'polybase enabled', 1;
GO
RECONFIGURE;
GO
EXEC sp_configure 'allow polybase export', 1;
GO
RECONFIGURE;
GO

-- create master key
USE [WideWorldImporters2022]
GO
IF NOT EXISTS (SELECT * FROM sys.symmetric_keys WHERE name = '##MS_DatabaseMasterKey##')
	CREATE MASTER KEY ENCRYPTION BY PASSWORD = '@@Pa55w.rd##';
GO

-- create s3 creds
USE [WideWorldImporters2022];
GO
IF EXISTS (SELECT * FROM sys.external_data_sources WHERE name = 's3_wwi')
	DROP EXTERNAL DATA SOURCE s3_wwi;
IF EXISTS (SELECT * FROM sys.database_scoped_credentials WHERE name = 's3_wwi_cred')
    DROP DATABASE SCOPED CREDENTIAL s3_wwi_cred;
GO
CREATE DATABASE SCOPED CREDENTIAL s3_wwi_cred
WITH IDENTITY = 'S3 Access Key',
SECRET = 'user:password';
GO

-- create s3 datasource
USE [WideWorldImporters2022];
GO
IF EXISTS (SELECT * FROM sys.external_data_sources WHERE name = 's3_wwi')
	DROP EXTERNAL DATA SOURCE s3_wwi;
GO
CREATE EXTERNAL DATA SOURCE s3_wwi
WITH
(
 LOCATION = 's3://192.168.1.16:9000'
,CREDENTIAL = s3_wwi_cred
);
GO

-- create parquet file format
USE [WideWorldImporters2022];
GO
IF EXISTS (SELECT * FROM sys.external_file_formats WHERE name = 'ParquetFileFormat')
	DROP EXTERNAL FILE FORMAT ParquetFileFormat;
CREATE EXTERNAL FILE FORMAT ParquetFileFormat WITH(FORMAT_TYPE = PARQUET);
GO

-- wwi_cetas - https
USE [WideWorldImporters2022];
GO
IF OBJECT_ID('wwi_customer_transactions', 'U') IS NOT NULL
	DROP EXTERNAL TABLE wwi_customer_transactions;
GO
CREATE EXTERNAL TABLE wwi_customer_transactions
WITH (
    LOCATION = '/wwi/',
    DATA_SOURCE = s3_wwi,  
    FILE_FORMAT = ParquetFileFormat
) 
AS
SELECT * FROM Sales.CustomerTransactions;
GO

-- query wwi external data

SELECT COUNT(*) FROM wwi_customer_transactions

USE [WideWorldImporters2022];
GO
SELECT c.CustomerName, SUM(wct.OutstandingBalance) as total_balance
FROM wwi_customer_transactions wct
JOIN Sales.Customers c
ON wct.CustomerID = c.CustomerID
GROUP BY c.CustomerName
ORDER BY total_balance DESC;
GO

-- ssms object explorer

-- query by openrowset

USE [WideWorldImporters2022];
GO
SELECT *
FROM OPENROWSET
	(BULK '/wwi/'
	, FORMAT = 'PARQUET'
	, DATA_SOURCE = 's3_wwi')
as [wwi_customer_transactions_file];
GO

-- query by external table

USE [WideWorldImporters2022];
GO
IF OBJECT_ID('wwi_customer_transactions_base', 'U') IS NOT NULL
	DROP EXTERNAL TABLE wwi_customer_transactions_base;
GO
CREATE EXTERNAL TABLE wwi_customer_transactions_base 
( 
	CustomerTransactionID int, 
	CustomerID int,
	TransactionTypeID int,
	TransactionDate date,
	TransactionAmount decimal(18,2)
)
WITH 
(
	LOCATION = '/wwi/'
    , FILE_FORMAT = ParquetFileFormat
    , DATA_SOURCE = s3_wwi
);
GO
SELECT * FROM wwi_customer_transactions_base;
GO

-- create stats

USE [WideWorldImporters2022];
GO
CREATE STATISTICS wwi_ctb_stats ON wwi_customer_transactions_base (CustomerID) WITH FULLSCAN;
GO


-- explore metadata

USE [WideWorldImporters2022];
GO
SELECT * FROM sys.external_data_sources;
GO
SELECT * FROM sys.external_file_formats;
GO
SELECT * FROM sys.external_tables;
GO

-- get parquet metadata

USE [WideWorldImporters2022];
GO
EXEC sp_describe_first_result_set N'
SELECT *
FROM OPENROWSET
	(BULK ''/wwi/''
	, FORMAT = ''PARQUET''
	, DATA_SOURCE = ''s3_wwi'')
as [wwi_customer_transactions_file];';
GO

-- get file metadata

USE [WideWorldImporters2022];
GO
SELECT TOP 1 wwi_customer_transactions_file.filepath(), 
wwi_customer_transactions_file.filename()
FROM OPENROWSET
	(BULK '/wwi/'
	, FORMAT = 'PARQUET'
	, DATA_SOURCE = 's3_wwi')
as [wwi_customer_transactions_file];
GO

----- delta
-- query delta table

USE [WideWorldImporters2022];
GO
SELECT * FROM OPENROWSET
(BULK '/delta/people-10m', 
FORMAT = 'DELTA', DATA_SOURCE = 's3_wwi') as [people];
GO

-- query by ssn

USE [WideWorldImporters2022];
GO
SELECT * FROM OPENROWSET
(BULK '/delta/people-10m', 
FORMAT = 'DELTA', DATA_SOURCE = 's3_wwi') as [people]
WHERE [people].ssn = '992-28-8780';
GO

-- query by id

USE [WideWorldImporters2022];
GO
SELECT * FROM OPENROWSET
(BULK '/delta/people-10m', 
FORMAT = 'DELTA', DATA_SOURCE = 's3_wwi') as [people]
WHERE [people].id = 10000000;
GO

-- create parquet from delta

USE [WideworldImporters2022];
GO
IF EXISTS (SELECT * FROM sys.objects WHERE NAME = 'PEOPLE10M_60s')
	DROP EXTERNAL TABLE PEOPLE10M_60s;
GO
CREATE EXTERNAL TABLE PEOPLE10M_60s
WITH 
(   LOCATION = '/delta/1960s',
    DATA_SOURCE = s3_wwi,  
    FILE_FORMAT = ParquetFileFormat)  
AS
SELECT * FROM OPENROWSET
(BULK '/delta/people-10m', FORMAT = 'DELTA', DATA_SOURCE = 's3_wwi') as [people]
WHERE YEAR(people.birthDate) > 1959 AND YEAR(people.birthDate) < 1970;
GO

-- query 1960s people

USE [WideWorldImporters2022];
GO
SELECT * FROM PEOPLE10M_60s
ORDER BY birthDate;
GO
