/*********************************************************************************************************************

	CONTAINED AVAILABILITY GROUPS
	SQL SERVER 2022
	WHAT'S NEW IN AVAILABILITY

	02 - CREATE GEORGE LOGIN/USER USING THE KNOW PROCEDURE
*********************************************************************************************************************/

SELECT CONVERT(BINARY(16),NEWID())

:CONNECT SQL2022B\RC1
USE master;
CREATE LOGIN george WITH PASSWORD='P@55w.rd', SID = 0x5B863A53D7018440AC9E317E42D1D8E7;
USE HellasGateV2;
CREATE USER george FROM LOGIN george;
ALTER ROLE db_datareader ADD MEMBER george;
GO

:CONNECT SQL2022C\RC1
USE master;
CREATE LOGIN george WITH PASSWORD='P@55w.rd', SID = 0x5B863A53D7018440AC9E317E42D1D8E7;
GO
