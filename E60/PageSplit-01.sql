use SQLschoolDB;
go
select db_id()


if exists ( select * from sys.tables where name='PageSplitT01' )
	drop table dbo.PageSplitT01;
go

create table dbo.PageSplitT01
(
	ID uniqueidentifier not null default newid()
,	colint int not null default(DATEPART(MILLISECOND, cast(sysdatetime() as time)))
,	coldate datetime2 not null default (sysdatetime())
);
go

alter table dbo.PageSplitT01
add constraint PK_PageSplitT01_ID primary key clustered (ID);
go

create index idx_PageSplitT01_colint on dbo.PageSplitT01(colint);
go

create index idx_PageSplitT01_coldate on dbo.PageSplitT01(coldate);
go



if exists ( select * from sys.tables where name='PageSplitT02' )
	drop table dbo.PageSplitT02;
go

create table dbo.PageSplitT02
(
	ID int not null identity(1,1) 
,	colint int not null default(DATEPART(MILLISECOND, cast(sysdatetime() as time)))
,	coldate datetime2 not null default (sysdatetime())
);
go



alter table dbo.PageSplitT02
add constraint PK_PageSplitT02_ID primary key clustered (ID);
go

create index idx_PageSplitT02_colint on dbo.PageSplitT02(colint);
go

create index idx_PageSplitT02_coldate on dbo.PageSplitT02(coldate);
go

set nocount on;
declare @i int = 1;
while (@i<=1000)
begin
	insert into dbo.PageSplitT01 default values;
	insert into dbo.PageSplitT02 default values;
	waitfor delay '00:00:00:005';
	set @i+=1;
end
set nocount off;
go

select * from dbo.PageSplitT01;
select * from dbo.PageSplitT02;
go

select
    AllocUnitName as N'Index',
    (case Context
        when N'LCX_INDEX_LEAF' then N'Nonclustered'
        when N'LCX_CLUSTERED' then N'Clustered'
        else N'Non-Leaf'
    end) as SplitType,
    count(1) as SplitCount
from
    fn_dblog (NULL, NULL)
where
    Operation = N'LOP_DELETE_SPLIT'
	and 
	AllocUnitName like '%PageSplit%'
group by AllocUnitName, Context;
go


select OBJECT_NAME(s.object_id), i.name, leaf_allocation_count, nonleaf_allocation_count, i.index_id
from sys.dm_db_index_operational_stats(db_id(),null,null,null) as s
inner join sys.indexes as i on s.object_id = i.object_id and i.index_id = s.index_id
where OBJECT_NAME(s.object_id) like '%PageSplit%';
go


exec sqlschoolgr.sp_indexdetails @table_name='PageSplitT01', @table_idxid=1;
go
exec sqlschoolgr.sp_indexdetails @table_name='PageSplitT01', @table_idxid=2;
go
exec sqlschoolgr.sp_indexdetails @table_name='PageSplitT01', @table_idxid=3;
go


exec sqlschoolgr.sp_indexdetails @table_name='PageSplitT02', @table_idxid=1;
go
exec sqlschoolgr.sp_indexdetails @table_name='PageSplitT02', @table_idxid=2;
go
exec sqlschoolgr.sp_indexdetails @table_name='PageSplitT02', @table_idxid=3;
go

select * from dbo.PageSplitT01;
select * from dbo.PageSplitT02;
go


update dbo.PageSplitT02
set coldate = DATEADD(day,id%2,coldate);
go


alter index PK_PageSplitT01_ID on dbo.PageSplitT01
rebuild
with (fillfactor=50);
go

alter index idx_PageSplitT01_colint on dbo.PageSplitT01
rebuild
with (fillfactor=70);
go

alter index idx_PageSplitT02_coldate on dbo.PageSplitT02
rebuild
with (fillfactor=80);
go

exec sqlschoolgr.sp_indexdetails @table_name='PageSplitT01', @table_idxid=1;
go
exec sqlschoolgr.sp_indexdetails @table_name='PageSplitT01', @table_idxid=2;
go
go
exec sqlschoolgr.sp_indexdetails @table_name='PageSplitT02', @table_idxid=3;
go


set nocount on;
declare @i int = 1;
while (@i<=1000)
begin
	insert into dbo.PageSplitT01 default values;
	insert into dbo.PageSplitT02 default values;
	waitfor delay '00:00:00:005';
	set @i+=1;
end
set nocount off;
go

update dbo.PageSplitT02
set coldate = DATEADD(day,id%2,coldate);
go