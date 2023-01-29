/*********************************************************************************************************************

	ROW LEVEL SECURITY IN SQL SERVER 
			
	(C) 2023 ANTONIOS CHATZIPAVLIS

*********************************************************************************************************************/

use HellasGate2022;
go

-- case insert 

delete from sales.OrdersHeader where orderid > 100000;
go

execute as user = 'markos.metaxas@hellasgate.gr';
insert into sales.OrdersHeader (custid,empid,orderdate,requireddate,shipperid)
values (1,1,'2023-01-17','2023-01-31',1)
revert;

execute as user = 'markos.metaxas@hellasgate.gr';
select top(10) * from sales.OrdersHeader where orderdate = '2023-01-17';
revert;

execute as user = 'menelaos.petsas@hellasgate.gr'; -- ceo
select top(10) * from sales.OrdersHeader where empid=1;
revert;
go

delete from sales.OrdersHeader where orderid > 100000;
go

-- case insert solution

alter security policy rlsSalesOrdersHeader with (state=off);
go
alter security policy rlsSalesOrdersHeader
alter filter predicate sec.rlsOrdersPredicate(empid) on sales.OrdersHeader,
add block predicate sec.rlsOrdersPredicate(empid) on sales.OrdersHeader after insert;
go
alter security policy rlsSalesOrdersHeader with (state=on);
go

delete from sales.OrdersHeader where orderid > 100000;
go

execute as user = 'markos.metaxas@hellasgate.gr';
insert into sales.OrdersHeader (custid,empid,orderdate,requireddate,shipperid)
values (1,1,'2023-01-17','2023-01-31',1)
revert;

execute as user = 'markos.metaxas@hellasgate.gr';
select top(10) * from sales.OrdersHeader where orderdate = '2023-01-17';
revert;

execute as user = 'menelaos.petsas@hellasgate.gr'; -- ceo
select top(10) * from sales.OrdersHeader where empid=1;
revert;
go

delete from sales.OrdersHeader where orderid > 100000;
go

-- case update 

delete from sales.OrdersHeader where orderid > 100000;
go

select * from hr.Employees where email = 'markos.metaxas@hellasgate.gr';
go

execute as user = 'markos.metaxas@hellasgate.gr';
insert into sales.OrdersHeader (custid,empid,orderdate,requireddate,shipperid)
values (1,142,'2023-01-17','2023-01-31',1)
revert;

execute as user = 'markos.metaxas@hellasgate.gr';
select top(10) * from sales.OrdersHeader where orderdate = '2023-01-17';
revert;

execute as user = 'markos.metaxas@hellasgate.gr';
update sales.OrdersHeader 
set empid = 1
where orderid = 100021;
revert;

execute as user = 'menelaos.petsas@hellasgate.gr'; -- ceo
select top(10) * from sales.OrdersHeader where empid=1;
revert;
go

delete from sales.OrdersHeader where orderid > 100000;
go

-- case update solution

alter security policy rlsSalesOrdersHeader with (state=off);
go
alter security policy rlsSalesOrdersHeader
alter filter predicate sec.rlsOrdersPredicate(empid) on sales.OrdersHeader,
alter block predicate sec.rlsOrdersPredicate(empid) on sales.OrdersHeader after insert,
add block predicate sec.rlsOrdersPredicate(empid) on sales.OrdersHeader after update;
go
alter security policy rlsSalesOrdersHeader with (state=on);
go

delete from sales.OrdersHeader where orderid > 100000;
go

select * from hr.Employees where email = 'markos.metaxas@hellasgate.gr';
go

execute as user = 'markos.metaxas@hellasgate.gr';
insert into sales.OrdersHeader (custid,empid,orderdate,requireddate,shipperid)
values (1,142,'2023-01-17','2023-01-31',1)
revert;

execute as user = 'markos.metaxas@hellasgate.gr';
select top(10) * from sales.OrdersHeader where orderdate = '2023-01-17';
revert;

execute as user = 'markos.metaxas@hellasgate.gr';
update sales.OrdersHeader 
set empid = 1
where orderid = 100022;
revert;

execute as user = 'menelaos.petsas@hellasgate.gr'; -- ceo
select top(10) * from sales.OrdersHeader where empid=1;
revert;
go

delete from sales.OrdersHeader where orderid > 100000;
go


select top(10) oh.orderid,oh.orderdate,oh.empid, oi.productid, oi.qty, oi.unitprice 
from sales.OrdersHeader as oh
inner join sales.OrderItems as oi
	on oi.orderid = oh.orderid;
go


-- joins with other tables

execute as user = 'markos.metaxas@hellasgate.gr';
select top(10) oh.orderid,oh.orderdate,oh.empid, oi.productid, oi.qty, oi.unitprice 
from sales.OrdersHeader as oh
inner join sales.OrderItems as oi
	on oi.orderid = oh.orderid;
revert;

execute as user = 'markos.metaxas@hellasgate.gr';
select top(10) *
from sales.OrderItems;
revert;