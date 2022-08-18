
use master 
drop database mydemodb

create database mydemodb
go

use mydemodb

/*  
exec sp_addextendedproperty  
		@name =   'property_name'   
	,	@value =  'value'    

    ,	@level0type =  'ASSEMBLY, CONTRACT, EVENT NOTIFICATION, FILEGROUP, 
					    MESSAGE TYPE, PARTITION FUNCTION, PARTITION SCHEME, 
						REMOTE SERVICE BINDING, ROUTE, SCHEMA, SERVICE, 
						USER, TRIGGER, TYPE, PLAN GUIDE, NULL' 
    ,   @level0name =  'level0_object_name'  


    ,	@level1type =  'AGGREGATE, DEFAULT, FUNCTION, LOGICAL FILE NAME, 
						PROCEDURE, QUEUE, RULE, SEQUENCE, SYNONYM, TABLE, 
						TABLE_TYPE, TYPE, VIEW, XML SCHEMA COLLECTION, NULL' 
    ,	@level1name =  'level1_object_name' 
	
    ,   @level2type =  'COLUMN, CONSTRAINT, EVENT NOTIFICATION, INDEX, PARAMETER, TRIGGER, NULL'    
    ,   @level2name =  'level2_object_name'    

*/
exec sys.sp_addextendedproperty 
			@name=N'Version', 
			@value=N'1.0' ;

exec sys.sp_addextendedproperty 
			@name=N'Description', 
			@value=N'My demo db for extended properties';
go

select * from sys.extended_properties;
go


create table table01 ( col1 int, col2 date, col3 decimal(10,2));
go



exec sys.sp_addextendedproperty 
			@name = N'Description', 
			@value= N'My Demo table',
			@level0type = 'SCHEMA',
			@level0name = 'dbo',
			@level1type = 'TABLE',
			@level1name = 'table01';

exec sys.sp_addextendedproperty 
			@name = N'Version', 
			@value= N'1.0',
			@level0type = 'SCHEMA',
			@level0name = 'dbo',
			@level1type = 'TABLE',
			@level1name = 'table01';
go

select * from sys.extended_properties;
go

								
exec sys.sp_addextendedproperty 
			@name = N'Description', 
			@value= N'col1 demo remarks',
			@level0type = 'SCHEMA',
			@level0name = 'dbo',
			@level1type = 'TABLE',
			@level1name = 'table01',
			@level2type = 'COLUMN',
			@level2name = 'col1';

exec sys.sp_addextendedproperty 
			@name = N'DataEntryFormat', 
			@value= N'#,###',
			@level0type = 'SCHEMA',
			@level0name = 'dbo',
			@level1type = 'TABLE',
			@level1name = 'table01',
			@level2type = 'COLUMN',
			@level2name = 'col1';



exec sys.sp_addextendedproperty 
			@name = N'Description', 
			@value= N'col2 demo remarks',
			@level0type = 'SCHEMA',
			@level0name = 'dbo',
			@level1type = 'TABLE',
			@level1name = 'table01',
			@level2type = 'COLUMN',
			@level2name = 'col2';

exec sys.sp_addextendedproperty 
			@name = N'Description', 
			@value= N'col3 demo remarks',
			@level0type = 'SCHEMA',
			@level0name = 'dbo',
			@level1type = 'TABLE',
			@level1name = 'table01',
			@level2type = 'COLUMN',
			@level2name = 'col3';

select * from sys.extended_properties;
go

create proc proc1 @p1 int, @p2 date
as
begin
	select * 
	from dbo.table01 
	where col1=@p1 and col2=@p2
end

exec sys.sp_addextendedproperty 
			@name = N'Description', 
			@value= N'demo stored procedure',
			@level0type = 'SCHEMA',
			@level0name = 'dbo',
			@level1type = 'PROCEDURE',
			@level1name = 'proc1';


exec sys.sp_addextendedproperty 
			@name = N'Description', 
			@value= N'demo stored procedure parameter @p1',
			@level0type = 'SCHEMA',
			@level0name = 'dbo',
			@level1type = 'PROCEDURE',
			@level1name = 'proc1',
			@level2type = 'PARAMETER',
			@level2name = '@p1';

exec sys.sp_addextendedproperty 
			@name = N'Description', 
			@value= N'demo stored procedure parameter @p2',
			@level0type = 'SCHEMA',
			@level0name = 'dbo',
			@level1type = 'PROCEDURE',
			@level1name = 'proc1',
			@level2type = 'PARAMETER',
			@level2name = '@p2';


select * from sys.extended_properties;
go



select 
	db_name() as DatabaseName,
	name as PropertyName,
	value as PropertyValue
from 
	sys.extended_properties
where 
	class = 0


select distinct
        schema_name(t.schema_id) as SchemaName,
        t.name as TableName,
		e.name as PropertyName,
		e.value as PropertyValue
from 
	sys.tables as t
left outer join 
	sys.extended_properties as e on e.major_id = t.object_id and e.minor_id=0
order by 1,2,3 desc

select
    schema_name(t.schema_id) as SchemaName,
    t.name as TableName,
    c.name as ColumnName,
    y.name as ColumnType,
    c.max_length as    ColumnLenght,
    e.name as PropertyName,
	e.value as PropertyValue
from sys.tables as t
    inner join sys.columns as c on t.object_id=c.object_id
    inner join sys.types as y on c.system_type_id=y.user_type_id
    left outer join sys.extended_properties as e on e.major_id=t.object_id and e.minor_id=c.column_id and e.class=1
order by c.column_id


select 
	schema_name(p.schema_id) as SchemaName,
	p.name as ProcedureName,
	e.name as ProcPropertyName,
	e.value as ProcPropertyValue
from 
	sys.procedures as p
left outer join 
	sys.extended_properties as e on e.major_id=p.object_id and e.class=1


select 
	schema_name (cast(objectpropertyex(p.object_id,'SchemaId') as int)) as SchemaName,
	object_name(p.object_id) as ProcedureName,
	p.name as ParameterName,
	t.name as ParameterType,
	p.max_length as ParameterLenght,
	e.name as ParmPropertyName,
	e.value as ParmPropertyValue
from 
	sys.parameters as p
inner join 
	sys.types as t on t.system_type_id=p.user_type_id
left outer join 
	sys.extended_properties as e on e.major_id=p.object_id and e.minor_id=p.parameter_id and e.class=2
order by SchemaName,ProcedureName,p.parameter_id







select distinct
		db_name() as DatabaseName,
        schema_name(t.schema_id) as SchemaName,
        t.name as TableName,
		null as ColumnPosition,
		null as ColumnName,
		null as ColumnType,
		null as ColumnLenght,
		e.name as PropertyName,
		e.value as PropertyValue
from 
	sys.tables as t
left outer join 
	sys.extended_properties as e on e.major_id = t.object_id and e.minor_id=0

union

select
	db_name() as DatabaseName,
    schema_name(t.schema_id) as SchemaName,
    t.name as TableName,
	c.column_id as ColumnPosition,
    c.name as ColumnName,
    y.name as ColumnType,
    c.max_length as ColumnLenght,
    e.name as PropertyName,
	e.value as PropertyValue
from sys.tables as t
    inner join sys.columns as c on t.object_id=c.object_id
    inner join sys.types as y on c.system_type_id=y.user_type_id
    left outer join sys.extended_properties as e on e.major_id=t.object_id and e.minor_id=c.column_id and e.class=1
order by DatabaseName, SchemaName, TableName, ColumnPosition,PropertyName


