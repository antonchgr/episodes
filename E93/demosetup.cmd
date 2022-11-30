echo off

echo Current TempDB Files Configuration
sqlcmd -S SQL2022B\RC1 -E -i currenttempdbconfiguration.sql -Y 50 -y 150

echo Start SQL Server with minimal confiuration
net stop mssql$rc1
net start mssql$rc1 /f /mSQLCMD

echo Modify TempDB Configuration
sqlcmd -S SQL2022B\RC1 -E -i modifytempdblog.sql -Y 50 -y 150

echo Current TempDB Files Configuration
sqlcmd -S SQL2022B\RC1 -E -i currenttempdbconfiguration.sql -Y 50 -y 150

echo Disbale TempDB optimizations 
sqlcmd -S SQL2022B\RC1 -E -Q "ALTER SERVER CONFIGURATION SET MEMORY_OPTIMIZED TEMPDB_METADATA = OFF;" -Y 50 -y 150

echo Disable GAM/SGAM
net stop mssql$rc1
net start mssql$rc1 /T6950 /T6962
