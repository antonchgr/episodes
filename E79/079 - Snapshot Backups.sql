--------------------------------------------------------------------------------------------------
-- DEMO SETUP SAMPLEDB1
--------------------------------------------------------------------------------------------------
USE master;
GO
DROP DATABASE IF EXISTS SampleDB1;
GO
CREATE DATABASE SampleDB1;
GO

USE SampleDB1;
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
SELECT value,CAST(value as char) FROM GENERATE_SERIES(1,1000)
GO

--------------------------------------------------------------------------------------------------
-- DEMO SETUP SAMPLEDB2
--------------------------------------------------------------------------------------------------
USE master;
GO
DROP DATABASE IF EXISTS SampleDB2;
GO
CREATE DATABASE SampleDB2;
GO

USE SampleDB2;
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
SELECT value,CAST(value as char) FROM GENERATE_SERIES(1,1000)
GO


--------------------------------------------------------------------------------------------------
-- DELETE BACKUP HISTORY AND FILES
--------------------------------------------------------------------------------------------------

USE master;
EXEC msdb.dbo.sp_delete_database_backuphistory @database_name = N'SampleDB1';
EXEC msdb.dbo.sp_delete_database_backuphistory @database_name = N'SampleDB2';
GO
EXEC sys.xp_delete_files 'D:\MSSQL16.RC0\MSSQL\Backup\SampleDB*.*';
GO

--------------------------------------------------------------------------------------------------
-- SNAPSHOT BACKUP
--------------------------------------------------------------------------------------------------

SELECT COUNT(*) FROM SampleDB1.dbo.T;
GO

USE master;
GO
ALTER DATABASE SampleDB1 SET SUSPEND_FOR_SNAPSHOT_BACKUP=ON;
GO

/* EXECUTE IN NEW QUERY WINDOW
INSERT INTO SampleDB1.dbo.T (col3,col4) VALUES (1,'a')
GO
*/

-- TAKE SNAPSHOT
EXEC xp_cmdshell 'C:\SNAPSHOTS\getsnapshot.cmd', no_output;
GO

BACKUP DATABASE SampleDB1 TO DISK=N'D:\MSSQL16.RC0\MSSQL\Backup\SampleDB1_Snapshoot.bkm'
WITH METADATA_ONLY, FORMAT;
GO

SELECT COUNT(*) FROM SampleDB1.dbo.T;
GO

-- IF SNAPSHOT FAILED EXECUTE TO THAW DATABASE
ALTER DATABASE SampleDB1 SET SUSPEND_FOR_SNAPSHOT_BACKUP=OFF;
GO

--------------------------------------------------------------------------------------------------
-- DROP DATABASE
--------------------------------------------------------------------------------------------------

USE master;
ALTER DATABASE SampleDB1 SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO
DROP DATABASE IF EXISTS SampleDB1;
GO

--------------------------------------------------------------------------------------------------
-- SNAPSHOT RESTORE
--------------------------------------------------------------------------------------------------
RESTORE FILELISTONLY 
FROM DISK=N'D:\MSSQL16.RC0\MSSQL\Backup\SampleDB1_Snapshoot.bkm';
GO

-- MOUNT SNAPSHOT
EXEC xp_cmdshell 'C:\SNAPSHOTS\restoresnapshot.cmd', no_output;
GO

SELECT COUNT(*) FROM SampleDB1.dbo.T;
GO

USE master;
RESTORE DATABASE SampleDB1 
FROM DISK = N'D:\MSSQL16.RC0\MSSQL\Backup\SampleDB1_Snapshoot.bkm' 
WITH FILE = 1, METADATA_ONLY, REPLACE, DBNAME='SampleDB1';
GO

SELECT COUNT(*) FROM SampleDB1.dbo.T;
GO

--------------------------------------------------------------------------------------------------
-- GROUP SNAPSHOT BACKUP
--------------------------------------------------------------------------------------------------

SELECT COUNT(*) FROM SampleDB1.dbo.T WITH(NOLOCK);
SELECT COUNT(*) FROM SampleDB2.dbo.T WITH(NOLOCK);
GO

USE master;
GO
--ALTER DATABASE SampleDB1 SET SUSPEND_FOR_SNAPSHOT_BACKUP=ON;
--GO
--ALTER DATABASE SampleDB2 SET SUSPEND_FOR_SNAPSHOT_BACKUP=ON;
--GO
ALTER SERVER CONFIGURATION
SET SUSPEND_FOR_SNAPSHOT_BACKUP = ON (GROUP=(SampleDB1,SampleDB2));
GO

/* EXECUTE IN NEW QUERY WINDOW
INSERT INTO SampleDB1.dbo.T (col3,col4) VALUES (1,'a');
INSERT INTO SampleDB2.dbo.T (col3,col4) VALUES (1,'a')
*/

-- TAKE SNAPSHOT
EXEC xp_cmdshell 'C:\SNAPSHOTS\getsnapshotgroup.cmd', no_output;
GO

BACKUP GROUP SampleDB1,SampleDB2 
TO DISK=N'D:\MSSQL16.RC0\MSSQL\Backup\SampleDB_Snapshoot.bkm'
WITH METADATA_ONLY, FORMAT;
GO

SELECT COUNT(*) FROM SampleDB1.dbo.T;
SELECT COUNT(*) FROM SampleDB2.dbo.T;
GO

--------------------------------------------------------------------------------------------------
-- DROP DATABASES
--------------------------------------------------------------------------------------------------

USE master;
ALTER DATABASE SampleDB1 SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO
DROP DATABASE IF EXISTS SampleDB1;
GO
ALTER DATABASE SampleDB2 SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO
DROP DATABASE IF EXISTS SampleDB2;
GO

--------------------------------------------------------------------------------------------------
-- GROUP SNAPSHOT RESTORE
--------------------------------------------------------------------------------------------------
RESTORE HEADERONLY	 
FROM DISK=N'D:\MSSQL16.RC0\MSSQL\Backup\SampleDB_Snapshoot.bkm';

RESTORE FILELISTONLY 
FROM DISK=N'D:\MSSQL16.RC0\MSSQL\Backup\SampleDB_Snapshoot.bkm'
WITH METADATA_ONLY;
GO


-- MOUNT SNAPSHOT
EXEC xp_cmdshell 'C:\SNAPSHOTS\restoresnapshotgroup.cmd', no_output;
GO

SELECT COUNT(*) FROM SampleDB1.dbo.T;
SELECT COUNT(*) FROM SampleDB2.dbo.T;
GO

USE master;
RESTORE DATABASE SampleDB1 
FROM DISK = N'D:\MSSQL16.RC0\MSSQL\Backup\SampleDB_Snapshoot.bkm' 
WITH FILE = 1, METADATA_ONLY, REPLACE, DBNAME='SampleDB1';
RESTORE DATABASE SampleDB2 
FROM DISK = N'D:\MSSQL16.RC0\MSSQL\Backup\SampleDB_Snapshoot.bkm' 
WITH FILE = 1, METADATA_ONLY, REPLACE, DBNAME='SampleDB2';
GO

SELECT COUNT(*) FROM SampleDB1.dbo.T;
SELECT COUNT(*) FROM SampleDB2.dbo.T;
GO

--------------------------------------------------------------------------------------------------
-- SNAPSHOT & LOG BACKUP 
--------------------------------------------------------------------------------------------------

SELECT COUNT(*) FROM SampleDB1.dbo.T;
GO

USE master;
GO
ALTER DATABASE SampleDB1 SET SUSPEND_FOR_SNAPSHOT_BACKUP=ON;
GO

/* EXECUTE IN NEW QUERY WINDOW
INSERT INTO SampleDB1.dbo.T (col3,col4) VALUES (1,'a')
GO
*/

-- TAKE SNAPSHOT
EXEC xp_cmdshell 'C:\SNAPSHOTS\getsnapshot.cmd', no_output;
GO

BACKUP DATABASE SampleDB1 TO DISK=N'D:\MSSQL16.RC0\MSSQL\Backup\SampleDB1_Snapshoot.bkm'
WITH METADATA_ONLY, FORMAT;
GO

SELECT COUNT(*) FROM SampleDB1.dbo.T;
GO

BACKUP LOG SampleDB1 TO DISK=N'D:\MSSQL16.RC0\MSSQL\Backup\SampleDB1_log.trn'
WITH FORMAT;
GO

-- IF SNAPSHOT FAILED EXECUTE TO THAW DATABASE
ALTER DATABASE SampleDB1 SET SUSPEND_FOR_SNAPSHOT_BACKUP=OFF;
GO

--------------------------------------------------------------------------------------------------
-- DROP DATABASE
--------------------------------------------------------------------------------------------------

USE master;
ALTER DATABASE SampleDB1 SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO
DROP DATABASE IF EXISTS SampleDB1;
GO

--------------------------------------------------------------------------------------------------
-- SNAPSHOT RESTORE
--------------------------------------------------------------------------------------------------
RESTORE HEADERONLY	 FROM DISK=N'D:\MSSQL16.RC0\MSSQL\Backup\SampleDB1_Snapshoot.bkm';
RESTORE HEADERONLY	 FROM DISK=N'D:\MSSQL16.RC0\MSSQL\Backup\SampleDB1_log.trn';
RESTORE FILELISTONLY FROM DISK=N'D:\MSSQL16.RC0\MSSQL\Backup\SampleDB1_Snapshoot.bkm';
RESTORE FILELISTONLY FROM DISK=N'D:\MSSQL16.RC0\MSSQL\Backup\SampleDB1_log.trn';
GO

-- MOUNT SNAPSHOT
EXEC xp_cmdshell 'C:\SNAPSHOTS\restoresnapshot.cmd', no_output;
GO

SELECT COUNT(*) FROM SampleDB1.dbo.T;
GO

USE master;
RESTORE DATABASE SampleDB1 
FROM DISK = N'D:\MSSQL16.RC0\MSSQL\Backup\SampleDB1_Snapshoot.bkm' 
WITH FILE = 1, METADATA_ONLY, REPLACE, DBNAME='SampleDB1', NORECOVERY;
GO

RESTORE LOG SampleDB1 FROM DISK=N'D:\MSSQL16.RC0\MSSQL\Backup\SampleDB1_log.trn'
WITH RECOVERY;
GO

SELECT COUNT(*) FROM SampleDB1.dbo.T;
GO

--------------------------------------------------------------------------------------------------
-- SNAPSHOT MONITOR
--------------------------------------------------------------------------------------------------

USE master;
GO
ALTER SERVER CONFIGURATION
SET SUSPEND_FOR_SNAPSHOT_BACKUP = ON (GROUP=(SampleDB1,SampleDB2));
GO

SELECT SERVERPROPERTY('SuspendedDatabaseCount');
SELECT DATABASEPROPERTYEX('SampleDB1', 'IsDatabaseSuspendedForSnapshotBackup');
SELECT DATABASEPROPERTYEX('SampleDB2', 'IsDatabaseSuspendedForSnapshotBackup');
GO

SELECT * 
FROM sys.dm_server_suspend_status 
GO

ALTER SERVER CONFIGURATION
SET SUSPEND_FOR_SNAPSHOT_BACKUP = OFF (GROUP=(SampleDB1,SampleDB2));
GO
