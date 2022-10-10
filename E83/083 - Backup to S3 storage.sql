/*********************************************************************************************************************

	SQL SERVER BACKUP TO URL FOR S3-COMPATIBLE OBJECT STORAGE
	SQL SERVER 2022 - WHAT'S NEW IN MANAGEMENT

*********************************************************************************************************************/

-- CREDENTIAL
USE MASTER
GO
IF EXISTS (SELECT * FROM sys.credentials WHERE name = 's3://192.168.1.16:9000/backups')
	DROP CREDENTIAL [s3://192.168.1.16:9000/backups];
GO
CREATE CREDENTIAL [s3://192.168.1.16:9000/backups]
WITH IDENTITY = 'S3 Access Key',
SECRET = '...';
GO
SELECT * FROM sys.credentials;
GO

-- CLEAR BACKUP HISTORY
USE master;
EXEC msdb.dbo.sp_delete_database_backuphistory @database_name = N'TSQLV6';
GO

-- FULL BACKUP
USE MASTER;
BACKUP DATABASE TSQLV6
TO URL = 's3://192.168.1.16:9000/backups/tsqlv6fb.bak'
WITH CHECKSUM, INIT, FORMAT;
GO

-- DIFFERENTIAL BACKUP
USE MASTER;
BACKUP DATABASE TSQLV6
TO URL = 's3://192.168.1.16:9000/backups/tsqlv6diff.bak'
WITH CHECKSUM, INIT, FORMAT,DIFFERENTIAL;
GO

-- TRANSACTION LOG BACKUP
USE MASTER;
BACKUP LOG TSQLV6
TO URL = 's3://192.168.1.16:9000/backups/tsqlv6log.bak'
WITH CHECKSUM, INIT, FORMAT;
GO


-- SQLschool.gr - Articles 
-- Restore survivor - Restore chain explanation and restore script generation
EXEC msdb.dbo.sp_emergency_db_restore @dbname='TSQLV6'
GO


-- READ METADATA
USE MASTER;
RESTORE VERIFYONLY FROM URL = 's3://192.168.1.16:9000/backups/tsqlv6fb.bak';
RESTORE HEADERONLY FROM URL = 's3://192.168.1.16:9000/backups/tsqlv6fb.bak';
RESTORE FILELISTONLY FROM URL = 's3://192.168.1.16:9000/backups/tsqlv6fb.bak';
GO


-- RESTORE
USE MASTER;
DROP DATABASE IF EXISTS TSQLV6;
GO

-- FULL BACKUP
RESTORE DATABASE TSQLV6 
FROM URL = 's3://192.168.1.16:9000/backups/tsqlv6fb.bak'
WITH NORECOVERY,
MOVE 'TSQLV6' TO 'D:\MSSQL16.RC1\MSSQL\DATA\TSQLV6.mdf',
MOVE 'TSQLV6_log' TO 'D:\MSSQL16.RC1\MSSQL\DATA\TSQLV6_log.mdf';
GO

-- DIFF BACKUP
RESTORE DATABASE TSQLV6 
FROM URL = 's3://192.168.1.16:9000/backups/tsqlv6diff.bak'
WITH NORECOVERY,
MOVE 'TSQLV6' TO 'D:\MSSQL16.RC1\MSSQL\DATA\TSQLV6.mdf',
MOVE 'TSQLV6_log' TO 'D:\MSSQL16.RC1\MSSQL\DATA\TSQLV6_log.mdf';
GO

-- LOG BACKUP
RESTORE LOG TSQLV6 
FROM URL = 's3://192.168.1.16:9000/backups/tsqlv6log.bak'
WITH RECOVERY,
MOVE 'TSQLV6' TO 'D:\MSSQL16.RC1\MSSQL\DATA\TSQLV6.mdf',
MOVE 'TSQLV6_log' TO 'D:\MSSQL16.RC1\MSSQL\DATA\TSQLV6_log.mdf';
GO

ALTER DATABASE TSQLV6 SET QUERY_STORE CLEAR ALL;
GO


-- READ BACKUP / RESTORE METADATA

USE msdb;
SELECT * FROM dbo.backupset
SELECT * FROM dbo.backupmediafamily
SELECT * FROM dbo.restorehistory