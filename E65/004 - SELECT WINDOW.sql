use tsqlv6;
 
select 
	orderid, 
	custid, 
	orderdate, 
	qty, val,
	sum(qty) over( partition by custid order by orderdate, orderid rows unbounded preceding ) as qty_running_total,
	sum(val) over( partition by custid order by orderdate, orderid rows unbounded preceding ) as amt_running_total,
	sum(qty) over( partition by custid ) as qty_total,
	sum(val) over( partition by custid ) as amt_total
from 
	sales.ordervalues
order by 
	custid, orderdate, orderid;

















-- new syntax 
/*

	SELECT
	FROM
	WHERE
	GROUP BY
	HAVING
	WINDOW
	ORDER BY

*/

select 
	orderid, 
	custid, 
	orderdate, 
	qty, val,
	sum(qty) over W1  as qty_running_total,
	sum(val) over W1  as amt_running_total,
	sum(qty) over W2  as qty_total,
	sum(val) over W2  as amt_total
from 
	sales.ordervalues
window 
		W1 as ( partition by custid order by orderdate, orderid rows unbounded preceding ),
		W2 as ( partition by custid ) 
order by 
	custid, orderdate, orderid;


select 
	orderid, 
	custid, 
	orderdate, 
	qty, val,
	sum(qty) over W2  as qty_running_total,
	sum(val) over W2  as amt_running_total,
	sum(qty) over W1  as qty_total,
	sum(val) over W1  as amt_total
from 
	sales.ordervalues
window 
		W1 as ( partition by custid ),
		W2 as ( W1 order by orderdate, orderid rows unbounded preceding )
order by 
	custid, orderdate, orderid;

select 
	orderid, 
	custid, 
	orderdate, 
	qty, val,
	sum(qty) over W1  as qty_running_total,
	sum(val) over W1  as amt_running_total,
	sum(qty) over W2  as qty_total,
	sum(val) over W2  as amt_total
from 
	sales.ordervalues
window 
		W1 as ( W2 order by orderdate, orderid rows unbounded preceding ),
		W2 as ( partition by custid )
order by 
	custid, orderdate, orderid;


select 
	orderid, 
	custid, 
	orderdate, 
	qty, val,
	sum(qty) over ( W1 order by orderdate, orderid rows unbounded preceding ) as qty_running_total,
	sum(val) over ( W1 order by orderdate, orderid rows unbounded preceding ) as amt_running_total,
	sum(qty) over W1  as qty_total,
	sum(val) over W1  as amt_total
from 
	sales.ordervalues
window 
		W1 as ( partition by custid )
order by 
	custid, orderdate, orderid;


select 'Cyclic window references are not permitted' window W1 as (W2), W2 as (W3), W3 as (W1);

select 
    book_id, 
    log_time, 
    action_type, 
    member_id ,
	last_value (member_id) over W as  lv
from dbo.LibraryLog
window W as ( partition by book_id order by log_time rows unbounded preceding)
order by book_id, log_time;


select 
    book_id, 
    log_time, 
    action_type, 
    member_id ,
	last_value (member_id) ignore nulls over W as  lv
from dbo.LibraryLog
window W as ( partition by book_id order by log_time rows unbounded preceding)
order by book_id, log_time;



