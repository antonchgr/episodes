use TSQLV6;
go



/******************************************************************************

	GREATEST() and LEAST() functions 

	The following types are not supported for comparison in GREATEST/LEAST: 
		varchar(max), 
		varbinary(max) 
		nvarchar(max) exceeding 8,000 bytes
		cursor
		geometry
		geography
		image
		ntext
		table
		text
		xml

*******************************************************************************/

select *
from sales.Orders as o;
go

select    
    o.orderid, 
    o.orderdate,
    o.requireddate,
    o.shippeddate,
    min(dd.dates) as min_date,
    max(dd.dates) as max_date
from 
    sales.Orders as o
outer apply 
    ( values (o.orderdate), (o.requireddate), (o.shippeddate) ) as dd(dates)
group by 
    o.orderid,
    o.orderdate, 
    o.requireddate,
    o.shippeddate;
go

select    
    o.orderid, 
    o.orderdate,
    o.requireddate,
    o.shippeddate,
    LEAST(o.orderdate, o.requireddate, o.shippeddate) as min_date,
    GREATEST(o.orderdate, o.requireddate, o.shippeddate) as max_date
from 
    sales.Orders as o;
go



/******************************************************************************

	STRING_SPLIT function

*******************************************************************************/

select 
	value 
from
	STRING_SPLIT('Microsoft Data Platform SQL Server 2022', ' ');
go

select 
	value,
	ordinal
from
	STRING_SPLIT('Microsoft Data Platform SQL Server 2022', ' ',1);
go


select 
	value,
	ordinal
from
	STRING_SPLIT('Microsoft Data Platform SQL Server 2022', ' ',1)
where ordinal = 4;
go


select 
	*
from 
	Production.Categories;


select 
	c.*,
	trim(s.value) as value,
	s.ordinal
from 
	Production.Categories as c
cross apply 
	string_split(description,',',1) as s;
go



/******************************************************************************

	DATETRUNC  function

*******************************************************************************/

DECLARE @d datetime2 = '2022-08-29 14:30:29.1234567';
SELECT 'Year', DATETRUNC(year, @d);
SELECT 'Quarter', DATETRUNC(quarter, @d);
SELECT 'Month', DATETRUNC(month, @d);
SELECT 'Week', DATETRUNC(week, @d); -- Using the default DATEFIRST setting value of 7 (U.S. English)
SELECT 'Iso_week', DATETRUNC(iso_week, @d);
SELECT 'DayOfYear', DATETRUNC(dayofyear, @d);
SELECT 'Day', DATETRUNC(day, @d);
SELECT 'Hour', DATETRUNC(hour, @d);
SELECT 'Minute', DATETRUNC(minute, @d);
SELECT 'Second', DATETRUNC(second, @d);
SELECT 'Millisecond', DATETRUNC(millisecond, @d);
SELECT 'Microsecond', DATETRUNC(microsecond, @d);


SELECT 
	InvoiceID,
	ConfirmedDeliveryTime
FROM [WideWorldImporters2022].[Sales].[Invoices]


SELECT 
	InvoiceID,
	ConfirmedDeliveryTime
FROM [WideWorldImporters2022].[Sales].[Invoices]
WHERE ConfirmedDeliveryTime between '2013-01-04 00:00:00.0000000' AND '2013-01-04 23:59:59.9999999'


SELECT 
	InvoiceID,
	ConfirmedDeliveryTime
FROM [WideWorldImporters2022].[Sales].[Invoices]
WHERE DATETRUNC(day,ConfirmedDeliveryTime) ='2013-01-04'


SELECT 
	InvoiceID,
	ConfirmedDeliveryTime
FROM [WideWorldImporters2022].[Sales].[Invoices]
WHERE ConfirmedDeliveryTime between '2013-01-04 07:00:00.0000000' AND '2013-01-04 07:59:59.9999999'

SELECT 
	InvoiceID,
	ConfirmedDeliveryTime
FROM [WideWorldImporters2022].[Sales].[Invoices]
WHERE DATETRUNC(hour,ConfirmedDeliveryTime) ='2013-01-04 07:00:00'