/*********************************************************************************************************************

	CONTAINED AVAILABILITY GROUPS
	SQL SERVER 2022
	WHAT'S NEW IN AVAILABILITY

	01 - VIEW PRINCIPALS
	02 - CREATE GEORGE LOGIN/USER USING THE KNOW PROCEDURE
	03 - CHECK USER GEORGE
	04 - CREATE ANTIGONE LOGIN/USER USING CONTAINED AG LISTENER
	05 - CHECK USER ANTIGONE
	06 - FAILOVER AND CHECK

*********************************************************************************************************************/

-- RESET DEMO

:CONNECT CAG_LISTENER
USE HellasGateV2;
ALTER ROLE db_datareader DROP MEMBER antigone;
DROP USER antigone;
USE master;
DROP LOGIN antigone; 
GO


:CONNECT SQL2022B\RC1
USE HellasGateV2;
ALTER ROLE db_datareader DROP MEMBER george;
DROP USER george ;
USE master;
DROP LOGIN george;
GO

:CONNECT SQL2022C\RC1
USE master;
DROP LOGIN george;
GO
