/**********************************************************************************************************************

	Resumable Table Constraints

	Resumable add table constraints apply only to PRIMARY KEY and UNIQUE KEY constraints

**********************************************************************************************************************/

drop database if exists SQL2022;
go

create database SQL2022;
go


use SQl2022;
go

create table dbo.T (col1 int not null, col2 int, col3 int, col4 char(1000));
go


insert into dbo.T (col1,col2,col3,col4)
select value, value % 100, value % 1000 , REPLICATE('a',1000)
from generate_series(1,5000000);
go


use SQl2022;
go

select constraint_name, table_name, constraint_type 
from information_schema.table_constraints where constraint_type='primary key';
go

select count(*) from dbo.T;
go


--alter table dbo.T drop constraint PK_T;
--go


-- Full process ~ 4:30
alter table dbo.T
add constraint PK_T primary key clustered (col1) ;
go
-- Resumable process
alter table dbo.T
add constraint PK_T primary key clustered (col1) 
with (online = on, maxdop = 2, resumable = on, max_duration = 1);
go

kill ??
alter index PK_T on dbo.T abort;
alter index PK_T on dbo.T pause;
alter index PK_T on dbo.T resume;

-- monitor query
use SQL2022;
SELECT * --sql_text, state_desc, percent_complete
FROM sys.index_resumable_operations;

SELECT constraint_name, table_name, constraint_type 
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_TYPE='PRIMARY KEY';

