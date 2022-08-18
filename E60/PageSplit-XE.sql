use master;
go


if exists (select 1 
            from sys.server_event_sessions 
            where name = 'Monitor_Page_Splits')
    drop event session [Monitor_Page_Splits] on server;
go


create event session [Monitor_Page_Splits]
on    server
add event sqlserver.transaction_log(
    where operation = 11  -- lop_delete_split 
      and database_id = 10 -- change this based on top splitting database!
)
add target package0.histogram(
    set filtering_event_name = 'sqlserver.transaction_log',
        source_type = 0, -- event column
        source = 'alloc_unit_id');
go

-- start the event session again
alter event session [Monitor_Page_Splits]
on server
state=start;
go

-- start the event session again
alter event session [Monitor_Page_Splits]
on server
state=stop;
go


use SQLschoolDB;
go

select
    o.name as table_name,
    i.name as index_name,
    tab.split_count,
    i.fill_factor
from (    select 
            n.value('(value)[1]', 'bigint') as alloc_unit_id,
            n.value('(@count)[1]', 'bigint') as split_count
        from
        (select cast(target_data as xml) target_data
         from sys.dm_xe_sessions as s 
         join sys.dm_xe_session_targets t
             on s.address = t.event_session_address
         where s.name = 'Monitor_Page_Splits'
          and t.target_name = 'histogram' ) as tab
        cross apply target_data.nodes('HistogramTarget/Slot') as q(n)
) as tab
join sys.allocation_units as au
    on tab.alloc_unit_id = au.allocation_unit_id
join sys.partitions as p
    on au.container_id = p.partition_id
join sys.indexes as i
    on p.object_id = i.object_id
        and p.index_id = i.index_id
join sys.objects as o
    on p.object_id = o.object_id
where o.is_ms_shipped = 0;