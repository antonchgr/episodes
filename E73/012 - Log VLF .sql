/**************************************************************************************************************************************************************

	Transaction Log Virtual Log Files (VLF)

	The algorithms for how many VLFs you get when you create, grow, or auto-grow the log 
	
	* Up to SQL Server 2012  

	  - Less than 1 MB  : ignore this case.
	  - Up to 64 MB     : 4 new VLFs, each roughly 1/4 the size of the growth
	  - 64 MB to 1 GB   : 8 new VLFs, each roughly 1/8 the size of the growth
	  - More than 1 GB  : 16 new VLFs, each roughly 1/16 the size of the growth

	* SQL Server 2014 to 2019

	  if ( growth size <= 1/8 of current log size)
	  {
	    1 VLF created equal to the growth size
	  }
	  else
	  {
		use the alogorithm up to SQL Server 2012
	  }

	* SQL Server 2022

	  if ( growth size > 1/8 of current log size) and ( growth size <= 64mb)
	  {
	    1 VLF created equal to the growth size
	  }
	  else
	  {
		use the alogorithm up to SQL Server 2012
	  }

	  https://docs.microsoft.com/en-us/sql/relational-databases/logs/manage-the-size-of-the-transaction-log-file?view=sql-server-ver16#Recommendations
************************************************************************************************************************************************************/

USE master;
DROP DATABASE IF EXISTS T;
GO

CREATE DATABASE [T]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'T', FILENAME = N'D:\MSSQL16.RC0\MSSQL\DATA\T.mdf' , SIZE = 64MB , FILEGROWTH = 64MB )
 LOG ON 
( NAME = N'T_log', FILENAME = N'D:\MSSQL16.RC0\MSSQL\DATA\T_log.ldf' , SIZE = 8MB , FILEGROWTH = 0)
GO

DBCC LOGINFO (T);
SELECT * FROM sys.dm_db_log_info(db_id('T'));
GO

USE [master]
-- 8MB / 8 = 1  -> + 64MB
ALTER DATABASE T MODIFY FILE ( NAME = N'T_log', SIZE = 72MB ) -- 64MB
SELECT * FROM sys.dm_db_log_info(db_id('T'));
GO

USE [master]
ALTER DATABASE T MODIFY FILE ( NAME = N'T_log', SIZE = 136MB ) -- 64MB
SELECT * FROM sys.dm_db_log_info(db_id('T'));
GO

USE [master]
ALTER DATABASE T MODIFY FILE ( NAME = N'T_log', SIZE = 200MB ) -- 64MB
SELECT * FROM sys.dm_db_log_info(db_id('T'));
GO

USE [master]
-- 200MB / 8 ~= 29  -> + 64MB
ALTER DATABASE T MODIFY FILE ( NAME = N'T_log', SIZE = 264MB )
SELECT * FROM sys.dm_db_log_info(db_id('T'));
GO

USE [master]
-- 264MB / 8 = 33  -> + 64MB
ALTER DATABASE T MODIFY FILE ( NAME = N'T_log', SIZE = 328MB ) 
SELECT * FROM sys.dm_db_log_info(db_id('T'));
GO

USE [master]
-- 328MB / 8 = 41  -> + 64MB
ALTER DATABASE T MODIFY FILE ( NAME = N'T_log', SIZE = 392MB ) 
SELECT * FROM sys.dm_db_log_info(db_id('T'));
GO

USE [master]
-- 392MB / 8 = 49 -> + 64MB
ALTER DATABASE T MODIFY FILE ( NAME = N'T_log', SIZE = 456MB ) 
SELECT * FROM sys.dm_db_log_info(db_id('T'));
GO

USE [master]
-- 456MB / 8 = 57 -> + 64MB
ALTER DATABASE T MODIFY FILE ( NAME = N'T_log', SIZE = 520MB ) 
SELECT * FROM sys.dm_db_log_info(db_id('T'));
GO


USE [master]
-- 520MB / 8 = 65 -> + 64MB
ALTER DATABASE T MODIFY FILE ( NAME = N'T_log', SIZE = 584MB ) 
SELECT * FROM sys.dm_db_log_info(db_id('T'));
GO


USE [master]
-- 584MB / 8 = 73 -> + 64MB
ALTER DATABASE T MODIFY FILE ( NAME = N'T_log', SIZE = 648MB ) 
SELECT * FROM sys.dm_db_log_info(db_id('T'));
GO

USE [master]
-- 648MB / 8 = 81 -> + 128MB
ALTER DATABASE T MODIFY FILE ( NAME = N'T_log', SIZE = 776MB ) 
SELECT * FROM sys.dm_db_log_info(db_id('T'));
GO

/******************************************************************************************************/

USE master;
DROP DATABASE IF EXISTS T;
GO

CREATE DATABASE [T]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'T', FILENAME = N'D:\MSSQL16.RC0\MSSQL\DATA\T.mdf' , SIZE = 64MB , FILEGROWTH = 64MB )
 LOG ON 
( NAME = N'T_log', FILENAME = N'D:\MSSQL16.RC0\MSSQL\DATA\T_log.ldf' , SIZE = 1MB , FILEGROWTH = 0)
GO

USE T;
SELECT 
	db_name() AS database_name, 
	name AS logical_file_name, 
	type_desc AS file_type_desc,
	size/128.0 AS current_size_mb, 
	size/128.0 - cast(fileproperty(name, 'spaceused') as int)/128.0 AS free_space_mb 
FROM 
	sys.database_files
GO


DBCC LOGINFO (T);
SELECT * FROM sys.dm_db_log_info(db_id('T'));
GO

/******************************************************************************************************/

USE master;
DROP DATABASE IF EXISTS T;
GO

CREATE DATABASE [T]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'T', FILENAME = N'D:\MSSQL16.RC0\MSSQL\DATA\T.mdf' , SIZE = 64MB , FILEGROWTH = 64MB )
 LOG ON 
( NAME = N'T_log', FILENAME = N'D:\MSSQL16.RC0\MSSQL\DATA\T_log.ldf' , SIZE = 64MB , FILEGROWTH = 0)
GO

SELECT * FROM sys.dm_db_log_info(db_id('T'));
GO

/******************************************************************************************************/

USE master;
DROP DATABASE IF EXISTS T;
GO

CREATE DATABASE [T]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'T', FILENAME = N'D:\MSSQL16.RC0\MSSQL\DATA\T.mdf' , SIZE = 64MB , FILEGROWTH = 64MB )
 LOG ON 
( NAME = N'T_log', FILENAME = N'D:\MSSQL16.RC0\MSSQL\DATA\T_log.ldf' , SIZE = 1GB , FILEGROWTH = 0)
GO

SELECT * FROM sys.dm_db_log_info(db_id('T'));
GO

/******************************************************************************************************/

USE master;
DROP DATABASE IF EXISTS T;
GO

CREATE DATABASE [T]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'T', FILENAME = N'D:\MSSQL16.RC0\MSSQL\DATA\T.mdf' , SIZE = 64MB , FILEGROWTH = 64MB )
 LOG ON 
( NAME = N'T_log', FILENAME = N'D:\MSSQL16.RC0\MSSQL\DATA\T_log.ldf' , SIZE = 2GB , FILEGROWTH = 0)
GO

SELECT * FROM sys.dm_db_log_info(db_id('T'));
GO

/******************************************************************************************************/

USE [master]
ALTER DATABASE T MODIFY FILE ( NAME = N'T_log', SIZE = 2112MB ) -- +64MB
GO
SELECT * FROM sys.dm_db_log_info(db_id('T'));
GO

USE [master]
ALTER DATABASE T MODIFY FILE ( NAME = N'T_log', SIZE = 2375MB ) -- + less than 1/8
GO
SELECT * FROM sys.dm_db_log_info(db_id('T'));
GO

USE [master]
ALTER DATABASE T MODIFY FILE ( NAME = N'T_log', SIZE = 2672MB ) -- + more than 1/8
GO
SELECT * FROM sys.dm_db_log_info(db_id('T'));
GO

/******************************************************************************************************/

USE master;
DROP DATABASE IF EXISTS T;
GO

CREATE DATABASE [T]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'T', FILENAME = N'D:\MSSQL16.RC0\MSSQL\DATA\T.mdf' , SIZE = 64MB , FILEGROWTH = 64MB )
 LOG ON 
( NAME = N'T_log', FILENAME = N'D:\MSSQL16.RC0\MSSQL\DATA\T_log.ldf' , SIZE = 8192MB , FILEGROWTH = 0)
GO

SELECT * FROM sys.dm_db_log_info(db_id('T'));
GO

USE [master]
ALTER DATABASE T MODIFY FILE ( NAME = N'T_log', SIZE = 8256MB ) -- 64MB
SELECT * FROM sys.dm_db_log_info(db_id('T'));
GO

USE [master]
ALTER DATABASE T MODIFY FILE ( NAME = N'T_log', SIZE = 8768MB ) -- + 512MB
SELECT * FROM sys.dm_db_log_info(db_id('T'));
GO

USE [master]
ALTER DATABASE T MODIFY FILE ( NAME = N'T_log', SIZE = 9792MB ) -- + 1024 MB
SELECT * FROM sys.dm_db_log_info(db_id('T'));
GO

/******************************************************************************************************/

