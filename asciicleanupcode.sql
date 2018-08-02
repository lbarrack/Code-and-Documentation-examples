----------------------------------------------------------------------------------------------------Create Table 

USE AdventureWorks2012 

GO 

/****** Object: Table dbo.STG_VALID_DATA_CLEANSE Script Date: 2/13/2018 8:32:16 AM ******/ 
--DROP TABLE dbo.STG_VALID_DATA_CLEANSE 
SET ANSI_NULLS ON 
GO 

SET QUOTED_IDENTIFIER ON 
GO

 IF OBJECT_ID('dbo.STG_VALID_DATA_CLEANSE') IS NULL 
 CREATE TABLE dbo.STG_VALID_DATA_CLEANSE ( VALID_DATA_CLEANSE_ID int IDENTITY(1,1) NOT NULL, DATATYPE varchar(25) NOT NULL, VALIDCHARS varchar(500) NOT NULL ) 
 
 GO 
 
 ------------------------------------------------------------------------------------------------INSERT TABLE VALUES- updated 
 USE AdventureWorks2012 
 GO 
 
 DELETE dbo.STG_VALID_DATA_CLEANSE 
 
 Set Identity_Insert dbo.STG_VALID_DATA_CLEANSE ON 
 
 GO 
 
 Insert into dbo.STG_VALID_DATA_CLEANSE ( VALID_DATA_CLEANSE_ID, DATATYPE, VALIDCHARS ) 
 Values (1,'NAME','%[^aáâãäbcdeéêÇfƒghiíÌÌîïjlmnñoòóôöðpqrstuúüûvxyŸz¿ABCD EÈËFGHIJKLMNÑOÕPQRSTUÙVWXYÝZ1234567890.~Ü,-]%'), 
 (2,'EMPLOYERNAME','%[^aáâãäbcdeéêÇfƒghiíÌÌîïjlmnñoòóôöðpqrstuúüûvxyŸz¿ABCD EÈËFGHIJKLMNÑOÕPQRSTUÙVWXYÝZ.1234567890."~Ü&™"~,-]%'), 
 (3,'ADDRESS','%[^aáâãäbcdeéêÇfƒghiíÌÌîïjlmnñoòóôöðpqrstuúüûvxyŸz¿ABCD EÈËFGHIJKLMNÑOÕPQRSTUÙVWXYÝZ1234567890.¼½¾.&"~Ü,-]%'), 
 (4,'PHONE','%[^1234567890]%'), 
 (5,'EMAIL','%[^@aáâãäbcdeéêÇfƒghiíÌÌîïjlmnñoòóôöðpqrstuúüûvxyŸz¿ABCD EÈËFGHIJKLMNÑOÕPQRSTUÙVWXYÝZ_1234567890."~Ü,-]%'), 
 (6,'ZIP','%[^1234567890]%'), (7,'DEFAULT','%[^:;<=>?@-^^{|}()''!\/aáâãäbcdeéêÇfƒghiíÌÌîïjlmnñoòóôöðpqrstuúüûvxyŸz¿ABCD EÈËFGHIJKLMNÑOÕPQRSTUÙVWXYÝZ.1234567890><=."#$%~Ü&&*+™"~,_``-]%') 
 
 GO 
 Set Identity_Insert dbo.STG_VALID_DATA_CLEANSE OFF 
 
 GO 
 ------------------------------------------------------------------------------------------------------------------------------Select TABLE 
 SELECT VALID_DATA_CLEANSE_ID ,DATATYPE ,VALIDCHARS 
 FROM [AdventureWorks2012].dbo.STG_VALID_DATA_CLEANSE 
 GO
 ------------------------------------------------------------------------------------------------------------------------------------CREATE Function 
 USE AdventureWorks2012 
 
 GO 
 
 /****** Object: UserDefinedFunction [dbo].[UFN_DATA_CLEANSE] Script Date: 2/14/2018 12:13:46 PM ******/ 
 -- THIS FUNCTION IS USED TO FILTER OUT ASCII CHARACTERS THAT BREAK THE CREATION OF XML FILES 
 -- THE FILTERING STRINGS ARE STORED IN THE dbo.STG_VALID_DATA_CLEANSE TABLE AND PULLED BY DATATYPE 
 ----------------------------------------------------------------------------------------------------------- 
 
 SET ANSI_NULLS ON 
 GO 

 SET QUOTED_IDENTIFIER ON 
 GO
 
 IF (OBJECT_ID('dbo.UFN_DATA_CLEANSE') IS NOT NULL) 
 DROP FUNCTION dbo.UFN_DATA_CLEANSE 
 
 GO 
 
 CREATE FUNCTION dbo.UFN_DATA_CLEANSE ( @String NVARCHAR(MAX), @MatchExpression VARCHAR(255) ) 
 
RETURNS NVARCHAR(MAX) AS 
BEGIN
 
 DECLARE @STRTYPE VARCHAR(200) 
 SET @STRTYPE = ( SELECT VALIDCHARS FROM dbo.STG_VALID_DATA_CLEANSE WHERE DATATYPE = @MatchExpression ) 
 WHILE (PatIndex(@STRTYPE, @String) > 0) BEGIN SET @String = Stuff(@String, PatIndex(@STRTYPE, @String ), 1, '') 
 
 END 
 ---------------------------------------------------------------------------------------------------------- 
 -- ********************** Do Not Remove ******************* 
 -- THE REPLACE FUNCTION IS USED WITH COLLATE LATIN1_GENERAL_BIN TO CHANGE THE DEFAULT COLLATION 
 -- OF SQL SERVER TO RECOGNIZE THE DIFFERENCE BETWEEN SOME LOWER AND HIGHER ASCII CHARS FOR FILTERING 
 -- FOR EXAMPLE CHAR 49 - 1 AND CHAR 185 - ¹ LOOK THE SAME IN THE DEFAULT COLLATION 
 ---------------------------------------------------------------------------------------------------------- 
 
 RETURN Replace(Replace(Replace(@String collate Latin1_General_BIN,CHAR(185),''),CHAR(178),''),CHAR(179),'') 
 
 END 
 
 ---------------------------------------------------------------------------------------------------------------CREATE TABLE INDEX 
 
 USE AdventureWorks2012 
 
 GO 
 
 SELECT @@SERVERNAME 
 
 GO 
 
 /*****************************************************************************/ -- 
 -- FILENAME : STG_STG_VALID_DATA_CLEANSE.SQL -- 
 -- DESCRIPTION: THIS SCRIPT RECREATES THE INDEXES ON dbo.STG_VALID_DATA_CLEANSE -- 
 -- NOTE : Created On 2-15-2018 4:18 PM by Louis Barrack -- 
 -- PARAMETERS : N/A -- 
 -- /*****************************************************************************/ 
 SET NOCOUNT ON ------------------------------------------------------------------------------- 
 -- Go Remove existing FKeys on dbo.STG_STG_VALID_DATA_CLEANSE. 
 ------------------------------------------------------------------------------- 
 -- Go Remove existing indexes on dbo.STG_VALID_DATA_CLEANSE. SET NOCOUNT ON 
 
 DECLARE @ROWID INT, 
 @MAX_ROWID INT, 
 @IDXNAME VARCHAR(256), 
 @TYPE INT, @BISPK INT, 
 @BISUNIQUE INT, 
 @SQL VARCHAR(MAX) 
 
 IF (OBJECT_ID('TEMPDB..#WKG_IDX') IS NOT NULL) 
 DROP TABLE #WKG_IDX 
 
 SELECT NAME AS IDX_NAME, TYPE, IS_PRIMARY_KEY, IS_UNIQUE_CONSTRAINT, IDENTITY (INT, 1, 1) AS ROWID INTO #WKG_IDX 
 
 FROM sys.indexes WHERE object_id = OBJECT_ID('dbo.STG_VALID_DATA_CLEANSE') ORDER BY TYPE DESC, NAME 
 
 SET @MAX_ROWID = @@ROWCOUNT 
 
 SET @ROWID = 1 
 WHILE (@ROWID <= @MAX_ROWID) 
 
 BEGIN 
 SELECT @IDXNAME = IDX_NAME, @TYPE = TYPE, @BISPK = IS_PRIMARY_KEY, @BISUNIQUE = IS_UNIQUE_CONSTRAINT 
 
 FROM #WKG_IDX 
 WHERE ROWID = @ROWID IF ((@BISPK = 1) or (@BISUNIQUE = 1)) 
 
 SET @SQL = 'ALTER TABLE dbo.STG_VALID_DATA_CLEANSE DROP CONSTRAINT ' + @IDXNAME 
 
 ELSE SET @SQL = 'DROP INDEX ' + @IDXNAME + ' ON dbo.STG_VALID_DATA_CLEANSE' 
 
 SELECT @SQL EXEC (@SQL) SET @ROWID = @ROWID + 1 
 
 END 
 
 ------------------------------------------------------------------------------- -- NOW ADD BACK IN THE INDEXES... 
 
 CREATE CLUSTERED INDEX STG_VALID_DATA_CLEANSE_DATATYPE 
 ON dbo.STG_VALID_DATA_CLEANSE (DATATYPE) 
 WITH (SORT_IN_TEMPDB = ON) 
 
 CREATE NONCLUSTERED INDEX STG_VALID_DATA_CLEANSE__VALID_DATA_CLEANSE_ID 
 ON dbo.STG_VALID_DATA_CLEANSE(VALID_DATA_CLEANSE_ID ASC) 
 WITH (SORT_IN_TEMPDB = ON) 
 ------------------------------------------------------------------------------- 
 -- Now go back in and add in FKeys ------------------------------------------------------------------------------- 
 
 GO 
 --------------------------------------------------------------------------------------------------------------------------------------Test Script 

USE AdventureWorks2012 

GO 

SELECT '#$$$T*$h!i@s ^#$$$T*$h!i@s ^*is aá ^^%%$$test & ™ ##0123456789¿' as STRINGInput, 
dbo.UFN_DATA_CLEANSE('#$$$T*$h!i@s ^*is aá ^^%%$$test & ™ ##0123456789¿','NAME') as NAMECleanUp, 
dbo.UFN_DATA_CLEANSE('#$$$T*$h!i@s ^*is a ^^%%$$test & ™ ##0123456789¿','EMPLOYERNAME') as EMPLOYERNAMECleanUp, 
dbo.UFN_DATA_CLEANSE('#$$$T*$h!i@s ^*is a ^^%%$$test & ™ ##0123456789¿','ADDRESS') as ADDRESSCleanUp, 
dbo.UFN_DATA_CLEANSE('#$$$T*$h!i@s ^*is a ^^%%$$test & ™ ##0123456789¿','PHONE') as PHONE, 
dbo.UFN_DATA_CLEANSE('#$$$T*$h!i@s ^*is a ^^%%$$@test & ™ ##0123456789¿','EMAIL') as EMAIL, 
dbo.UFN_DATA_CLEANSE('#$$$T*$h!i@s ^*is a ^^%%$$@test & ™ ##0123456789¿','ZIP') as ZIP 

GO 

------------------------------------------------------------------TEST Against ASCII Table 
DECLARE @ASCIITable TABLE        
(AsciiChar nvarchar(2), CharNum int) 
DECLARE @CNT INT 
SET @CNT = 1   
WHILE @CNT < 255 BEGIN        
INSERT INTO @ASCIITable        
SELECT CHAR(@CNT), @CNT        

SET @CNT = @CNT + 1 END   

SELECT 

AsciiChar, 
CharNum, 
dbo.UFN_DATA_CLEANSE([AsciiChar],'NAME') as NAMECleanUp, 
ASCII(dbo.UFN_DATA_CLEANSE([AsciiChar],'NAME')) as NAMEASCII, 
dbo.UFN_DATA_CLEANSE([AsciiChar],'EMPLOYERNAME') as EMPLOYERCleanUp, 
ASCII(dbo.UFN_DATA_CLEANSE([AsciiChar],'EMPLOYERNAME')) as EMPLOYERASCII, 
dbo.UFN_DATA_CLEANSE([AsciiChar],'ADDRESS') as ADDRESSCleanUp, 
ASCII(dbo.UFN_DATA_CLEANSE([AsciiChar],'ADDRESS')) as ADDRESSASCII, 
dbo.UFN_DATA_CLEANSE([AsciiChar],'EMAIL') as EMAILCleanUp, 
ASCII(dbo.UFN_DATA_CLEANSE([AsciiChar],'EMAIL')) as EMAILASCII, 
dbo.UFN_DATA_CLEANSE([AsciiChar],'PHONE') as PHONECleanUp, 
ASCII(dbo.UFN_DATA_CLEANSE([AsciiChar],'PHONE')) as PHONEASCII, 
dbo.UFN_DATA_CLEANSE([AsciiChar],'ZIP') as ZIPCleanUp, 
ASCII(dbo.UFN_DATA_CLEANSE([AsciiChar],'ZIP')) as ZIPASCII FROM @ASCIITable


