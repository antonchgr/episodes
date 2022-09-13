USE [master]
GO

CREATE LOGIN [Mitsos] WITH PASSWORD=N'.....' 
GO

ALTER SERVER ROLE [##MS_DatabaseConnector##] ADD MEMBER [Mitsos]
GO

-- open a new query and execute
USE TSQLV6
GO
SELECT * FROM Sales.Customers;
SELECT * FROM sys.dm_exec_sessions;
SELECT * FROM sys.tables;
SELECT * FROM INFORMATION_SCHEMA.TABLES;

