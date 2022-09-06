/*****************************************************************************************************************************

	XML compression	

	XML compression provides a method to compress off-row XML data for both XML columns and indexes, 
	improving capacity requirements. 

	For more information, see CREATE TABLE (Transact-SQL) and CREATE INDEX (Transact-SQL).

******************************************************************************************************************************/

use AdventureWorks2022;
go

select object_name(object_id) objectname, * from sys.xml_indexes
where object_name(object_id) in ('Person_Copy','Person_Copy_XML_Compressed');
go

exec sp_spaceused 'Person.Person_Copy'
exec sp_spaceused 'Person.Person_Copy_XML_Compressed'


use AdventureWorks2022;
set statistics io on

;with xmlnamespaces 
('http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey' AS ns)
select *
from Person.Person_Copy
where Demographics.exist('(/ns:IndividualSurvey/ns:Education[.="Bachelors"])')=0
go
--Compressed
;with xmlnamespaces 
('http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey' AS ns)
select *
from Person.Person_Copy_XML_Compressed
where Demographics.exist('(/ns:IndividualSurvey/ns:Education[.="Bachelors"])')=0
go

set statistics io off



-------------------------------------------------------------------------------------------
-- ENABLE XML (Only) COMPRESSION --------------------------------------------------------
-------------------------------------------------------------------------------------------

alter table person.person_copy_xml_compressed 
rebuild partition = all with (xml_compression = on);
go
alter index pxml_person_copy_xml_compressed_addcontact
on person.person_copy_xml_compressed rebuild with (xml_compression = on);
alter index pxml_person_copy_xml_compressed_demographics
on person.person_copy_xml_compressed rebuild with (xml_compression = on);
alter index xmlpath_person_copy_xml_compressed_demographics
on person.person_copy_xml_compressed rebuild with (xml_compression = on);
alter index xmlproperty_person_copy_xml_compressed_demographics
on person.person_copy_xml_compressed rebuild with (xml_compression = on);
alter index xmlvalue_person_copy_xml_compressed_demographics
on person.person_copy_xml_compressed rebuild with (xml_compression = on);
go

exec sp_spaceused 'Person.Person_Copy'
exec sp_spaceused 'Person.Person_Copy_XML_Compressed'


use AdventureWorks2022;
set statistics io on

;with xmlnamespaces 
('http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey' AS ns)
select *
from Person.Person_Copy
where Demographics.exist('(/ns:IndividualSurvey/ns:Education[.="Bachelors"])')=0
go
--Compressed
;with xmlnamespaces 
('http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey' AS ns)
select *
from Person.Person_Copy_XML_Compressed
where Demographics.exist('(/ns:IndividualSurvey/ns:Education[.="Bachelors"])')=0
go

set statistics io off

