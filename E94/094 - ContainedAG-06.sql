/*********************************************************************************************************************

	CONTAINED AVAILABILITY GROUPS
	SQL SERVER 2022
	WHAT'S NEW IN AVAILABILITY

	06 - FAILOVER AND CHECK

*********************************************************************************************************************/

:CONNECT SQL2022C\RC1
ALTER AVAILABILITY GROUP [CAG] FAILOVER;
GO

:CONNECT CAG_LISTENER
USE HellasGateV2;
EXECUTE AS USER = 'antigone'
SELECT COUNT(*) FROM sales.Customers;
REVERT
GO

BACKUP DATABASE HellasGateV2
TO DISK ='D:\MSSQL16.RC1\MSSQL\Backup\HellasGateV2AG.BAK'
