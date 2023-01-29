/*********************************************************************************************************************

	ROW LEVEL SECURITY IN SQL SERVER 
	FUNDAMENTALS
	
	(C) 2023 ANTONIOS CHATZIPAVLIS

*********************************************************************************************************************/

use master;
go
drop database if exists RLSDemoDB;
go
create database RLSDemoDB;
go

use RLSDemoDB;
go

create table dbo.T 
( 
	id int identity
,	username nvarchar(20)
)
go

insert into dbo.T(username) 
values ('user1'),('user2');
go


select * from dbo.T;
select * from dbo.T where username=N'user1';
select * from dbo.T where username=N'user2';
go

create user user1 without login;
create user user2 without login;
create user user3 without login;
go

grant select on dbo.T to user1;
grant select on dbo.T to user2;
grant select on dbo.T to user3;
go

execute as user = 'user1';
select * from dbo.T;
revert;

execute as user = 'user2';
select * from dbo.T;
revert;

execute as user = 'user3';
select * from dbo.T;
revert;
go

create schema sec;
go

create function sec.rlspredicate (@username as nvarchar(20)) 
returns table 
with schemabinding
as
return 
(
	select 1 as r 
	where 
		@username = user_name()
		or
		user_name() = 'user3'
);
go


create security policy rlsonT
add filter predicate sec.rlspredicate(username)
on dbo.T;
go
alter security policy rlsonT with (state=on);
go

--grant select on sec.rlspredicate to user1;
--grant select on sec.rlspredicate to user2;
--grant select on sec.rlspredicate to user3;
--go

execute as user = 'user1';
select * from dbo.T;
revert;

execute as user = 'user2';
select * from dbo.T;
revert;

execute as user = 'user3';
select * from dbo.T;
revert;
go


alter security policy rlsonT with (state=off);
go

execute as user = 'user1';
select * from dbo.T;
revert;

execute as user = 'user2';
select * from dbo.T;
revert;

execute as user = 'user3';
select * from dbo.T;
revert;
go


