/*********************************************************************************************************************

	ROW LEVEL SECURITY IN SQL SERVER 
			
	(C) 2023 ANTONIOS CHATZIPAVLIS

*********************************************************************************************************************/

use HellasGate2022;
go

if not exists (select * from sys.database_principals where name='webappuser' and type='S')
begin
	create user webappuser without login;
	alter role [db_datawriter] add member webappuser;
	alter role [db_datareader] add member webappuser;
end
go

execute as user = 'webappuser';
select top(10) * from sales.OrdersHeader;
revert;

-- webappuser

if exists (select * from sys.security_policies where name = 'rlsSalesOrdersHeader')
	drop security policy rlsSalesOrdersHeader;
go

if exists (select * from sys.objects where name ='rlsOrdersPredicate' and schema_id=schema_id('sec'))
	drop function sec.rlsOrdersPredicate;
go

create function sec.rlsOrdersPredicate (@empid as int) 
returns table 
with schemabinding
as
return
(
	select 1 as r
	from hr.Employees as e
	where 
		(
			e.empid=@empid 
			and
			e.email = user_name()
		)
		or
		(
			is_rolemember('db_NoRLS') = 1
			or
			is_srvrolemember('sysadmin') = 1
		)
		or
		(
			database_principal_id()=database_principal_id('webappuser')
		)
);
go

create security policy rlsSalesOrdersHeader
add filter predicate sec.rlsOrdersPredicate(empid) on sales.OrdersHeader,
add block predicate sec.rlsOrdersPredicate(empid) on sales.OrdersHeader after insert,
add block predicate sec.rlsOrdersPredicate(empid) on sales.OrdersHeader after update;
go
alter security policy rlsSalesOrdersHeader with (state=on);
go

execute as user = 'webappuser';
select top(10) * from sales.OrdersHeader;
revert;

execute as user = 'markos.metaxas@hellasgate.gr';
select top(10) * from sales.OrdersHeader;
revert;

execute as user = 'viktor.mpastias@hellasgate.gr';
select top(10) * from sales.OrdersHeader;
revert;

execute as user = 'menelaos.petsas@hellasgate.gr'; -- ceo
select top(10) * from sales.OrdersHeader;
revert;

-- webappuser with session context

if exists (select * from sys.security_policies where name = 'rlsSalesOrdersHeader')
	drop security policy rlsSalesOrdersHeader;
go

if exists (select * from sys.objects where name ='rlsOrdersPredicate' and schema_id=schema_id('sec'))
	drop function sec.rlsOrdersPredicate;
go

create function sec.rlsOrdersPredicate (@empid as int) 
returns table 
with schemabinding
as
return
(
	select 1 as r
	from hr.Employees as e
	where 
		(
			e.empid=@empid 
			and
			e.email = user_name()
		)
		or
		(
			IS_ROLEMEMBER('db_NoRLS') = 1
			or
			IS_SRVROLEMEMBER('sysadmin') = 1
		)
		or
		(
			DATABASE_PRINCIPAL_ID()=DATABASE_PRINCIPAL_ID('webappuser')
			and 
			cast ( session_context(N'empid') as int ) = @empid
		)
);
go

create security policy rlsSalesOrdersHeader
add filter predicate sec.rlsOrdersPredicate(empid) on sales.OrdersHeader,
add block predicate sec.rlsOrdersPredicate(empid) on sales.OrdersHeader after insert,
add block predicate sec.rlsOrdersPredicate(empid) on sales.OrdersHeader after update;
go
alter security policy rlsSalesOrdersHeader with (state=on);
go

execute as user = 'webappuser';
-- viktor.mpastias@hellasgate.gr empid=10
exec sp_set_session_context @key=N'empid',@value='10'
select top(10) * from sales.OrdersHeader;
revert;

execute as user = 'viktor.mpastias@hellasgate.gr';
select top(10) * from sales.OrdersHeader;
revert;

execute as user = 'menelaos.petsas@hellasgate.gr'; -- ceo
select top(10) * from sales.OrdersHeader;
revert;

