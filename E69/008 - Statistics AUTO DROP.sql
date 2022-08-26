use TSQLV6;
go

drop table if exists sales.T;
go

create table sales.T ( col1 int );
go

insert into sales.T
select value
from generate_series(1,100);
go

create statistics t_col1 on sales.T (col1); -- with auto_drop = on;
go

dbcc show_statistics ('sales.T' , t_col1);
go

alter table sales.T alter column col1 bigint;
go

update statistics sales.T(t_col1) with auto_drop = on;
go

alter table sales.T alter column col1 bigint;
go

dbcc show_statistics ('sales.T' , t_col1);
go

