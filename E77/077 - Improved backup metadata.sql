
	USE master;
	GO

	EXEC msdb.dbo.sp_delete_database_backuphistory @database_name = N'SampleDB';
	GO
	EXEC sys.xp_delete_files 'D:\MSSQL16.RC0\MSSQL\Backup\SampleDB*.*';
	GO

	DROP DATABASE IF EXISTS SampleDB;
	GO

	CREATE DATABASE SampleDB;
	GO

	USE SampleDB;
	CREATE TABLE T 
	(
		col1 INT IDENTITY NOT NULL CONSTRAINT PK_T PRIMARY KEY , 
		col2 DATETIME2(7) DEFAULT (SYSDATETIME())
	)
	GO



	USE msdb;
	GO
	
	CREATE OR ALTER VIEW SampleDBBackupsView
	AS
	SELECT 
		bf.physical_device_name
	,	bs.database_name
	,	bs.server_name
	,	bs.position
	,	CASE
			WHEN bs.type = 'D' AND bs.is_copy_only = 0 THEN 'Full Database'
			WHEN bs.type = 'D' AND bs.is_copy_only = 1 THEN 'Full Copy-Only Database'
			WHEN bs.type = 'I' THEN 'Differential database backup'
			WHEN bs.type = 'L' THEN 'Transaction Log'
			WHEN bs.type = 'F' THEN 'File or filegroup'
			WHEN bs.type = 'G' THEN 'Differential file'
			WHEN bs.type = 'P' THEN 'Partial'
			WHEN bs.type = 'Q' THEN 'Differential partial'
			END + ' Backup' AS backup_type
	,	bs.last_valid_restore_time
	FROM 
		dbo.backupset AS bs
	INNER JOIN 
		dbo.backupmediafamily AS bf ON bf.media_set_id=bs.media_set_id
	WHERE 
		bs.database_name = N'SampleDB';
	GO
	
----------------------------------------------------------------------------------------------
-- run on new query
----------------------------------------------------------------------------------------------
	SET NOCOUNT ON;
	USE SampleDB;
	WHILE (1=1)
	BEGIN
		INSERT INTO T DEFAULT VALUES;
	END
	SET NOCOUNT OFF;
	GO
----------------------------------------------------------------------------------------------
	
	USE master;
	GO

	BACKUP DATABASE SampleDB TO DISK=N'D:\MSSQL16.RC0\MSSQL\Backup\SampleDB_FB1.bak'
	WITH EXPIREDATE='2022-10-01';

	BACKUP DATABASE SampleDB TO DISK=N'D:\MSSQL16.RC0\MSSQL\Backup\SampleDB_FB2.bak'
	WITH RETAINDAYS=30;
	GO

	BACKUP DATABASE SampleDB TO DISK=N'D:\MSSQL16.RC0\MSSQL\Backup\SampleDB_DIFF.bak'
	WITH DIFFERENTIAL;
	GO

	SELECT * FROM msdb.dbo.SampleDBBackupsView;
	GO

	
	
	BACKUP LOG SampleDB TO DISK=N'D:\MSSQL16.RC0\MSSQL\Backup\SampleDB_Log.trn'
	GO

	
	SELECT 
		* 
	,	(SELECT COUNT(*) FROM SampleDB.dbo.T WHERE col2<=V.last_valid_restore_time) AS countrows
	FROM 
		msdb.dbo.SampleDBBackupsView AS V
	WHERE v.backup_type ='Transaction Log Backup';
	GO


	
	SELECT COUNT(*) FROM dbo.T WHERE col2<='2022-09-13 15:48:28.000'
	SELECT COUNT(*) FROM dbo.T WHERE col2<='2022-09-13 15:49:01.000'
	SELECT COUNT(*) FROM dbo.T WHERE col2<='2022-09-13 15:49:26.000'