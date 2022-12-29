USE master;
GO

IF EXISTS ( SELECT * FROM sys.dm_xe_sessions WHERE name = 'Statistics_Monitor' )
BEGIN
	ALTER EVENT SESSION Statistics_Monitor ON SERVER STATE = STOP;
	DROP EVENT SESSION Statistics_Monitor ON SERVER;
END
GO

CREATE EVENT SESSION Statistics_Monitor
ON SERVER
    ADD EVENT sqlserver.auto_stats
    (ACTION
     (
         sqlserver.sql_text
     )
     WHERE (sqlserver.database_name = N'HellasGate2022')
    ),
    ADD EVENT sqlserver.sql_batch_completed
    (WHERE (sqlserver.database_name = N'HellasGate2022'))
	ADD TARGET package0.event_file
	(
		SET filename=N'statistics_monitor.xel',max_file_size=(100),max_rollover_files=(10)
	),
	ADD TARGET package0.ring_buffer
	(
		SET max_events_limit=(5000),max_memory=(4096)
	)
GO
ALTER EVENT SESSION Statistics_Monitor ON SERVER STATE = START;
GO


USE tempdb;
GO

DROP VIEW IF EXISTS dbo.StatisticsMonitorXE;
GO

CREATE OR ALTER VIEW dbo.StatisticsMonitorXE
AS
	with xesession
	as
	(
		select cast ( event_data as xml) as xedata
		from 
			 sys.fn_xe_file_target_read_file ( 'statistics_monitor*.xel',null,null,null )
		
	)
	select 
		convert(datetime2,switchoffset(xedata.value(N'(event/@timestamp)[1]', N'datetime2'),datename(tzoffset, sysdatetimeoffset())))  as [timestamp]
	,	xedata.value(N'(event/@name)[1]', N'nvarchar(100)') as [name]
	,	xedata.value(N'(event/data[@name="batch_text"]/value)[1]', N'nvarchar(max)') as batch_text
	,	xedata.value(N'(event/data[@name="statistics_list"]/value)[1]', N'nvarchar(max)') as statistics_list
	,	xedata.value(N'(event/data[@name="duration"]/value)[1]',N'bigint') AS duration
	from xesession

GO




