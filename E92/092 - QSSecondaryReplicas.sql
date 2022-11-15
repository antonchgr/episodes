/*********************************************************************************************************************

	QUERY STORE AND SECONDARY REPLICAS
	SQL SERVER 2022
	WHAT'S NEW IN QUERY STORE

*********************************************************************************************************************/

USE HellasGateV1;
GO

ALTER DATABASE HellasGateV1 
SET QUERY_STORE = ON;
GO
ALTER DATABASE HellasGateV1 
SET QUERY_STORE ( OPERATION_MODE = READ_WRITE );
GO

ALTER DATABASE HellasGateV1
FOR SECONDARY SET QUERY_STORE = ON (OPERATION_MODE = READ_WRITE );
GO

SELECT * FROM sys.query_store_replicas;
GO

:CONNECT SQL2022C\RC1
USE HellasGateV1
SELECT desired_state, desired_state_desc, actual_state, actual_state_desc, readonly_reason
FROM sys.database_query_store_options;
-- The readonly_reason of 8 indicates that the query was run against a secondary replica. 
-- These results indicate that Query Store has been enabled successfully on the secondary replica.

ALTER DATABASE HellasGateV1
FOR SECONDARY SET QUERY_STORE = OFF;
GO

USE HellasGateV1;
SELECT * FROM sys.query_store_replicas;
GO

:CONNECT SQL2022C\RC1
USE HellasGateV1
SELECT * FROM sys.query_store_replicas;
GO
/*
The only Query Store views that capture the replica_group_id are 
	sys.query_store_runtime_stats and 
	sys.query_store_wait_stats. 

If you want to find out information in the plan store (i.e., Sys.query_store_query) 
specific to a replica, you will need to join to one of these views 
(using the plan_id as the join column). 
In other words, if you only query sys.query_store_plan, you will not be able to tell 
whether plans were captured from the primary or secondary replicas.
*/

ALTER DATABASE HellasGateV1 SET QUERY_STORE CLEAR ALL;
GO

SELECT *
FROM sales.OrdersHeader AS o
INNER JOIN sales.OrderItems AS i ON o.orderid= i.orderid

:CONNECT SQL2022C\RC1
USE HellasGateV1
SELECT *
FROM sales.OrdersHeader AS o
INNER JOIN sales.OrderItems AS i ON o.orderid= i.orderid


USE HellasGateV1;
SELECT * FROM sys.query_store_replicas;
SELECT * FROM sys.query_store_runtime_stats
SELECT * FROM sys.query_store_wait_stats 