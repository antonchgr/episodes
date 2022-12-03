/*********************************************************************************************************************

	CONTAINED AVAILABILITY GROUPS
	SQL SERVER 2022
	WHAT'S NEW IN AVAILABILITY

	04 - CREATE ANTIGONE LOGIN/USER USING CONTAINED AG LISTENER

*********************************************************************************************************************/

SELECT CONVERT(BINARY(16),NEWID())

:CONNECT CAG_LISTENER
USE master;
CREATE LOGIN antigone WITH PASSWORD='P@55w.rd', SID = 0x466EDFBD020B9549A7024533BE071F16;
USE HellasGateV2;
CREATE USER antigone FROM LOGIN antigone;
ALTER ROLE db_datareader ADD MEMBER antigone;
GO
