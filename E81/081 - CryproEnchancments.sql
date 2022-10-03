/*********************************************************************************************************************

	Crypto and Encryption Enhancements
	SQL Server 2022 - What's new in Security

*********************************************************************************************************************/

USE master;
GO

CREATE CREDENTIAL [https://sql2022backups.blob.core.windows.net/certbackups]
WITH 
	IDENTITY ='SHARED ACCESS SIGNATURE'
,	SECRET = '...';
GO

SELECT * FROM sys.credentials;
GO

----------------------------------------------------------------------------------------------------------------------

CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'ehz6SPEwb#kI8@vNdrHTFy7x(U2qfsXm';
GO

SELECT * FROM sys.symmetric_keys;
GO

BACKUP MASTER KEY
TO URL = 'https://sql2022backups.blob.core.windows.net/certbackups\mk2022.bak'
ENCRYPTION BY PASSWORD ='%MpEwSs$Ffq4(89CeGnQ3WXZVvxk)Y7a';
GO

DROP MASTER KEY;
GO

SELECT * FROM sys.symmetric_keys;
GO

RESTORE MASTER KEY
FROM URL = 'https://sql2022backups.blob.core.windows.net/certbackups\mk2022.bak'
DECRYPTION BY PASSWORD ='%MpEwSs$Ffq4(89CeGnQ3WXZVvxk)Y7a'
ENCRYPTION BY PASSWORD ='%MpEwSs$Ffq4(89CeGnQ3WXZVvxk)Y7a';
GO

SELECT * FROM sys.symmetric_keys;
GO

----------------------------------------------------------------------------------------------------------------------

OPEN MASTER KEY DECRYPTION BY PASSWORD ='%MpEwSs$Ffq4(89CeGnQ3WXZVvxk)Y7a';

CREATE CERTIFICATE Cert2022
WITH SUBJECT = 'Sqlschool demo A';
GO

SELECT * FROM sys.certificates;
GO

-- BACKUP CERT TO PFX

BACKUP CERTIFICATE Cert2022
TO FILE = 'D:\SampleDatabases\Cert2022.pfx'
WITH
	FORMAT = 'PFX',
	PRIVATE KEY ( ENCRYPTION BY PASSWORD ='%MpEwSs$Ffq4(89CeGnQ3WXZVvxk)Y7a', ALGORITHM = 'AES_256');
GO

DROP CERTIFICATE Cert2022;
GO
SELECT * FROM sys.certificates;
GO

-- CREATE CERTIFICATE FROM PFX FILE
CREATE CERTIFICATE Cert2022
FROM FILE = 'D:\SampleDatabases\Cert2022.pfx'
WITH
	FORMAT = 'PFX',
	PRIVATE KEY ( ENCRYPTION BY PASSWORD ='%MpEwSs$Ffq4(89CeGnQ3WXZVvxk)Y7a', 
				  DECRYPTION BY PASSWORD ='%MpEwSs$Ffq4(89CeGnQ3WXZVvxk)Y7a');
GO
SELECT * FROM sys.certificates;
GO