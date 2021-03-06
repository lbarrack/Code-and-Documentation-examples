USE [Apollo_Log]
GO
/****** Object:  StoredProcedure [dbo].[USP_Procedure_Step_Log_Template]    Script Date: 12/6/2017 2:52:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--IF (OBJECT_ID('[dbo].[USP_Procedure_Step_Log_Template]') IS NOT NULL)
--   DROP PROCEDURE [dbo].[USP_Procedure_Step_Log_Template] 
--GO


ALTER PROCEDURE [dbo].[USP_Procedure_Step_Log_Template]

/*****************************************************************************/
--
--
-- FILENAME   : USP_PROCEDURE_STEP_LOG_TEMPLATE.SQL
--
-- DESCRIPTION: THIS IS THE STORED PROCEDURE TEMPLATE SHOWING HOW TO ENABLE 
--                LOGGING WITHIN YOUR STORED PROCEDURE 
-- NOTE       : CHANGE THE PROCEDURE NAME BEFORE EXECUTING
-- PARAMETERS :      @ProcedureName   VARCHAR(100)         THE FULLY QUALIFIED STORED 
--                                                         PROCEDURE NAME
--                                                         (DATABASENAME.SCHEMA.STOREDPROCEDURENAME)
--	             @Variables       VARCHAR(150)         THE RUNTIME VARIABLES 
--	             @StepDesc        VARCHAR(100) = NULL  SUMMARY OF WHAT THE CURRENT PROCESS 
--                                                            IS DOING 
--	             @RowsAffected    INT = NULL           SET TO @@ROWCOUNT
--	             @ErrorLine       INT = NULL           SET TO @ERROR_LINE
--	             @ErrorMessage    VARCHAR(4000) = NULL SET TO @ERROR_MESSAGE
--	             @ErrorSQLCode    VARCHAR(500) = NULL  INCLUDE YOUR SQL CODE
--	             @AdditionalInfo  VARCHAR(500) = NULL  ANY HELPFUL INFO
--	             @RunID           INT                  CURRENT RUNID NUMBER
--	             @CreatedBy       VARCHAR(50)          PERSON WHO STARTED PROCESS
--	             @ApplicationID   SMALLINT             BATCHID NUMBER
--
-- EXAMPLE    : MAKE STORED PROCEDURE CALL TO APOLLO_LOG.DBO.USP_STEP_LOG AT THE
--                 BEGINNING, INSIDE A TRY CATCH WITH A NEW PROCESS AND AFTER THE 
--                 PROCESS IS COMPLETED FOR EVERY NEW PROCESS IN THE STORED PROCEDURE.

/* BEGIN
   SET NOCOUNT ON;

   DECLARE @ERROR_LINE INT
   DECLARE @ERROR_MSG VARCHAR(4000)
   
--------------------------------Step  1
---BEGINNING PROCESS
   EXEC Apollo_Log.dbo.USP_Step_Log
       @ProcedureName = 'APOLLO_NDM.dbo.USP_SOMEPROCEDURE' 
      ,@Variables = 'SomeVar = 234'
      ,@ApplicationId =234
      ,@RunID = 115 
      ,@StepDesc = 'Start Step 1 Pull 50,000 Records'
      ,@RowsAffected  = @@ROWCOUNT
      ,@AdditionalInfo = 'Est Runtime 2 hrs'
      ,@CreatedBy = 'Lbarrack'
      ;

---DURING PROCESS INSIDE TRY CATCH BLOCK
   BEGIN TRY
 
      SELECT 1/1;
   END TRY
   BEGIN CATCH

   SET @ERROR_LINE = ERROR_LINE()
   SET @ERROR_MSG =  ERROR_MESSAGE();

   EXEC Apollo_Log.dbo.USP_Step_Log
      @ProcedureName = 'APOLLO_NDM.dbo.USP_SOMEPROCEDURE'  
      ,@Variables = 'SomeVar = 234'
      ,@ErrorLine = @ERROR_LINE
      ,@ErrorMessage = @ERROR_MSG
      ,@ApplicationId =234
      ,@RunID = 115 
      ,@StepDesc = 'Start Step 1 Pull 50,000 Records'
      ,@RowsAffected= @@ROWCOUNT
      ,@CreatedBy = 'Lbarrack'
      ;
	 
   THROW;
   END CATCH
---PROCESS COMPLETE

    EXEC Apollo_Log.dbo.USP_Step_Log
      @ProcedureName = 'APOLLO_NDM.dbo.USP_SOMEPROCEDURE' 
      ,@Variables = 'SomeVar = 234'
      ,@ApplicationId =234
      ,@RunID = 115 
      ,@StepDesc = 'End Step 1'
      ,@RowsAffected = @@ROWCOUNT
      ,@AdditionalInfo = 'Row affected should be 10,000'
      ,@CreatedBy = 'Lbarrack'
      ;

-- --------------------------------Step 2 

---BEGIN NEXT PROCESS

=========================================================

-- These variables must have a value:
--
--	 @ProcedureName
--	 @Variables		  
--	 @CreatedBy    
--	 @ApplicationID      
--   @RunID
--
-- These variables are optional:
--	 @AdditionalInfo   
--	 @RowsAffected	 	
--	 @ErrorSQLCode	 	
--   @StepDesc
--
--  OUTPUTS TO APOLLO_LOG_DBO_PROCEDURESTEPLOG TABLE RECORDING
--      A TIMESTAMP FOR EACH PROCEDURE CALL THAT IS EXECUTED
--
--  HISTORY   :  12/04/2017  LMB  PBI 64651  LOGGING FOR STORED PROCEDURES
--
******************************************************************************/
----------------------------Stored Procedure Template -------------------------
AS
BEGIN
   SET NOCOUNT ON;

   DECLARE @ERROR_LINE INT
   DECLARE @ERROR_MSG VARCHAR(4000)

      
--------------------------------New Process Step  1
--START PROCESS LOGGING
   EXEC Apollo_Log.dbo.USP_Step_Log
       @ProcedureName = ' '  
      ,@Variables = ' '
      ,@StepDesc = ' '  
      ,@RowsAffected= @@ROWCOUNT
      ,@AdditionalInfo = ' '
      ,@RunID = 0
      ,@CreatedBy = ' '
      ,@ApplicationId = 0
      ;
	    
   BEGIN TRY
---------------------------------------------
      SELECT 'Put Code Here';---ENTER YOUR PROCESS CODE HERE
---------------------------------------------
   END TRY
   BEGIN CATCH
      SET @ERROR_LINE = ERROR_LINE()
      SET @ERROR_MSG =  ERROR_MESSAGE();

--CATCH ERROR LOGGING
   EXEC Apollo_Log.dbo.USP_Step_Log
       @ProcedureName = ' '  
      ,@Variables = ' '
      ,@ErrorLine = @ERROR_LINE
      ,@ErrorMessage = @ERROR_MSG
      ,@RowsAffected= @@ROWCOUNT
      ,@RunID = 0
      ,@CreatedBy = ' '
      ,@ApplicationId = 0
      ;
  
   THROW;
   END CATCH

--COMPLETION OF PROCESS LOGGING
   EXEC Apollo_Log.dbo.USP_Step_Log
      @ProcedureName = ' '  
      ,@Variables = ' '
      ,@StepDesc = ' '  
      ,@RowsAffected= @@ROWCOUNT
      ,@AdditionalInfo = ' '
      ,@RunID = 0
      ,@CreatedBy = ' '
      ,@ApplicationId = 0
      ;
--------------------------------New Process Step  2 
--START NEXT PROCESS LOGGING
   EXEC Apollo_Log.dbo.USP_Step_Log
      @ProcedureName = ' '  
      ,@Variables = ' '
      ,@StepDesc = ' '  
      ,@RowsAffected= @@ROWCOUNT
      ,@AdditionalInfo = ' '
      ,@RunID = 0
      ,@CreatedBy = ' '
      ,@ApplicationId = 0
      ;
	    
   BEGIN TRY
---------------------------------------------
      SELECT 'Put Code Here';---ENTER YOUR PROCESS CODE HERE
---------------------------------------------
   END TRY
   BEGIN CATCH
      SET @ERROR_LINE = ERROR_LINE()
      SET @ERROR_MSG =  ERROR_MESSAGE();

--CATCH ERROR LOGGING
   EXEC Apollo_Log.dbo.USP_Step_Log
      @ProcedureName = ' '  
      ,@Variables = ' '
      ,@ErrorLine = @ERROR_LINE
      ,@ErrorMessage = @ERROR_MSG
      ,@RowsAffected= @@ROWCOUNT
      ,@RunID = 0
      ,@CreatedBy = ' '
      ,@ApplicationId = 0
      ;
  
   THROW;
   END CATCH

--COMPLETION OF PROCESS LOGGING
   EXEC Apollo_Log.dbo.USP_Step_Log
      @ProcedureName = ' '  
      ,@Variables = ' '
      ,@StepDesc = ' '  
      ,@RowsAffected= @@ROWCOUNT
      ,@AdditionalInfo = ' '
      ,@RunID = 0
      ,@CreatedBy = ' '
      ,@ApplicationId = 0
      ;
---------------------------------Add as needed


END  

