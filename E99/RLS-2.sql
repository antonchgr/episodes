/*********************************************************************************************************************

	ROW LEVEL SECURITY IN SQL SERVER 
			
	(C) 2023 ANTONIOS CHATZIPAVLIS

*********************************************************************************************************************/

use HellasGate2022;
go

if not exists (select * from sys.schemas where name ='sec')
	exec ('create schema sec;');
go


if exists (select * from sys.security_policies where name = 'rlsSalesOrdersHeader')
	drop security policy rlsSalesOrdersHeader;
go

if exists (select * from sys.objects where name ='rlsOrdersPredicate' and schema_id=schema_id('sec'))
	drop function sec.rlsOrdersPredicate;
go


-- case 
execute as user = 'markos.metaxas@hellasgate.gr';
select top(10) * from sales.OrdersHeader;
revert;

execute as user = 'viktor.mpastias@hellasgate.gr';
select top(10) * from sales.OrdersHeader;
revert;

execute as user = 'menelaos.petsas@hellasgate.gr'; -- ceo
select top(10) * from sales.OrdersHeader;
revert;
go

-- sysadmin
select top(10) * from sales.OrdersHeader;
go

-- solution-1

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
	from sales.OrdersHeader as oh
	inner join hr.Employees as e on oh.empid = e.empid
	where 
		oh.empid=@empid 
		and
		e.email = user_name() 
);
go

create security policy rlsSalesOrdersHeader
add filter predicate sec.rlsOrdersPredicate(empid)
on sales.OrdersHeader;
go
alter security policy rlsSalesOrdersHeader with (state=on);
go

execute as user = 'markos.metaxas@hellasgate.gr';
select top(10) * from sales.OrdersHeader;
revert;

execute as user = 'viktor.mpastias@hellasgate.gr';
select top(10) * from sales.OrdersHeader;
revert;

execute as user = 'menelaos.petsas@hellasgate.gr'; -- ceo
select top(10) * from sales.OrdersHeader;
revert;
go

-- sysadmin
select top(10) * from sales.OrdersHeader;
go

-- solution-2

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
		e.empid=@empid 
		and
		e.email = user_name() 
);
go

create security policy rlsSalesOrdersHeader
add filter predicate sec.rlsOrdersPredicate(empid)
on sales.OrdersHeader;
go
alter security policy rlsSalesOrdersHeader with (state=on);
go

execute as user = 'markos.metaxas@hellasgate.gr';
select top(10) * from sales.OrdersHeader;
revert;

execute as user = 'viktor.mpastias@hellasgate.gr';
select top(10) * from sales.OrdersHeader;
revert;

execute as user = 'menelaos.petsas@hellasgate.gr'; -- ceo
select top(10) * from sales.OrdersHeader;
revert;
go

-- sysadmin
select top(10) * from sales.OrdersHeader;
go

-- solution 1 - c level

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
			user_name() = 'menelaos.petsas@hellasgate.gr'
		)
);
go

create security policy rlsSalesOrdersHeader
add filter predicate sec.rlsOrdersPredicate(empid)
on sales.OrdersHeader;
go
alter security policy rlsSalesOrdersHeader with (state=on);
go

execute as user = 'markos.metaxas@hellasgate.gr';
select top(10) * from sales.OrdersHeader;
revert;

execute as user = 'viktor.mpastias@hellasgate.gr';
select * from sales.OrdersHeader;
revert;

execute as user = 'menelaos.petsas@hellasgate.gr'; -- ceo
select top(10) * from sales.OrdersHeader;
revert;
go

-- sysadmin
select top(10) * from sales.OrdersHeader;
go

-- solution 2 - c level

if exists (select * from sys.database_principals where type='R' and name ='db_NoRLS')
begin

	alter role db_NoRLS drop member [menelaos.petsas@hellasgate.gr];
	drop role db_NoRLS;
end
go

create role db_NoRLS;
go

alter role db_NoRLS add member [menelaos.petsas@hellasgate.gr];
go


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
);
go

create security policy rlsSalesOrdersHeader
add filter predicate sec.rlsOrdersPredicate(empid)
on sales.OrdersHeader;
go
alter security policy rlsSalesOrdersHeader with (state=on);
go

execute as user = 'markos.metaxas@hellasgate.gr';
select top(10) * from sales.OrdersHeader;
revert;

execute as user = 'viktor.mpastias@hellasgate.gr';
select top(10) * from sales.OrdersHeader;
revert;

execute as user = 'menelaos.petsas@hellasgate.gr'; -- ceo
select top(10) * from sales.OrdersHeader;
revert;

-- sysadmin
select  top(10) * from sales.OrdersHeader;
go

