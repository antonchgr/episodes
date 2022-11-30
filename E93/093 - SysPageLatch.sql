/*********************************************************************************************************************

	SYSTEM PAGE LATCH CONCURRENCY ENHANCEMENTS
	SQL SERVER 2022
	WHAT'S NEW IN PERFORMANCE

*********************************************************************************************************************/

-- run	demosetup.cmd
-- before sql 2017<
-- open TempDBLatchDemo.PerfmonCfg
-- run	tempsql22stress 25
-- exec page info script
USE tempdb;
GO
SELECT object_name(page_info.object_id), page_info.* 
FROM sys.dm_exec_requests AS d 
  CROSS APPLY sys.fn_PageResCracker(d.page_resource) AS r
  CROSS APPLY sys.dm_db_page_info(r.db_id, r.file_id, r.page_id,'DETAILED')
    AS page_info;
GO

-- before sql 2022<
-- run	optimizedtempdbbefore2022.cmd
-- open TempDBLatchDemo.PerfmonCfg
-- run	tempsql22stress 25
-- exec page info script
USE tempdb;
GO
SELECT object_name(page_info.object_id), page_info.* 
FROM sys.dm_exec_requests AS d 
  CROSS APPLY sys.fn_PageResCracker(d.page_resource) AS r
  CROSS APPLY sys.dm_db_page_info(r.db_id, r.file_id, r.page_id,'DETAILED')
    AS page_info;
GO


-- in sql 2022
-- run	restartsql.cmd
-- open TempDBLatchDemo.PerfmonCfg
-- run	tempsql22stress 25
-- exec page info script
USE tempdb;
GO
SELECT object_name(page_info.object_id), page_info.* 
FROM sys.dm_exec_requests AS d 
  CROSS APPLY sys.fn_PageResCracker(d.page_resource) AS r
  CROSS APPLY sys.dm_db_page_info(r.db_id, r.file_id, r.page_id,'DETAILED')
    AS page_info;
GO


-- restore tempdb files
USE master;
GO
ALTER DATABASE tempdb MODIFY FILE (NAME=templog, SIZE = 8192Kb, FILEGROWTH = 65536kb);
GO
ALTER DATABASE tempdb ADD FILE (NAME=temp2, FILENAME = 'D:\MSSQL16.RC1\MSSQL\DATA\tempdb_mssql_2.ndf', SIZE = 8192Kb, FILEGROWTH = 65536Kb);
GO
ALTER DATABASE tempdb ADD FILE (NAME=temp3, FILENAME = 'D:\MSSQL16.RC1\MSSQL\DATA\tempdb_mssql_3.ndf', SIZE = 8192Kb, FILEGROWTH = 65536Kb);
GO
ALTER DATABASE tempdb ADD FILE (NAME=temp4, FILENAME = 'D:\MSSQL16.RC1\MSSQL\DATA\tempdb_mssql_4.ndf', SIZE = 8192Kb, FILEGROWTH = 65536Kb);
GO


USE master;
GO
SELECT name, physical_name, size*8192/1024 as size_kb, growth*8192/1024 as growth_kb
FROM sys.master_files
WHERE database_id = 2;
GO