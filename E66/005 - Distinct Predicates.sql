/*********************************************************************************************************************************************************

	DISTINCT PREDICATES
	-------------------

	Compares the equality of two expressions and guarantees a true or false result, even if one 
	or both operands are NULL.

	IS [NOT] DISTINCT FROM is a predicate used in the search condition of 
	WHERE clauses and HAVING clauses, the join conditions of FROM clauses,
	and other constructs where a Boolean value is required.


	| A	   | B	  |	A=B	    | A IS NOT DISTINCT FROM B | A IS DISTINCT FROM B |
	|------|------|---------|--------------------------|----------------------|
	| 0	   | 0	  |	TRUE    | TRUE				       | FALSE                |
	| 0	   | 1	  |	FALSE   | FALSE					   | TRUE				  |
	| 0	   | NULL |	UNKNOWN | FALSE					   | TRUE				  |
	| NULL | NULL | UNKNOWN | TRUE					   | FALSE				  |


	A IS NOT DISTINCT FROM B =  (NOT (A <> B OR A IS NULL OR B IS NULL) OR (A IS NULL AND B IS NULL))
	A IS DISTINCT FROM B     =  ((A <> B OR A IS NULL OR B IS NULL) AND NOT (A IS NULL AND B IS NULL))








********************************************************************************************************************************************************/

use TSQLV6;
go


select 
	orderid,
	shippeddate
from 
	sales.Orders;
go

--********************************************************

create or alter proc dbo.GetOrdersShippingInfo @dt date
as
begin
	set nocount on;

	select 
		orderid,
		shippeddate
	from 
		sales.Orders
	where 
		shippeddate = @dt
	option (recompile);
end
go

exec dbo.GetOrdersShippingInfo @dt = '2020-10-14';
exec dbo.GetOrdersShippingInfo @dt = NULL;
go

--********************************************************

create or alter proc dbo.GetOrdersShippingInfo @dt date
as
begin
	set nocount on;

	select 
		orderid,
		shippeddate
	from 
		sales.Orders
	where 
		isnull(shippeddate,'99991231') = isnull(@dt,'99991231')
	option (recompile);
end
go

exec dbo.GetOrdersShippingInfo @dt = '2020-10-14';				
exec dbo.GetOrdersShippingInfo @dt = NULL;
go

--********************************************************

create or alter proc dbo.GetOrdersShippingInfo @dt date
as
begin
	set nocount on;

	select 
		orderid,
		shippeddate
	from 
		sales.Orders
	where 
		shippeddate = @dt 
		or 
		(shippeddate is null and @dt is null)
	option (recompile);
end
go

exec dbo.GetOrdersShippingInfo @dt = '2020-10-14';
exec dbo.GetOrdersShippingInfo @dt = NULL;
go

--********************************************************

create or alter proc dbo.GetOrdersShippingInfo @dt date
as
begin
	set nocount on;

	select 
		orderid,
		shippeddate
	from 
		sales.Orders
	where 
		shippeddate is not distinct from  @dt 
	option (recompile);
end
go

exec dbo.GetOrdersShippingInfo @dt = '2020-10-14';
exec dbo.GetOrdersShippingInfo @dt = NULL;
go
