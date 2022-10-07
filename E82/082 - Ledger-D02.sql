/*********************************************************************************************************************

	LEDGER - DEMO 02
	SQL SERVER 2022 - WHAT'S NEW IN SECURITY

*********************************************************************************************************************/

-- APPEND-ONLY LEDGER
USE SQLschoolHR;
DROP TABLE IF EXISTS [dbo].[AuditEvents];
CREATE TABLE [dbo].[AuditEvents](
	[Timestamp] [Datetime2] NOT NULL DEFAULT (GETDATE()),
	[UserName] [nvarchar](255) NOT NULL,
	[Query] [nvarchar](4000) NOT NULL
	)
WITH (LEDGER = ON (APPEND_ONLY = ON));
GO

-- UPDATE ROW with HRUser
USE SQLschoolHR;
SELECT empid,lastname,firstname,salary FROM dbo.Employees WHERE empid=8;
UPDATE DBO.Employees SET salary += 10000 WHERE empid=8;
INSERT INTO dbo.AuditEvents VALUES (getdate(), 'mitsos', 'UPDATE dbo.Employees SET Salary += 50000 WHERE empid = 8;');
SELECT empid,lastname,firstname,salary FROM dbo.Employees WHERE empid=8;
GO

USE SQLschoolHR
SELECT * FROM dbo.AuditEvents;
GO

USE SQLschoolHR
UPDATE dbo.AuditEvents SET UserName='kitsos';
GO


-- AUDIT DATA
USE SQLschoolHR
SELECT	
	a.*,
	dlt.transaction_id, 
	dlt.commit_time, 
	dlt.principal_name, 
	a.ledger_operation_type_desc, 
	dlt.table_hashes
FROM 
	sys.database_ledger_transactions AS dlt
JOIN 
	dbo.AuditEvents_Ledger AS a ON a.ledger_transaction_id = dlt.transaction_id
ORDER BY 
	dlt.commit_time DESC;
GO