/****************************************************************************************
	
	Bit manipulation functions

	All five functions are intended to operate on 
		tinyint, smallint, int, bigint, binary(n), and varbinary(n) data types.

	The following types aren't supported: 
		varchar, nvarchar, image, ntext, text, xml, and table.

	In the initial implementation, Distributed Query functionality 
	for the bit manipulation functions within linked server or 
	ad hoc queries (OPENQUERY) won't be supported.

*****************************************************************************************/



-- LEFT/ RIGHT SHIFT

-- 2022 =      0111 1110 0110
-- 8088 = 0001 1111 1001 1000

SELECT  LEFT_SHIFT(2022, 2) as lefts, RIGHT_SHIFT(8088, 2) as rights


-- BIT_COUNT
-- returns the number of bits set to 1 in that parameter as a bigint type

-- abcdef = 1010 1011 1100 1101 1110 1111
SELECT BIT_COUNT ( 0xabcdef ) as Count;

-- 17 = 0001 0001
SELECT  BIT_COUNT ( 17 ) as Count;

-- GET_BIT
-- returns the bit in expression_value that is in the offset defined by bit_offset

-- abcdef = 1010 1011 1100 1101 1110 1111
--                                 |  | 
SELECT GET_BIT ( 0xabcdef, 2 ) as Get_2nd_Bit, GET_BIT ( 0xabcdef, 4 ) as Get_4th_Bit;


-- 2022 =      0111 1110 0110
SELECT	GET_BIT ( 2022, 0 ) as bit_0, GET_BIT ( 2022, 1 ) as bit_1, 
		GET_BIT ( 2022, 2 ) as bit_2, GET_BIT ( 2022, 3 ) as bit_3,
		GET_BIT ( 2022, 4 ) as bit_4, GET_BIT ( 2022, 5 ) as bit_5,
		GET_BIT ( 2022, 6 ) as bit_6, GET_BIT ( 2022, 7 ) as bit_7,
		GET_BIT ( 2022, 8 ) as bit_8, GET_BIT ( 2022, 9 ) as bit_9,
		GET_BIT ( 2022, 10 ) as bit_10, GET_BIT ( 2022, 11 ) as bit_11

-- SET_BIT
-- returns expression_value offset by the bit defined by bit_offset. The bit value defaults to 1, or is set by bit_value.

-- 0x00 = 0000
--        0100 = 0x04
SELECT SET_BIT ( 0x00, 2 ) as r;

-- abcdef = 1010 1011 1100 1101 1110 1111 = 
--          1010 1011 1100 1101 1110 1110

SELECT SET_BIT ( 0xabcdef, 0, 0 ) as r;



SELECT  LEFT_SHIFT(2, 1) as [2^2], 
		LEFT_SHIFT(2, 2) as [2^3],
		LEFT_SHIFT(2, 3) as [2^4],
		LEFT_SHIFT(2, 4) as [2^5]


DECLARE @HEXCOLOR char(6)
DECLARE @INTCOLOR INT 
-- https://www.color-hex.com/color/00ff00

SET @HEXCOLOR = '000000' -- BLACK
SET @HEXCOLOR = 'FFFFFF' -- WHITE
SET @HEXCOLOR = '0000ff' -- BLUE
SET @HEXCOLOR = 'ff0000' -- RED
SET @HEXCOLOR = '00ff00' -- GREEN
SET @HEXCOLOR = '007fff' -- AZURE BLUE
SET @HEXCOLOR = '3d85c6' -- shade of BLUE

SET @INTCOLOR = CONVERT(INT,CONVERT(VARBINARY(4),@HEXCOLOR,2))

SELECT 
	@HEXCOLOR AS COLOR_HEX, 
	@INTCOLOR AS COLOR_INT, 
	RIGHT_SHIFT(@INTCOLOR,16) & 255 AS R, 
	RIGHT_SHIFT(@INTCOLOR,8) & 255 AS G,  
	RIGHT_SHIFT(@INTCOLOR,0) & 255 AS B

