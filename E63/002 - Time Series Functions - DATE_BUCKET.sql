/******************************************************************************

	DATE_BUCKET function

	DATE_BUCKET (datepart, number, date, origin)

	Use DATE_BUCKET in the following clauses:

	GROUP BY
	HAVING
	ORDER BY
	SELECT <list>
	WHERE


*******************************************************************************/


DECLARE 
	@date DATETIME2 = '2022-06-13 14:08:00'
,	@bucket int = 6
--,	@origin datetime2 = '2021-01-13 00:00:00';
,	@origin datetime2 = '1900-01-01 00:00:00';

SELECT @date,DATE_BUCKET(MONTH, @bucket, @date, @origin)

SELECT @date,DATE_BUCKET(MONTH, 1, @date, @origin) as m1, DATE_BUCKET(MONTH, 2, @date, @origin) as m2

GO

DECLARE 
	@date DATETIME2 = SYSDATETIME()
,	@bucket int = 1
,	@origin datetime2 = '2022-02-01 00:00:00';
--,	@origin datetime2 = '1900-01-01 00:00:00';

SELECT 1 as aa, 'DAY' as datepart, @date as currentdate ,DATE_BUCKET(DAY, @bucket, @date, @origin) as date_bucket_result
UNION
SELECT 2, 'WEEK',@date,DATE_BUCKET(WEEK, @bucket, @date, @origin)
UNION
SELECT 3, 'MONTH',@date,DATE_BUCKET(MONTH, @bucket, @date, @origin)
UNION
SELECT 4, 'QUARTER',@date,DATE_BUCKET(QUARTER, @bucket, @date, @origin)
UNION
SELECT 5, 'YEAR',@date,DATE_BUCKET(YEAR, @bucket, @date, @origin)
UNION
SELECT 6, 'HOUR',@date,DATE_BUCKET(HOUR, @bucket, @date, @origin)
UNION
SELECT 7, 'MINUTE',@date,DATE_BUCKET(MINUTE, @bucket, @date, @origin)
UNION
SELECT 8, 'SECOND',@date,DATE_BUCKET(SECOND, @bucket, @date, @origin)
UNION
SELECT 9, 'MILLISECOND',@date,DATE_BUCKET(MILLISECOND, @bucket, @date, @origin);
GO


select YEAR(orderdate) as y, month(orderdate) as m , count(*) as orders_num
from sales.Orders
group by YEAR(orderdate), month(orderdate)
order by y,m


select DATE_BUCKET(YEAR,1,orderdate) as b,  count(*) as orders_num
from sales.Orders
group by DATE_BUCKET(YEAR,1,orderdate)
order by b