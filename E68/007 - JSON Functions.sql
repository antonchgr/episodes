/************************************************************************************************
	
	ISJSON Function
	

	Syntax
	
		ISJSON ( expression [, json_type_constraint] )  

	VALUE	Tests for a valid JSON value. 
			This can be a JSON object, array, number, string or one of the three literal values (false, true, null)
	ARRAY	Tests for a valid JSON array
	OBJECT	Tests for a valid JSON object
	SCALAR	Tests for a valid JSON scalar – number or string

************************************************************************************************/

USE WideWorldImporters2022;

SELECT
	TOP (1000) 
	PersonID
,	CustomFields
,	ISJSON(CustomFields) as is_json
,	ISJSON(CustomFields,value) as is_json_value
,	ISJSON(CustomFields,array) as is_json_array
,	ISJSON(CustomFields,object) as is_json_object
,	ISJSON(CustomFields,scalar) as is_json_scalar
FROM 
	[Application].[People];
GO


/************************************************************************************************
	
	JSON_PATH_EXISTS Function
	
	Syntax
	
		JSON_PATH_EXISTS( value_expression, sql_json_path )   

	Tests whether a specified SQL/JSON path exists in the input JSON string.
	
	Return value
	
		Returns a bit value of 1 or 0 or NULL. 
		Returns NULL if the value_expression or input is a SQL null value. 
		Returns 1 if the given SQL/JSON path exists in the input or returns a non-empty sequence. 
		Returns 0 otherwise.

	The JSON_PATH_EXISTS function does not return errors.

************************************************************************************************/

USE WideWorldImporters2022;

SELECT
	TOP (1000) 
	PersonID
,	CustomFields
,	json_path_exists(CustomFields,'$.CommissionRate') as has_CommissionRate
,	json_path_exists(CustomFields,'$.PrimarySalesTerritory') as has_PrimarySalesTerritory
,	json_path_exists(CustomFields,'$.OtherLanguages') as has_OtherLanguages

FROM 
	[Application].[People];
GO


/************************************************************************************************
	
	JSON_OBJECT Function
	
	Syntax
	
		JSON_OBJECT ( [ <json_key_value> [,...n] ] [ json_null_clause ] )
	
		<json_key_value> ::= json_key_name : value_expression
		<json_null_clause> ::=  NULL ON NULL | ABSENT ON NULL

	Constructs JSON object text from zero or more expressions.
	
	Return value
	
	Returns a valid JSON object string of nvarchar(max) type.
	

************************************************************************************************/

USE TSQLV6;

SELECT 
	*
,	JSON_OBJECT('productid':D.productid,'unitprice':D.unitprice,'qty':D.qty)
,	JSON_OBJECT('product':JSON_OBJECT('id':D.productid,'unitprice':D.unitprice,'qty':D.qty))
FROM 
	SALES.Orders AS O
	INNER JOIN Sales.OrderDetails AS D ON O.orderid = D.orderid



/************************************************************************************************
	
	JSON_ARRAY Function
	
	Syntax
	
		JSON_ARRAY ( [ <json_array_value> [,...n] ] [ <json_null_clause> ]  )  
	
		<json_array_value> ::= value_expression
		<json_null_clause> ::= NULL ON NULL | ABSENT ON NULL

	Constructs JSON array text from zero or more expressions.
	
	Return value
	
		Returns a valid JSON array string of nvarchar(max) type.
	
************************************************************************************************/

USE TSQLV6;

SELECT 
	*
,	JSON_ARRAY('productid',D.productid,'unitprice',D.unitprice,'qty',D.qty)
,	JSON_ARRAY('products',JSON_OBJECT('id':D.productid,'unitprice':D.unitprice,'qty':D.qty))
FROM 
	SALES.Orders AS O
	INNER JOIN Sales.OrderDetails AS D ON O.orderid = D.orderid

GO

