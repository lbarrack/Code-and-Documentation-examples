USE Apollo_Log
GO

SELECT @@SERVERNAME
GO

/*****************************************************************************/
--
-- FILENAME   : PROCEDURESTEPLOG IDX.SQL
--
-- DESCRIPTION: THIS SCRIPT RECREATES THE INDEXES ON dbo.PROCEDURESTEPLOG
--
-- NOTE       : 
--
-- PARAMETERS :  N/A
--
--
/*****************************************************************************/

SET NOCOUNT ON

-------------------------------------------------------------------------------
-- Go Remove existing FKeys on dbo.PROCEDURESTEPLOG.

-------------------------------------------------------------------------------
-- Go Remove existing indexes on dbo.PROCEDURESTEPLOG.

SET NOCOUNT ON 

DECLARE @ROWID     INT,
        @MAX_ROWID INT,
        @IDXNAME   VARCHAR(256),
        @TYPE      INT,
        @BISPK     INT,
        @BISUNIQUE INT,
        @SQL       VARCHAR(MAX)

IF (OBJECT_ID('TEMPDB..#WKG_IDX') IS NOT NULL)
   DROP TABLE #WKG_IDX

SELECT NAME AS IDX_NAME, 
       TYPE,
       IS_PRIMARY_KEY,
       IS_UNIQUE_CONSTRAINT,
       IDENTITY (INT, 1, 1) AS ROWID
  INTO #WKG_IDX
-- SELECT *
  FROM sys.indexes 
 WHERE object_id = OBJECT_ID('dbo.PROCEDURESTEPLOG') 
 ORDER BY TYPE DESC, NAME

SET @MAX_ROWID = @@ROWCOUNT
SET @ROWID = 1

WHILE (@ROWID <= @MAX_ROWID)
BEGIN

   SELECT @IDXNAME   = IDX_NAME,
          @TYPE      = TYPE,
          @BISPK     = IS_PRIMARY_KEY,
          @BISUNIQUE = IS_UNIQUE_CONSTRAINT
     FROM #WKG_IDX
    WHERE ROWID = @ROWID

   IF ((@BISPK = 1) or
       (@BISUNIQUE = 1))
       SET @SQL = 'ALTER TABLE dbo.PROCEDURESTEPLOG DROP CONSTRAINT ' + @IDXNAME
   ELSE
      SET @SQL = 'DROP INDEX ' + @IDXNAME + ' ON dbo.PROCEDURESTEPLOG'

   SELECT @SQL
   EXEC (@SQL)

   SET @ROWID = @ROWID + 1
END

-------------------------------------------------------------------------------
-- NOW ADD BACK IN THE INDEXES...

ALTER TABLE dbo.PROCEDURESTEPLOG
  ADD CONSTRAINT PROCEDURESTEPLOG_ProcedureStepLogId
      PRIMARY KEY CLUSTERED (ProcedureStepLogId)
	  
	  
CREATE NONCLUSTERED INDEX ProcedureStepLog_CreatedOnDTTM
    ON dbo.ProcedureStepLog(CreatedOnDTTM)
	WITH (SORT_IN_TEMPDB = ON)


CREATE NONCLUSTERED INDEX ProcedureStepLog_RunID
    ON dbo.ProcedureStepLog(RunID)
	WITH (SORT_IN_TEMPDB = ON)



-------------------------------------------------------------------------------
-- Now go back in and add in FKeys
  
-------------------------------------------------------------------------------
GO
