

-------------------------------------------------------Create Table

USE [TDatabase]

GO

 

/****** Object:  Table [dbo].[STG_STAGE_XML]    Script Date: 12/20/2017 12:10:25 PM ******/

SET ANSI_NULLS ON

GO

 

SET QUOTED_IDENTIFIER ON

GO

 

SET ANSI_PADDING OFF

GO

 

CREATE TABLE [dbo].[STG_STAGE_XML](

              [AccountId] bigint NULL,

              [ACCOUNT_NUMBER] [bigint] NULL,

              [PREPURCHASE_CONSUMER_FIRST_NAME] [varchar](30) NULL,

              [PREPURCHASE_CONSUMER_MIDDLE_NAME] [varchar](30) NULL,

              [PREPURCHASE_CONSUMER_LAST_NAME] [varchar](30) NULL,

              [PREPURCHASE_CONSUMER_ADDRESS_LINE1] [varchar](30) NULL,

              [PREPURCHASE_CONSUMER_ADDRESS_LINE2] [varchar](30) NULL,

              [PREPURCHASE_CONSUMER_CITY] [varchar](30) NULL,

              [PREPURCHASE_CONSUMER_STATE] [varchar](2) NULL,

              [PREPURCHASE_CONSUMER_ZIP] [varchar](5) NULL,

              [SOURCE_OF_PREPURCHASE_INFO] [varchar](1) NULL,

              [LAST_PURCHASE_DATE] [date] NULL,

              [LAST_PURCHASE_AMOUNT] [decimal](9, 2) NULL,

              [LAST_BALANCE_TRANSFER_DATE] [date] NULL,

              [LAST_BALANCE_TRANSFER_AMOUNT] [decimal](9, 2) NULL,

              [LAST_CASH_ADVANCE_DATE] [date] NULL,

              [LAST_CASH_ADVANCE_AMOUNT] [decimal](9, 2) NULL,

              [CreatedOnDTTM] [datetime] NOT NULL,

              [RecordNo] [bigint] NULL,

              [GroupNo] [int] NULL

) ON [PRIMARY]

 

GO

 

SET ANSI_PADDING OFF

GO

 

 

 

 

-------------------------------------------------------------------------Load Table

 

use TDatabase

GO

DELETE FROM   [dbo].[STG_STAGE_XML]

 

GO 

 

declare @max int

 

set @max = 

 

    --5

 

    CONVERT(Int,(Select [PARAMETER_VALUE]

 

    FROM [ALog].[dbo].[DM_LG_APP_PARAMETER]

 

    WHERE  PARAMETER_TYPE = 'DM_IMPORT' AND PARAMETER_NAME = 'BDL_BATCH_SIZE'))

 

 

if (OBJECT_ID('tempdb..##tmpACCT_DMS') is not null)

   drop table ##tmpACCT_DMS

 

if (OBJECT_ID('tempdb..##tmp2ACCT_DMS') is not null)

   drop table ##tmp2ACCT_DMS

  

SELECT        

              

                                              AM.AccountId,

                                              ACCOUNT_NUMBER,

                                              PREPURCHASE_CONSUMER_FIRST_NAME,

                                              PREPURCHASE_CONSUMER_MIDDLE_NAME,

                                              PREPURCHASE_CONSUMER_LAST_NAME,

                                              PREPURCHASE_CONSUMER_ADDRESS_LINE1,

                                              PREPURCHASE_CONSUMER_ADDRESS_LINE2,

                                              PREPURCHASE_CONSUMER_CITY,

                                              PREPURCHASE_CONSUMER_STATE,

                                              PREPURCHASE_CONSUMER_ZIP,

                                              SOURCE_OF_PREPURCHASE_INFO,

                                              LAST_PURCHASE_DATE,

                                              LAST_PURCHASE_AMOUNT,

                                              LAST_BALANCE_TRANSFER_DATE,

                                              LAST_BALANCE_TRANSFER_AMOUNT,

                                              LAST_CASH_ADVANCE_DATE,

                                              LAST_CASH_ADVANCE_AMOUNT,

                                              GetDATE() as CreatedOnDTTM, 

                                 IDENTITY(int, 1, 1) as rowId

                                             

INTO ##tmpACCT_DMS

               

FROM dbo.APPPCONSINFO_LCO LEFT JOIN Apollo_NDM..ACCOUNTMATRIX AM

On CAST(ACCOUNT_NUMBER as varchar) = am.SPAcctNo and SPCode = 'R2K' 

 

WHERE AM.AccountId <> ''

 

 

 

 

; with cte as 

(

select *, cast((( rowId - 1 )/ @max) as int) as GroupNo

  from ##tmpACCT_DMS

)

 

 

 

INSERT INTO [dbo].[STG_STAGE_XML]

select

               

                                              AccountId,

                           ACCOUNT_NUMBER,

                                              PREPURCHASE_CONSUMER_FIRST_NAME,

                                              PREPURCHASE_CONSUMER_MIDDLE_NAME,

                                              PREPURCHASE_CONSUMER_LAST_NAME,

                                              PREPURCHASE_CONSUMER_ADDRESS_LINE1,

                                              PREPURCHASE_CONSUMER_ADDRESS_LINE2,

                                              PREPURCHASE_CONSUMER_CITY,

                                              PREPURCHASE_CONSUMER_STATE,

                                              PREPURCHASE_CONSUMER_ZIP,

                                              SOURCE_OF_PREPURCHASE_INFO,

                                              LAST_PURCHASE_DATE,

                                              LAST_PURCHASE_AMOUNT,

                                              LAST_BALANCE_TRANSFER_DATE,

                                              LAST_BALANCE_TRANSFER_AMOUNT,

                                              LAST_CASH_ADVANCE_DATE,

                                              LAST_CASH_ADVANCE_AMOUNT,

                                 CreatedOnDTTM,

                                              row_number() OVER (PARTITION BY GroupNo order by GroupNo, rowid) as RecordNo,

                                              GroupNo

 

               

FROM cte

Go

 

 

if (OBJECT_ID('tempdb..##tmpACCT_DMS') is not null)

   drop table ##tmpACCT_DMS

GO

 

if (OBJECT_ID('tempdb..##tmp2ACCT_DMS') is not null)

   drop table ##tmp2ACCT_DMS

GO

--------------------------------------------------------------------------xml in progress

 

DECLARE @Header VARCHAR(1000)

DECLARE @Footer VARCHAR(1000)

DECLARE @RECCOUNT VARCHAR (8)

DECLARE @BATCHID VARCHAR (8)

DECLARE @CreationDate varchar(100)

declare @offset varchar(10)

declare @MAXPERGROUP int

declare @GRECCOUNT int

declare @GROUPRECCOUNT int

DECLARE @CURRGROUPNO int

 

-------------------------------------------------------------SET @CURRGROUPNO = ?

SET @CURRGROUPNO = 0

 

--set @MAXPERGROUP =  CONVERT(Int,(Select [PARAMETER_VALUE]

 

--    FROM [ALog].[dbo].[DM_LG_APP_PARAMETER]

 

--    WHERE  PARAMETER_TYPE = 'DM_IMPORT' AND PARAMETER_NAME = 'BDL_BATCH_SIZE'))

 

 

 

 

SET @GRECCOUNT = (select count(*)

 

FROM [TDatabase].[dbo].[STG_STAGE_XML]

 

Where GroupNo = @CURRGROUPNO)

 

SET @GROUPRECCOUNT = (select Case When @GRECCOUNT< @MAXPERGROUP THEN @RECCOUNT

                                                                                      ELSE @MAXPERGROUP END)

 

 

set @offset = (select right(cast(SYSDATETIMEOFFSET() as varchar(100)), 6))

 

 

SET @BATCHID = 0

SET @RECCOUNT = 120

SET @CreationDate = (select convert(varchar(100), SYSDATETIMEOFFSET(), 126))

 

 

 

SET @Header='

 

<dm_data xmlns="http://www.fico.com/xml/debtmanager/data/v1_0">;

 

 

<header>

 

<sender_id_txt/>

 

<target_id_txt>0</target_id_txt>

 

<batch_id_txt>' + CONVERT(Varchar(4),@CURRGROUPNO) + '</batch_id_txt>

 

<operational_transaction_type>CONSUMER</operational_transaction_type>

 

<total_count>' +CONVERT(Varchar(4), @GRECCOUNT) + '</total_count>

 

<creation_data>' + @CreationDate + '</creation_data>

 

</header>

<operational_transaction_data>

'

 

SET @Footer='

</operational_transaction_data>

</dm_data>'

 

SELECT

--------------------------------------------('<?xml version="1.0" encoding="UTF-8"?>' + char(10)) +

      --------------------------------------- cast((

                 CAST(@Header+

 

 

 

(SELECT --[MSACT#] as msa

       RecordNo as "@seq_no" ,

                 'UDEFALL_CONSUMER_ADDRESS' as "@type",

                

 

       [ACCOUNT_NUMBER]

      ,[PREPURCHASE_CONSUMER_FIRST_NAME] as UDEFCHG_OFF_CNSMR_FN

      --,[PREPURCHASE_CONSUMER_MIDDLE_NAME]

                ,[PREPURCHASE_CONSUMER_LAST_NAME] as UDEFCHG_OFF_CNSMR_LN

      ,[PREPURCHASE_CONSUMER_ADDRESS_LINE1] as UDEFCHG_OFF_CNSMR_ST

      ,[PREPURCHASE_CONSUMER_ADDRESS_LINE2] as UDEFCHG_OFF_CNSMR_STREET2

      ,[PREPURCHASE_CONSUMER_CITY] as UDEFCHG_OFF_CNSMR_CITY

      ,[PREPURCHASE_CONSUMER_STATE] as UDEFCHG_OFF_CNSMR_ST

      ,[PREPURCHASE_CONSUMER_ZIP] as UDEFCHG_OFF_CNSMR_ZIP

      ,[SOURCE_OF_PREPURCHASE_INFO] as UDEFCHG_OFF_CNSMR_SOURCE

     -- ,[LAST_PURCHASE_DATE]

      ,[LAST_PURCHASE_AMOUNT]

      ,[LAST_BALANCE_TRANSFER_DATE]

      ,[LAST_BALANCE_TRANSFER_AMOUNT]

      ,[LAST_CASH_ADVANCE_DATE]

      ,[LAST_CASH_ADVANCE_AMOUNT]

      ,[CreatedOnDTTM]

      ,[RecordNo]

    

 

  FROM [TDatabase].[dbo].[STG_STAGE_XML]

  WHERE  GroupNo = @CURRGROUPNO

  Order By [RecordNo]

  for xml

  Path ('cnsmr_upd') ,Root('Something'))+@Footer AS XML)

---------------------------------------------------------------------------------------------------------XML

if (object_id('tempdb..##tmp') is not null )

   drop table ##tmp

 

if (OBJECT_ID('tempdb..##tmp2') is not null)

   drop table ##tmp2

 

 

DECLARE @Header          VARCHAR(1000)

DECLARE @Footer          VARCHAR(1000)

DECLARE @RECCOUNT        VARCHAR (8)

DECLARE @BATCHID         VARCHAR (8)

DECLARE @CreationDate    varchar(100)

declare @offset          varchar(10)

declare @MAXPERGROUP     int

declare @GRECCOUNT       int

declare @GROUPRECCOUNT   int

DECLARE @CURRGROUPNO     int

 

SET @CURRGROUPNO = 0

 

set @MAXPERGROUP =  CONVERT(Int,(SELECT [PARAMETER_VALUE]

                                   FROM [ALog].[dbo].[DM_LG_APP_PARAMETER]

                                  WHERE PARAMETER_TYPE = 'DM_IMPORT'

                                    AND PARAMETER_NAME = 'BDL_BATCH_SIZE'))

 

SET @GRECCOUNT = (

                  select count(*)

                     FROM STG_STAGE_XML

                                                                        WHERE GroupNo = @CURRGROUPNO

                 )

 

 

                          

SET @GROUPRECCOUNT = (

                      select Case

                                When (@GRECCOUNT< @MAXPERGROUP)

                                   THEN @RECCOUNT

                                ELSE

                                   @MAXPERGROUP

                             END

                     )

 

 

set @offset = (select right(cast(SYSDATETIMEOFFSET() as varchar(100)), 6))

 

 

SET @BATCHID = 0

SET @RECCOUNT = 120

SET @CreationDate = (select convert(varchar(100), SYSDATETIMEOFFSET(), 126))

 

SET @Header='

 

<dm_data xmlns="http://www.fico.com/xml/debtmanager/data/v1_0">;

<header>

<sender_id_txt/>

<target_id_txt>0</target_id_txt>

<batch_id_txt>' + CONVERT(Varchar(20),@CURRGROUPNO) + '</batch_id_txt>

<operational_transaction_type>CONSUMERACCOUNT</operational_transaction_type>

<total_count>' +CONVERT(Varchar(20), @GRECCOUNT) + '</total_count>

<creation_data>' + @CreationDate + '</creation_data>

</header>

<operational_transaction_data>

'

 

SET @Footer='

</operational_transaction_data>

</dm_data>'

 

 

 

 

select ACCOUNT_NUMBER, AccountId AS 'cnsmr_accnt_idntfr_agncy_id' 

                           ,RecordNo as rowId   

                 into ##tmp2

                     FROM [TDatabase].[dbo].STG_STAGE_XML A

                                                                         WHERE GroupNo = @CURRGROUPNO

  

  

 

 

;

 

with RCMAST_cte as

(

 

(

  select ACCOUNT_NUMBER

       , 'text_type' as [type]

       , 'UDEFCHG_OFF_CNSMR_FN' as [name]

       , cast(PREPURCHASE_CONSUMER_FIRST_NAME as varchar(max)) as [value]

       , 1 as seq

    from [TDatabase].[dbo].[STG_STAGE_XML]

              WHERE GroupNo = @CURRGROUPNO

)

 

union

(

  select ACCOUNT_NUMBER

       , 'text_type' as [type]

       , 'UDEFCHG_OFF_CNSMR_LN' as [name]

       , cast(PREPURCHASE_CONSUMER_LAST_NAME as varchar(max)) as [value]

       , 2 as seq

    from [TDatabase].[dbo].[STG_STAGE_XML]

              WHERE GroupNo = @CURRGROUPNO

)

union

(

  select ACCOUNT_NUMBER

       , 'text_type' as [type]

       , 'UDEFCHG_OFF_CNSMR_STREET' as [name]

       , cast([PREPURCHASE_CONSUMER_ADDRESS_LINE1] as varchar(max)) as [value]

       , 3 as seq

    from [TDatabase].[dbo].[STG_STAGE_XML]

              WHERE GroupNo = @CURRGROUPNO

)

 

union

(

  select ACCOUNT_NUMBER

       , 'text_type' as [type]

       , 'UDEFCHG_OFF_CNSMR_STREET2' as [name]

       , cast([PREPURCHASE_CONSUMER_ADDRESS_LINE2] as varchar(max)) as [value]

       , 4 as seq

    from [TDatabase].[dbo].[STG_STAGE_XML]

    WHERE PREPURCHASE_CONSUMER_ADDRESS_LINE2 is Not Null

              AND GroupNo = @CURRGROUPNO

)

union

(

  select ACCOUNT_NUMBER

       , 'text_type' as [type]

       , 'UDEFCHG_OFF_CNSMR_CITY' as [name]

       , cast([PREPURCHASE_CONSUMER_CITY] as varchar(max)) as [value]

       , 5 as seq

    from [TDatabase].[dbo].[STG_STAGE_XML]

              WHERE GroupNo = @CURRGROUPNO

)

union

(

  select ACCOUNT_NUMBER

       , 'text_type' as [type]

       , 'UDEFCHG_OFF_CNSMR_ST' as [name]

       , cast([PREPURCHASE_CONSUMER_STATE] as varchar(max)) as [value]

       , 6 as seq

    from [TDatabase].[dbo].[STG_STAGE_XML]

              WHERE GroupNo = @CURRGROUPNO

)

union

(

  select ACCOUNT_NUMBER

       , 'text_type' as [type]

       , 'UDEFCHG_OFF_CNSMR_ZIP' as [name]

       , cast([PREPURCHASE_CONSUMER_ZIP] as varchar(max)) as [value]

       , 7 as seq

    from [TDatabase].[dbo].[STG_STAGE_XML]

              WHERE GroupNo = @CURRGROUPNO

)

union

(

  select ACCOUNT_NUMBER

       , 'text_type' as [type]

       , 'UDEFCHG_OFF_CNSMR_SOURCE' as [name]

       , cast([SOURCE_OF_PREPURCHASE_INFO] as varchar(max)) as [value]

       , 8 as seq

    from [TDatabase].[dbo].[STG_STAGE_XML]

              WHERE GroupNo = @CURRGROUPNO

)

)

select * into ##tmp from RCMAST_cte;

 

WITH XMLNAMESPACES ('http://www.w3.org/2001/XMLSchema-instance' as xsi)

 

---------------------------------------for varchar with encoding in header

SELECT

('<?xml version="1.0" encoding="UTF-8"?>' + char(10)) +

      cast((

-------------------------------------------------------------------------

SELECT (CAST(@Header+(SELECT 

              'UDEFCHG_OFF_CNSMR' AS "@type", rowId as "@seq_no"

              ,cnsmr_accnt_idntfr_agncy_id AS 'cnsmr_accnt_idntfr_agncy_id'

              ,(

                select [type] as "@xsi:type", [name] as "@name",

                                  [value] as "value"

                  from ##tmp

                 where ##tmp.ACCOUNT_NUMBER = ##tmp2.ACCOUNT_NUMBER

                 order by seq

                   FOR XML PATH('udp_field'), TYPE

               ) as 'udp_fields'

          

  FROM ##tmp2

       FOR XML PATH('cnsmr_accnt_udp'), ROOT('account_operational_transaction_data'))+@Footer AS XML))

 

                   )  as varchar(max)) -----------------FOR Varchar with encoding

---------------------------------------------------------------------------------------FlatFile destinantion

 

 

"\\internal.mcmcg.com\\shares\\Applications\\Apollo\\Dev\\DM-SRC\\TitaniumFS\\BDL\\import\\staging\\" + @[User::XMLFileName]

 

------------------------------------------------------------------------------------------------------------------

 

USE [TDatabase]

GO

/****** Object:  StoredProcedure [dbo].[USP_PPCONSINFO_BUILDXML]    Script Date: 12/27/2017 9:24:23 AM ******/

SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

 

SET NOCOUNT ON

GO

 

 

IF (OBJECT_ID('[dbo].[USP_PPCONSINFO_BUILDXML]') IS NOT NULL)

DROP PROCEDURE [dbo].[USP_PPCONSINFO_BUILDXML]

GO

 

 

CREATE PROCEDURE [dbo].[USP_PPCONSINFO_BUILDXML]

 

@CURRGROUPNO     int

 

AS

 

 

 

 

if (object_id('tempdb..##tmp') is not null )

   drop table ##tmp

 

if (OBJECT_ID('tempdb..##tmp2') is not null)

   drop table ##tmp2

 

 

DECLARE @Header          VARCHAR(1000)

DECLARE @Footer          VARCHAR(1000)

DECLARE @RECCOUNT        VARCHAR (8)

DECLARE @BATCHID         VARCHAR (8)

DECLARE @CreationDate    varchar(100)

declare @offset          varchar(10)

declare @MAXPERGROUP     int

declare @GRECCOUNT       int

declare @GROUPRECCOUNT   int

 

 

 

 

set @MAXPERGROUP =  CONVERT(Int,(SELECT [PARAMETER_VALUE]

                                   FROM [ALog].[dbo].[DM_LG_APP_PARAMETER]

                                  WHERE PARAMETER_TYPE = 'DM_IMPORT'

                                    AND PARAMETER_NAME = 'BDL_BATCH_SIZE'))

 

SET @GRECCOUNT = (

                  select count(*)

                     FROM STG_STAGE_XML

                                                                        WHERE GroupNo = @CURRGROUPNO

                 )

 

 

                          

SET @GROUPRECCOUNT = (

                      select Case

                                When (@GRECCOUNT< @MAXPERGROUP)

                                   THEN @RECCOUNT

                                ELSE

                                   @MAXPERGROUP

                             END

                     )

 

 

set @offset = (select right(cast(SYSDATETIMEOFFSET() as varchar(100)), 6))

 

 

SET @BATCHID = 0

SET @RECCOUNT = 120

SET @CreationDate = (select convert(varchar(100), SYSDATETIMEOFFSET(), 126))

 

SET @Header='

 

<dm_data xmlns="http://www.fico.com/xml/debtmanager/data/v1_0">;

<header>

<sender_id_txt/>

<target_id_txt>0</target_id_txt>

<batch_id_txt>' + CONVERT(Varchar(20),@CURRGROUPNO) + '</batch_id_txt>

<operational_transaction_type>CONSUMERACCOUNT</operational_transaction_type>

<total_count>' +CONVERT(Varchar(20), @GRECCOUNT) + '</total_count>

<creation_data>' + @CreationDate + '</creation_data>

</header>

<operational_transaction_data>

'

 

SET @Footer='

</operational_transaction_data>

</dm_data>'

 

 

 

 

select ACCOUNT_NUMBER, AccountId AS 'cnsmr_accnt_idntfr_agncy_id' 

                           ,RecordNo as rowId   

                 into ##tmp2

                     FROM [TDatabase].[dbo].STG_STAGE_XML A

                                                                         WHERE GroupNo = @CURRGROUPNO

  

  

 

 

;

 

with RCMAST_cte as

(

 

(

  select ACCOUNT_NUMBER

       , 'text_type' as [type]

       , 'UDEFCHG_OFF_CNSMR_FN' as [name]

       , cast(PREPURCHASE_CONSUMER_FIRST_NAME as varchar(max)) as [value]

       , 1 as seq

    from [TDatabase].[dbo].[STG_STAGE_XML]

              WHERE GroupNo = @CURRGROUPNO

)

 

union

(

  select ACCOUNT_NUMBER

       , 'text_type' as [type]

       , 'UDEFCHG_OFF_CNSMR_LN' as [name]

       , cast(PREPURCHASE_CONSUMER_LAST_NAME as varchar(max)) as [value]

       , 2 as seq

    from [TDatabase].[dbo].[STG_STAGE_XML]

              WHERE GroupNo = @CURRGROUPNO

)

union

(

  select ACCOUNT_NUMBER

       , 'text_type' as [type]

       , 'UDEFCHG_OFF_CNSMR_STREET' as [name]

       , cast([PREPURCHASE_CONSUMER_ADDRESS_LINE1] as varchar(max)) as [value]

       , 3 as seq

    from [TDatabase].[dbo].[STG_STAGE_XML]

              WHERE GroupNo = @CURRGROUPNO

)

 

union

(

  select ACCOUNT_NUMBER

       , 'text_type' as [type]

       , 'UDEFCHG_OFF_CNSMR_STREET2' as [name]

       , cast([PREPURCHASE_CONSUMER_ADDRESS_LINE2] as varchar(max)) as [value]

       , 4 as seq

    from [TDatabase].[dbo].[STG_STAGE_XML]

    WHERE PREPURCHASE_CONSUMER_ADDRESS_LINE2 is Not Null

              AND GroupNo = @CURRGROUPNO

)

union

(

  select ACCOUNT_NUMBER

       , 'text_type' as [type]

       , 'UDEFCHG_OFF_CNSMR_CITY' as [name]

       , cast([PREPURCHASE_CONSUMER_CITY] as varchar(max)) as [value]

       , 5 as seq

    from [TDatabase].[dbo].[STG_STAGE_XML]

              WHERE GroupNo = @CURRGROUPNO

)

union

(

  select ACCOUNT_NUMBER

       , 'text_type' as [type]

       , 'UDEFCHG_OFF_CNSMR_ST' as [name]

       , cast([PREPURCHASE_CONSUMER_STATE] as varchar(max)) as [value]

       , 6 as seq

    from [TDatabase].[dbo].[STG_STAGE_XML]

              WHERE GroupNo = @CURRGROUPNO

)

union

(

  select ACCOUNT_NUMBER

       , 'text_type' as [type]

       , 'UDEFCHG_OFF_CNSMR_ZIP' as [name]

       , cast([PREPURCHASE_CONSUMER_ZIP] as varchar(max)) as [value]

       , 7 as seq

    from [TDatabase].[dbo].[STG_STAGE_XML]

              WHERE GroupNo = @CURRGROUPNO

)

union

(

  select ACCOUNT_NUMBER

       , 'text_type' as [type]

       , 'UDEFCHG_OFF_CNSMR_SOURCE' as [name]

       , cast([SOURCE_OF_PREPURCHASE_INFO] as varchar(max)) as [value]

       , 8 as seq

    from [TDatabase].[dbo].[STG_STAGE_XML]

              WHERE GroupNo = @CURRGROUPNO

)

)

select * into ##tmp from RCMAST_cte;

 

WITH XMLNAMESPACES ('http://www.w3.org/2001/XMLSchema-instance' as xsi)

 

---------------------------------------for varchar with encoding in header

SELECT

('<?xml version="1.0" encoding="UTF-8"?>' + char(10)) +

      cast((

-------------------------------------------------------------------------

SELECT (CAST(@Header+(SELECT 

              'UDEFCHG_OFF_CNSMR' AS "@type", rowId as "@seq_no"

              ,cnsmr_accnt_idntfr_agncy_id AS 'cnsmr_accnt_idntfr_agncy_id'

              ,(

                select [type] as "@xsi:type", [name] as "@name",

                                  [value] as "value"

                  from ##tmp

                 where ##tmp.ACCOUNT_NUMBER = ##tmp2.ACCOUNT_NUMBER

                 order by seq

                   FOR XML PATH('udp_field'), TYPE

               ) as 'udp_fields'

          

  FROM ##tmp2

       FOR XML PATH('cnsmr_accnt_udp'), ROOT('account_operational_transaction_data'))+@Footer AS XML))

 

                   )  as varchar(max)) AS COL1