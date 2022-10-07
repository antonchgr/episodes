/*********************************************************************************************************************

	LEDGER - DEMO 03
	SQL SERVER 2022 - WHAT'S NEW IN SECURITY

*********************************************************************************************************************/

USE SQLschoolHR;
GO
-- YOU CANNOT TURN OFF VERSIONING FOR A LEDGER TABLE
ALTER TABLE dbo.Employees SET (SYSTEM_VERSIONING = OFF);
GO
-- YOU CANNOT DROP THE LEDGER HISTORY TABLE
DROP TABLE MSSQL_LedgerHistoryFor_917578307;
GO
-- YOU CAN DROP A LEDGER TABLE
DROP TABLE dbo.Employees;
GO
-- BUT WE KEEP A HISTORY OF THE DROPPED TABLE
SELECT * FROM sys.objects WHERE name like '%DroppedLedgerTable%';
GO
-- AUDIT DATA
USE SQLschoolHR
SELECT	
	e.empid, e.lastname, e.firstname, e.title, e.titleofcourtesy, 
	e.birthdate, e.hiredate, e.[address], e.city, e.region, e.postalcode, 
	e.country, e.phone, e.mgrid, e.salary,
	dlt.transaction_id, 
	dlt.commit_time, 
	dlt.principal_name, 
	e.ledger_operation_type_desc, 
	dlt.table_hashes
FROM 
	sys.database_ledger_transactions AS dlt
JOIN 
	[dbo].[MSSQL_DroppedLedgerView_Employees_Ledger_FD7E901B55C741FC8728DABF562DD167] AS e 
		ON e.ledger_transaction_id = dlt.transaction_id
ORDER BY 
	e.empid,dlt.commit_time DESC;
GO

