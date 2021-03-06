USE [Apollo_Log]
GO
/****** Object:  StoredProcedure [dbo].[USP_Step_Log]    Script Date: 11/27/2017 9:24:23 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--IF (OBJECT_ID('[dbo].[USP_Step_Log]') IS NOT NULL)
--   DROP PROCEDURE [dbo].[USP_Step_Log] 
--GO


CREATE PROCEDURE [dbo].[USP_Step_Log]

  @ProcedureName   VARCHAR(100)
 ,@Variables       VARCHAR(150)
 ,@StepDesc        VARCHAR(100) = NULL
 ,@RowsAffected    INT = NULL
 ,@ErrorLine       INT = NULL
 ,@ErrorMessage    VARCHAR(4000) = NULL
 ,@ErrorSQLCode    VARCHAR(500) = NULL
 ,@AdditionalInfo  VARCHAR(500) = NULL
 ,@RunID           INT 
 ,@CreatedBy       VARCHAR(50)
 ,@ApplicationID   SMALLINT
 

/****** Object:  StoredProcedure [dbo].[USP_Step_Log]    Script Date: 11/22/2017 1:16:54 PM ******/
--
-- FILENAME   :  USP_Step_Log.SQL
--
-- DESCRIPTION: THIS IS THE STORED PROCEDURE USED TO LOG STORED PROCEDURE EVENTS 
--                SEE USP_PROCEDURE_STEP_LOG_TEMPLATE FOR INSTRUCTIONS 
-- NOTE       : 
-- PARAMETERS : @ProcedureName   VARCHAR(100)             THE FULLY QUALIFIED STORED 
--                                                         PROCEDURE NAME
--                                                        (DATABASENAME.STOREDPROCEDURENAME)
--                  @Variables       VARCHAR(150)         THE RUNTIME VARIABLES 
--	            @StepDesc        VARCHAR(100) = NULL  IDENTIFIES RUNNING PROCESS
--	            @RowsAffected    INT = NULL           SET TO @@ROWCOUNT
--	            @ErrorLine       INT = NULL           SET TO @ERROR_LINE
--	            @ErrorMessage    VARCHAR(4000) = NULL SET TO @ERROR_MESSAGE
--	            @ErrorSQLCode    VARCHAR(500) = NULL  INCLUDE YOUR SQL CODE
--	            @AdditionalInfo  VARCHAR(500) = NULL  ANY HELPFUL INFO
--	            @RunID           INT                  CURRENT RUNID NUMBER
--	            @CreatedBy       VARCHAR(50)          PERSON WHO STARTED PROCESS
--	            @ApplicationID   SMALLINT             BATCHID NUMBER
--
-- EXAMPLE    : MAKE STORED PROCEDURE CALL TO APOLLO_LOG.DBO.USP_STEP_LOG AT THE
--                 BEGINNING, INSIDE A TRY CATCH WITH A NEW PROCESS AND AFTER THE 
--                 PROCESS IS COMPLETED FOR EVERY NEW PROCESS IN THE STORED PROCEDURE.
--                 SEE USP_PROCEDURE_STEP_LOG_TEMPLATE FOR INSTRUCTIONS
--
-- OUTPUTS TO : APOLLO_LOG_DBO_PROCEDURESTEPLOG TABLE RECORDING
--               A TIMESTAMP FOR EACH PROCEDURE CALL THAT IS EXECUTED
--
--  HISTORY   :  11/21/2017  LMB  PBI 64651  LOGGING FOR STORED PROCEDURE
/******************************************************************************/


 
 
 
AS
BEGIN
   SET NOCOUNT ON;
  
   
   INSERT Apollo_Log.dbo.PROCEDURESTEPLOG
      (
       ProcedureName
      ,Variables
      ,StepDesc
      ,RowsAffected
      ,ErrorLine
      ,ErrorMessage
      ,ErrSQLCode
      ,AdditionalInfo
      ,RunID
      ,CreatedBy         
      ,ApplicationID
      )

   SELECT

      @ProcedureName    
     ,@Variables                        
     ,@StepDesc        
     ,@RowsAffected    
     ,@ErrorLine       
     ,@ErrorMessage        
     ,@ErrorSQLCode
     ,@AdditionalInfo
     ,@RunID  
     ,@CreatedBy
     ,@ApplicationID         
     ;

END

GO

GRANT EXECUTE ON APOLLO_Log.dbo.USP_Step_Log To public;

GO