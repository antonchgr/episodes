/********************************************************************************************************
	
	STATISTICS AUTO UPDATES

********************************************************************************************************/

USE HellasGate2022;
GO

-- create a table 
DROP TABLE IF EXISTS edu.TestStats;
GO
CREATE TABLE edu.TestStats
(
    col1 INT IDENTITY,
    col2 INT 
);
GO


-- insert 2000 rows
INSERT INTO edu.TestStats (col2)
SELECT value
FROM GENERATE_SERIES (1,2000);
GO

-- create nc index on col2
CREATE NONCLUSTERED INDEX i1 ON edu.TestStats (col2);
GO

-- create xe objects 

-- actual execution plan
SELECT t.col1,
       t.col2
FROM edu.TestStats AS t
WHERE t.col2 = 2;

-- close actual execution plan
-- view xe data
SELECT * FROM tempdb.dbo.StatisticsMonitorXE
ORDER BY [timestamp];
GO

-- update threshord
SELECT	SQRT(1000*COUNT(*)) as sqrt_update_threshord, 
		(500+(0.2*count(*))) as min_update_threshord,
		((least(SQRT(1000*COUNT(*)),(500+(0.2*count(*))))) * 0.90)-10
FROM edu.TestStats

-- insert rows 
INSERT INTO edu.TestStats (col2)
SELECT value
FROM GENERATE_SERIES (1,19000);
GO

-- select again
SELECT t.col1,
       t.col2
FROM edu.TestStats AS t
WHERE t.col2 = 2;

-- view xe data
SELECT * FROM tempdb.dbo.StatisticsMonitorXE
ORDER BY [timestamp];
GO
