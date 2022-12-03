/*********************************************************************************************************************

	CONTAINED AVAILABILITY GROUPS
	SQL SERVER 2022
	WHAT'S NEW IN AVAILABILITY

	01 - VIEW PRINCIPALS
*********************************************************************************************************************/
:CONNECT SQL2022B\RC1
USE master;
SELECT @@SERVERNAME AS servername, name,sid,type 
FROM sys.server_principals WHERE type = 'S';
GO

:CONNECT SQL2022C\RC1
USE master;
SELECT @@SERVERNAME AS servername, name,sid,type 
FROM sys.server_principals WHERE type = 'S';
GO

:CONNECT CAG_LISTENER
USE master;
SELECT @@SERVERNAME AS servername, name,sid,type 
FROM sys.server_principals WHERE type = 'S';
GO
