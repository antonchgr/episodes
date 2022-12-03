/*********************************************************************************************************************

	CONTAINED AVAILABILITY GROUPS
	SQL SERVER 2022
	WHAT'S NEW IN AVAILABILITY

	03 - CHECK USER GEORGE

*********************************************************************************************************************/

:CONNECT SQL2022B\RC1
USE HellasGateV2;
EXECUTE AS USER = 'george'
SELECT COUNT(*) FROM sales.Customers;
REVERT
GO

:CONNECT SQL2022C\RC1
USE HellasGateV2;
EXECUTE AS USER = 'george'
SELECT COUNT(*) FROM sales.Customers;
REVERT
GO

:CONNECT CAG_LISTENER
USE HellasGateV2;
EXECUTE AS USER = 'george'
SELECT COUNT(*) FROM sales.Customers;
REVERT
GO
