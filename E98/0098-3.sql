create view MonitorStatisticsPowerBI as 
with 
xesession as
	(
		select cast ( event_data as xml) as xedata
		from 
			 sys.fn_xe_file_target_read_file ( 'statistics_monitor*.xel',null,null,null )
		where object_name = 'auto_stats'
	),
auto_stats as 
	(
		select 
			convert(datetime2,switchoffset(xedata.value(N'(event/@timestamp)[1]', N'datetime2'),datename(tzoffset, sysdatetimeoffset())))  as [timestamp]
		,	xedata.value(N'(event/@name)[1]', N'nvarchar(100)') as [name]
		,	xedata.value(N'(event/data[@name="object_id"]/value)[1]', N'bigint') as object_id
		,	xedata.value(N'(event/data[@name="index_id"]/value)[1]', N'int') as index_id
		,	xedata.value(N'(event/data[@name="job_type"]/value)[1]', N'int') as job_type_value
		,	xedata.value(N'(event/data[@name="job_type"]/text)[1]', N'nvarchar(50)') as job_type_desc
		,	xedata.value(N'(event/data[@name="duration"]/value)[1]',N'bigint') AS duration
		,	xedata.value(N'(event/data[@name="statistics_list"]/value)[1]', N'nvarchar(max)') as statistics_list
		,	xedata.value(N'(event/data[@name="status"]/value)[1]', N'nvarchar(max)') as status_value
		,	xedata.value(N'(event/data[@name="status"]/text)[1]', N'nvarchar(max)') as status_desc
		,	xedata.value(N'(event/action[@name="sql_text"]/value)[1]', N'nvarchar(max)') as sql_text
		from xesession
	)
select CONCAT_WS('.', SCHEMA_NAME(o.schema_id),o.name) as object_name, i.name as index_name, i.type_desc as index_type_desc
, s.timestamp, s.duration,s.status_value,s.status_desc,s.sql_text
from auto_stats as s
inner join sys.objects as o on o.object_id = s.object_id
inner join sys.indexes as i on i.object_id = s.object_id and i.index_id = s.index_id
where s.status_value=1