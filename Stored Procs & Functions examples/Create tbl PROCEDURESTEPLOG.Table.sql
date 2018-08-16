USE [Apollo_Log]
GO

/****** Object:  Table [dbo].[PROCEDURESTEPLOG]    Script Date: 11/27/2017 9:29:40 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

IF (OBJECT_ID('dbo.PROCEDURESTEPLOG') IS NOT NULL)
   DROP TABLE dbo.PROCEDURESTEPLOG 
GO

CREATE TABLE dbo.PROCEDURESTEPLOG(
	 ProcedureStepLogId   BIGINT IDENTITY(1,1) NOT NULL
	,ProcedureName        VARCHAR(100) NOT NULL
	,Variables            VARCHAR(150) NULL
	,SQLCMD  AS (((('EXEC'+' ')+ProcedureName)+' ')+Variables)
	,StepDesc             VARCHAR(100) NULL
	,RowsAffected         INT          NULL
	,ErrorLine            VARCHAR(15)  NULL
	,ErrorMessage         VARCHAR(4000)NULL
	,ErrSQLCode           VARCHAR(500) NULL
	,AdditionalInfo       VARCHAR(500) NULL
	,RunID                BIGINT       NULL
	,CreatedBy            VARCHAR(50)  NOT NULL
	,ApplicationId        SMALLINT     NOT NULL
    ,CreatedOnDTTM        DATETIME     NOT NULL CONSTRAINT df_PROCEDURESTEPLOG_CreatedOnDTTM   DEFAULT (GETDATE())
)
GO

SET ANSI_PADDING OFF
GO


