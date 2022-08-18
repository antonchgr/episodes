/*****************************************************************************************
	Generates a series of numbers within a given interval. 
	The interval and the step between series values are defined by the user.

	GENERATE_SERIES
	(
		  START = @start | start_literal | numeric_expression
		, STOP  = @stop  | stop_literal  | numeric_expression
	   [, STEP  = @step  | step_literal  | numeric_expression ]
	)

******************************************************************************************/

WITH cte(n) AS 
(
  SELECT 1 UNION ALL 
  SELECT n + 1 FROM cte WHERE n <= 50
)
SELECT value = n FROM cte;
GO


SELECT value
FROM GENERATE_SERIES(START = 1, STOP = 50, STEP = 1);
GO


SELECT value
FROM GENERATE_SERIES(1, 50, 1);
GO


WITH cte(n) AS 
(
  SELECT 1 UNION ALL 
  SELECT n + 1 FROM cte WHERE n <= 50
)
SELECT value = ((n-1)*5)+1  FROM cte;
GO

SELECT value
FROM GENERATE_SERIES(START = 1, STOP = 50, STEP = 5);
GO

SELECT value
FROM GENERATE_SERIES(1, 50, 5);
GO



SELECT value
FROM GENERATE_SERIES(1,  50,  5)
order by value desc;
GO



-- DATE RANGES

use TSQLV6;
go

declare @begindate date = '2011-01-01', @enddate date = '2012-06-30'

select	dateadd(dd, n-1, @begindate) [date]
	,	day(dateadd(dd, n-1, @begindate)) [day] 
	,	month(dateadd(dd, n-1, @begindate)) [month]
	,	year(dateadd(dd, n-1, @begindate)) [year]
from dbo.nums
where n <= datediff(dd, @begindate, @enddate) + 1;


select	dateadd(dd, value-1, @begindate) [date]
	,	day(dateadd(dd, value-1, @begindate)) [day] 
	,	month(dateadd(dd, value-1, @begindate)) [month]
	,	year(dateadd(dd, value-1, @begindate)) [year]
from GENERATE_SERIES(1,  1000,  1)
where value <= datediff(dd, @begindate, @enddate) + 1;
go


-- split

declare @s varchar(255) 
select @s= 'SQL;school;gr;pass;sql staturdays' ;

select substring(@s+';', n, 
    charindex(';', @s+';', n) - n) 
from dbo.nums
where n <= len(@s) 
and substring(';' + @s, 
            n, 1) = ';' 
order by n

select substring(@s+';', value, 
    charindex(';', @s+';', value) - value) 
from GENERATE_SERIES(1,  1000,  1)
where value <= len(@s) 
and substring(';' + @s, 
            value, 1) = ';' 
order by value


-- FIND MISSING DATES

declare @datestart datetime = null;
declare @datesend datetime = null;
select @datestart = min(orderdate) from sales.Orders;
select @datesend = max(orderdate) from sales.Orders;

select convert(date, dateadd(dd, t.n, @datestart)) as missing_dates
from sales.orders as o
right join dbo.nums as t on dateadd(dd, t.n, @datestart) = o.orderdate
where o.orderdate is null and dateadd(dd, t.n, @datestart) <= @datesend

select convert(date, dateadd(dd, t.value, @datestart)) as missing_dates
from sales.orders as o
right join GENERATE_SERIES(1,  10000,  1) as t on dateadd(dd, t.value, @datestart) = o.orderdate
where o.orderdate is null and dateadd(dd, t.value, @datestart) <= @datesend


create function dbo.getWorkingDays1 
( 
    @startdate datetime, 
    @enddate datetime 
) 
returns int 
as 
begin 
return 
(select count(*) 
    from dbo.Nums 
    where dateadd(day,n-1,@startdate)< @enddate 
    and datename(dw,dateadd(day,n-1,@startdate)) 
    not in ('saturday','sunday')) 
end 
go


create function dbo.getWorkingDays2 
( 
    @startdate datetime, 
    @enddate datetime 
) 
returns int 
as 
begin 
return 
(select count(*) 
    from GENERATE_SERIES(1,  10000,  1)
    where dateadd(day,value-1,@startdate)< @enddate 
    and datename(dw,dateadd(day,value-1,@startdate)) 
    not in ('saturday','sunday')) 
end 
go


select orderid,orderdate,requireddate,dbo.getWorkingDays1(orderdate,requireddate) as working_days
from Sales.Orders
where orderdate<cast('2022-12-31' as datetime)



select orderid,orderdate,requireddate,dbo.getWorkingDays2(orderdate,requireddate) as working_days
from Sales.Orders
where orderdate<cast('2022-12-31' as datetime)



