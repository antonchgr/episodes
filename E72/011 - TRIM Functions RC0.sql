/*
	
	TRIM Functions Enchancements SQL Server 2022 RC0

	TRIM ( [ LEADING | TRAILING | BOTH ] [characters FROM ] string )
	RTRIM ( character_expression , [ characters ] )
	LTRIM ( character_expression , [ characters ] )

	Earlier Version and Azure SQL Database

	TRIM ( [ characters FROM ] string )
	RTRIM ( character_expression )
	LTRIM ( character_expression )

*/

use tempdb;
go

declare @s1 nvarchar(20) = N'123SQLschool.gr123';
select 
	TRIM('123' FROM @s1),
	TRIM(LEADING '123' FROM @s1),
	TRIM(TRAILING '123' FROM @s1),
	TRIM(BOTH '123' FROM @s1),
	RTRIM (@s1,'123'),
	LTRIM (@s1,'123')


declare @s2 nvarchar(20) = N'123SQLschool.gr456';
select 
	TRIM('123456' FROM @s2),
	TRIM(LEADING '123456' FROM @s2),
	TRIM(TRAILING '123456' FROM @s2),
	TRIM(BOTH '123456' FROM @s2),
	RTRIM (@s2,'123456'),
	LTRIM (@s2,'123456')


