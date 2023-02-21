/*********************************************************************************************************************

	BACKUP ENCRYPTION IN SQL SERVER
	ENCRYPTION OPTIONS IN SQL SERVER - PART II
	
	(C) 2023 ANTONIOS CHATZIPAVLIS

*********************************************************************************************************************/

use master;
go

-- clear all previous executions
if exists ( select * from sys.certificates where name ='BackupEncryptionCert')
	drop certificate BackupEncryptionCert;
go
if exists (select * from sys.symmetric_keys where name='##MS_DatabaseMasterKey##')
	drop master key; 
go

-- create master key
create master key
encryption by password = 'zE(T$6Lxq#_nj9ukd-4Y5{D';
go

-- backup master key
backup master key to file = 'G:\MSSQL16.MSSQLSERVER.BACKUP\demoDMK'
encryption by password = 'zE(T$6Lxq#_nj9ukd-4Y5{D';
go

-- create certificate for backup usage
create certificate BackupEncryptionCert
with subject = 'Certificate for backup encryption';
go

-- backup certificate
backup certificate backupencryptioncert
to file = 'G:\MSSQL16.MSSQLSERVER.BACKUP\backupencryptioncert.cer'
with private key
(
    file = 'G:\MSSQL16.MSSQLSERVER.BACKUP\backupencryptioncert_privatekeyfile.pvk',
    encryption by password = 'zE(T$6Lxq#_nj9ukd-4Y5{D'
);
go

-- set default size in hellasgate database
exec hellasgate.dfi.ReGenerateData;
go

-- in the case of the account that is taking backups is not sysadmin
use master;
grant view definition on certificate::backupencryptioncert to <account>;
go

-- take encrypted backup
backup database HellasGate
to disk = 'G:\MSSQL16.MSSQLSERVER.BACKUP\HellasGate_encrypted.bak'
with encryption(algorithm = aes_256, server certificate = backupencryptioncert);
go

-- restore backup metadata
restore headeronly
from disk = 'G:\MSSQL16.MSSQLSERVER.BACKUP\HellasGate_encrypted.bak';
go

-- restore encrypted backup
restore database HellasGate
from disk = 'G:\MSSQL16.MSSQLSERVER.BACKUP\HellasGate_encrypted.bak'
with replace;


-- everyhting goes to hell
if exists ( select * from sys.certificates where name ='BackupEncryptionCert')
	drop certificate BackupEncryptionCert;
go

-- restore encrypted backup
restore database HellasGate
from disk = 'G:\MSSQL16.MSSQLSERVER.BACKUP\HellasGate_encrypted.bak'
with replace;
go


-- restore certificate
create certificate backupencryptioncert
from file = 'G:\MSSQL16.MSSQLSERVER.BACKUP\backupencryptioncert.cer'
with private key
(
   file = 'G:\MSSQL16.MSSQLSERVER.BACKUP\backupencryptioncert_privatekeyfile.pvk',
   decryption by password = 'zE(T$6Lxq#_nj9ukd-4Y5{D'
);
go

-- restore encrypted backup
restore database HellasGate
from disk = 'G:\MSSQL16.MSSQLSERVER.BACKUP\HellasGate_encrypted.bak'
with replace;
go

-- prefromance

backup database HellasGate
to disk = 'G:\MSSQL16.MSSQLSERVER.BACKUP\HellasGate_unencrypted.bak'
with init,format
go

backup database HellasGate
to disk = 'G:\MSSQL16.MSSQLSERVER.BACKUP\HellasGate_encrypted.bak'
with encryption(algorithm = aes_256, server certificate = backupencryptioncert)
, init, format;
go

exec hellasgate.dfi.ReGenerateData 
                    @numofCustomers = 15000,
                    @numofSuppliers = 1500,
                    @numofEmployees = 1500,
                    @numofProducts  = 20000,
                    @numofShippers  = 2000,
                    @numofOrders  = 1000000,
                    @maxItemsInOrder  = 10,
                    @calendarstartdate  = null,
                    @calendarnumberofyears = null;
go

backup database HellasGate
to disk = 'G:\MSSQL16.MSSQLSERVER.BACKUP\HellasGate_unencrypted.bak'
with init,format
go

backup database HellasGate
to disk = 'G:\MSSQL16.MSSQLSERVER.BACKUP\HellasGate_encrypted.bak'
with encryption(algorithm = aes_256, server certificate = backupencryptioncert)
, init, format;
go

-- compression
backup database HellasGate
to disk = 'G:\MSSQL16.MSSQLSERVER.BACKUP\HellasGate_unencrypted.bak'
with init,format,compression;
go

backup database HellasGate
to disk = 'G:\MSSQL16.MSSQLSERVER.BACKUP\HellasGate_encrypted.bak'
with encryption(algorithm = aes_256, server certificate = backupencryptioncert)
, init, format, compression;
go


