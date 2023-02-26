/*********************************************************************************************************************

	TRANSPARENT DATA ENCRYPTION (TDE)
	ENCRYPTION OPTIONS IN SQL SERVER - PART III
	
	(c) 2023 ANTONIOS CHATZIPAVLIS

*********************************************************************************************************************/


-- clear all previous executions
use master;
go

if exists (select name from sys.databases where is_encrypted = 1 and name='HellasGate')
	alter database HellasGate set encryption off;
go

use HellasGate;
go

if exists (select * from sys.dm_database_encryption_keys where database_id = DB_ID('HellasGate'))
	DROP DATABASE ENCRYPTION KEY  
go

use master;
go

if exists ( select * from sys.certificates where name ='HellasGateTDECert')
	drop certificate HellasGateTDECert;
go

if exists (select * from sys.symmetric_keys where name='##MS_DatabaseMasterKey##')
	drop master key; 
go

-- expand hellasgate database

exec hellasgate.dfi.ReGenerateData 
                    @numofCustomers = 50000,
                    @numofSuppliers = 5000,
                    @numofEmployees = 5000,
                    @numofProducts  = 200000,
                    @numofShippers  = 20000,
                    @numofOrders  = 10000000,
                    @maxItemsInOrder  = 10,
                    @calendarstartdate  = null,
                    @calendarnumberofyears = null;
go

backup database HellasGate
to disk = 'G:\MSSQL16.MSSQLSERVER.BACKUP\HellasGateFB.bak'
with init,format
go

use master;
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
create certificate HellasGateTDECert
with subject = 'Certificate for TDE encryption of HellasGate database';
go

-- create TDE certificate
-- This creates two backup files, one for the certificate and one for the private key.
backup certificate HellasGateTDECert
to file = 'G:\MSSQL16.MSSQLSERVER.BACKUP\HellasGateTDECert.cer'
with private key
(
    file = 'G:\MSSQL16.MSSQLSERVER.BACKUP\backupencryptioncert_privatekeyfile.pvk',
    encryption by password = 'zE(T$6Lxq#_nj9ukd-4Y5{D'
);
go

-- create database encryption key (DEK)
use HellasGate;
go

create database encryption key 
with algorithm = aes_256
encryption by server certificate HellasGateTDECert;
go


-- encrypt database
alter database HellasGate set encryption on;
go

backup log HellasGate
to disk = 'G:\MSSQL16.MSSQLSERVER.BACKUP\HellasGateLOG.trn'
with init,format
go

alter database HellasGate set encryption on;
go

select name from sys.databases where is_encrypted = 1;
go

select
   d.name,
   k.encryption_state,
   k.encryption_state_desc,
   k.encryptor_type,
   k.key_algorithm,
   k.key_length,
   k.percent_complete,
   k.encryption_scan_state_desc
from sys.dm_database_encryption_keys as k
inner join sys.databases as d
   on k.database_id = d.database_id;
go


select *
from sys.dm_tran_locks
where resource_type = 'encryption_scan';
