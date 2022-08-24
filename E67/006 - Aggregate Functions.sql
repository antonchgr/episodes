use Stats;

select * from dbo.score005;

select 
	Exam,
	Examinee,
	Score,
	percentile_cont (0.5) within group (order by score) over (partition by exam) as medianscore_cont, 
	percentile_disc (0.5) within group (order by score) over (partition by exam) as medianscore_disc
from dbo.score005;
go


/********************************************************************************************************************/

use Stats;
select * from dbo.score010;

select 
	Exam,
	Examinee,
	Score,
	percentile_cont (0.5) within group (order by score) over (partition by exam) as medianscore_cont, 
	percentile_disc (0.5) within group (order by score) over (partition by exam) as medianscore_disc
from dbo.score010;
go

/********************************************************************************************************************/

use Stats;

select  * from  dbo.score100;

select 
	Exam,
	Examinee,
	Score,
	percentile_cont (0.5) within group (order by score) over (partition by exam) as medianscore_cont, 
	percentile_disc (0.5) within group (order by score) over (partition by exam) as medianscore_disc
from dbo.score100;
go

/********************************************************************************************************************


	The Approximate Percentile Functions
	
	
	According to the documentation

	This function provides rank-based error guarantees not value based. 
	The function implementation guarantees up to a 1.33% error bounds within a 99% confidence.

	The algorithm used for these functions is KLL sketch which is a randomized algorithm. 
	https://arxiv.org/pdf/1603.05346v2.pdf

	Every time the sketch is built, random values are picked. 
	These functions provide rank-based error guarantees not value based.

********************************************************************************************************************/

use Stats;

select * from dbo.score1000000;

set statistics io on ;
set statistics time on;

 
with a as 
(
	select 
		Exam,
		percentile_cont (0.5) within group (order by score) over (partition by exam) as medianscore_cont, 
		percentile_disc (0.5) within group (order by score) over (partition by exam) as medianscore_disc
	from dbo.score1000000
)
select exam , max(medianscore_cont) as medianscore_cont, max(medianscore_disc) as medianscore_disc from a group by Exam;


select 
	distinct
	Exam,
	percentile_cont (0.5) within group (order by score) over (partition by exam) as medianscore_cont, 
	percentile_disc (0.5) within group (order by score) over (partition by exam) as medianscore_disc
from dbo.score1000000


select 
	Exam,
	approx_percentile_cont (0.5) within group (order by score) as medianscore_cont, 
	approx_percentile_disc (0.5) within group (order by score) as medianscore_disc
from dbo.score1000000
group by exam;