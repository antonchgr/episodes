use tsqlv6;
go

 
drop table if exists dbo.LibraryLog;
go

create table dbo.LibraryLog
(
	id int identity not null constraint pk_library primary key,
	book_id int,
	log_time datetime2,
	action_type char(10),
	member_id int null
);
go

insert into dbo.LibraryLog
values
(1,'2019-02-01 10:00','lend',1232),
(1,'2019-02-07 10:00','return',null),
(1,'2019-02-07 03:00','lend',1321),
(1,'2019-02-13 10:00','return',null),
(1,'2019-03-02 09:00','lend',81),
(1,'2019-03-08 08:00','extend',null),
(1,'2019-03-10 06:00','return',null),
(2,'2020-01-03 09:30','lend',123),
(2,'2020-01-08 09:30','return',null),
(2,'2020-01-15 01:00','lend',789),
(2,'2020-01-22 10:00','extend',null),
(2,'2020-01-28 03:00','extend',null),
(2,'2020-02-02 09:00','return',null),
(2,'2020-02-02 09:00','lend',452),
(2,'2020-02-08 03:00','extend',null)
go

select * from dbo.LibraryLog
go


select 
    book_id, 
    log_time, 
    action_type, 
    member_id ,
    first_value (member_id) over ( partition by book_id order by log_time rows unbounded preceding) as  fv,
	last_value (member_id) over ( partition by book_id order by log_time rows unbounded preceding) as  lv
from dbo.LibraryLog
order by book_id, log_time;


select 
    book_id, 
    log_time, 
    action_type, 
    member_id ,
    first_value (member_id) ignore nulls over ( partition by book_id order by log_time rows unbounded preceding) as  fv,
	last_value (member_id) ignore nulls over ( partition by book_id order by log_time rows unbounded preceding) as  lv
from dbo.LibraryLog
order by book_id, log_time;




select l_out.book_id, 
       l_out.log_time, 
       l_out.action_type, 
       member_find.member_id
from dbo.LibraryLog as l_out
cross apply
(    select top 1 member_id
    from dbo.LibraryLog as l_in 
    where l_out.book_id = l_in.book_id
        and l_in.log_time <= l_out.log_time
        and l_in.member_id is not null
    order by log_time desc
) as member_find
order by book_id, log_time;
