/**********************************************************************************************************************

	Accelerated Database Recovery (ADR) improvements

**********************************************************************************************************************/
use master;
go


create database SQL2022ADR;
go

use SQl2022ADR;
go

create table dbo.T 
(
	col1 int identity not null constraint PK_T primary key clustered, 
	col2 int, 
	col3 int, 
	col4 char(2000));
go

insert into dbo.T (col2,col3,col4)
select  value , value % 1000 , REPLICATE('a',2000)
from generate_series(1,10000000);
go


-- ADR Enable

alter database SQl2022ADR set accelerated_database_recovery = on;
go

use master;
alter database SQl2022ADR add filegroup adrfg;
go

alter database SQl2022ADR 
add file 
( 
	name = 'adrdata'
,	filename = 'd:\mssql16.rc0\mssql\data\versionstore.ndf'
)
to filegroup adrfg
go

use master;
alter database SQl2022ADR set accelerated_database_recovery = on
(
	persistent_version_store_filegroup = adrfg
);
go


insert into dbo.T (col1,col2,col3,col4)
select value, value % 100, value % 1000 , REPLICATE('a',2000)
from generate_series(1,10000000);
go

--	ADR improvements in SQL Server 2022 (16.x)

/*
	Multi-threaded version cleanup
*/

dbcc traceon(3515, -1)
go 
dbcc tracestatus
go

exec sp_configure 'show advanced options', 1;
reconfigure with override; 
go

exec sp_configure 'ADR Cleaner Thread Count', '4'
reconfigure with override; 
go

/*
	New extended event
*/

select DB_ID('SQL2022ADR');

create event session [ADR_Monitor] on server 
add event sqlserver.tx_commit_abort_stats,
add event sqlserver.tx_mtvc2_sweep_stats, -- sql server 2022
add event sqlserver.tx_version_cleanup_stats,
add event sqlserver.tx_version_cleanup_sweep_stats, 
add event sqlserver.tx_version_stats(
    action(sqlserver.database_name)
    where ([database_id]=(13)))
add target package0.event_file(set filename=N'ADR_Monitor')
go

alter event session [ADR_Monitor] on server state=start
go


/* cleanup */
use master;
go
drop database if exists SQL2022ADR;
go
alter event session [ADR_Monitor] on server state=start;
go
drop event session [adr_monitor] on server  ;
go
dbcc traceoff(3515, -1)
go 
