/*********************************************************************************************************************

	CONTAINED AVAILABILITY GROUPS
	SQL SERVER 2022
	WHAT'S NEW IN AVAILABILITY
		
	05 - CHECK USER ANTIGONE

*********************************************************************************************************************/

:CONNECT SQL2022B\RC1
USE HellasGateV2;
EXECUTE AS USER = 'antigone'
SELECT COUNT(*) FROM sales.Customers;
REVERT
GO

:CONNECT SQL2022C\RC1
USE HellasGateV2;
EXECUTE AS USER = 'antigone'
SELECT COUNT(*) FROM sales.Customers;
REVERT
GO

:CONNECT CAG_LISTENER
USE HellasGateV2;
EXECUTE AS USER = 'antigone'
SELECT COUNT(*) FROM sales.Customers;
REVERT
GO
