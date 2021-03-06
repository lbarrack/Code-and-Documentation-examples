USE [Runtime]
GO
/****** Object:  StoredProcedure [dbo].[ProcessCIP4ReportResultsSummary]    Script Date: 05/09/2013 12:12:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
ALTER Procedure [dbo].[ProcessCIP4ReportResultsSummary]   
  
As
  declare @BatchRunIndex varchar(100);
  declare @SQLQueryString nvarchar(2000);
  declare @BatchStartDateTime datetime2(7);
  declare @BatchEndDateTime datetime2(7);
  declare @BatchNumberString varchar(50);
  declare @RunNumber bigint;
  declare @ReportStatusMessage nvarchar(500);
  declare @SolutionStartDateTime datetime2(7);
  declare @SolutionEndDateTime datetime2(7);  
  declare @SolutionCount bigint;  
  declare @SolutionNumber bigint;
  declare @SolutionNumberPrev bigint;
  declare @SolutionName varchar(50);
  declare @SolutionStartedButNotYetEnded binary;
  declare @StepTimeInMinutes real;
  declare @SupplyTemperature real;
  declare @SupplyConductivity real;
  declare @DateTime datetime2(7);
    
  declare @SolutionTemporaryTableVariable Table (iSolutionCount bigint, dtSolutionStartDateTime datetime2(7), dtSolutionEndDateTime datetime2(7), sSolutionName varchar(82), rStepTime real, rSupplyTemperature real, rSupplyConductivity real)
    
  SET NOCOUNT ON
    
  SET @BatchRunIndex = (Select CIP4Report From ProcessReportUserParameters Where HostName = HOST_NAME() AND UserID = SUSER_SNAME());

  SET @BatchNumberString = (Select sBatchNumberString From ProcessReportingBatchRunLookup Where sBatchRunIndex = @BatchRunIndex);
  SET @RunNumber = (Select iRunNumber From ProcessReportingBatchRunLookup Where sBatchRunIndex = @BatchRunIndex);
  SET @BatchStartDateTime = (Select dtBatchStartDateTime From ProcessReportingBatchRunLookup Where sBatchRunIndex = @BatchRunIndex);
  SET @BatchEndDateTime = (Select dtBatchEndDateTime From ProcessReportingBatchRunLookup Where sBatchRunIndex = @BatchRunIndex);

  SET @ReportStatusMessage = '';  
  
  /* Initialize The Variables Before Stepping Through The Loop */
  SET @SolutionNumber = 0;
  SET @SolutionNumberPrev = 0;
  SET @SolutionCount = 0;
  SET @SolutionStartedButNotYetEnded = 0;
  
  DECLARE Batch_Cursor CURSOR For  
  SELECT DateTime, Value
  FROM History 
  WHERE TagName = 'cskdSeqeNu'
  AND DateTime >= Cast(@BatchStartDateTime As varchar(30)) 
  AND DateTime <= Cast(@BatchEndDateTime As varchar(30)) 
  AND vValue IS NOT NULL 
  AND wwRetrievalMode = 'Delta'

  OPEN Batch_Cursor
  FETCH NEXT FROM Batch_Cursor
  INTO @DateTime, @SolutionNumber

  WHILE @@FETCH_STATUS = 0
  BEGIN
    /* Detect A Change In The Solution Number
    It Changes From 0 To A Nonzero Value At The Beginning Of A Batch
    And It Changes To Other Numbers With Each Solution Change.  It 
    Is Potentially Possible For The Value To Go To 0 Between Solutions
    And It Is Also Possible For The Sam Solution To Be Used At Different Time In The Batch.*/
    IF (@SolutionNumber <> @SolutionNumberPrev)
      BEGIN
        /* When A Change In Solution Occurs Count That As Either A Start Of One Solution Or The Stop Of Previous Solution Or Both. */
        
        IF (@SolutionNumber > 0)
          BEGIN
            /* If The Previous Solution Number Was Not 0 Then The
            Solution Number Changed Without Going To A 0 Value Between Solutions,
            Therefore The End Timestamp Of The Previous Batch Must Be Captured.  This Must 
            Be Done Before Incrementing The Solution Counter To Make Sure Every Thing Works Right. */
            IF (@SolutionNumberPrev > 0)
              BEGIN
                SET @SolutionEndDateTime = @DateTime;            

				SET @StepTimeInMinutes = DATEDIFF(mi, @SolutionStartDateTime, @SolutionEndDateTime);

				SET @SupplyTemperature = (SELECT AVG(Value) FROM History WHERE TagName = 'TT_007\OutEngFltr' AND DateTime >= Cast(@SolutionStartDateTime As varchar(30)) AND DateTime <= Cast(@SolutionEndDateTime As varchar(30)) AND wwRetrievalMode = 'CYCLIC' AND wwResolution = 1000);
				SET @SupplyConductivity = (SELECT AVG(Value) FROM History WHERE TagName = 'CIT_113\OutEngFltr' AND DateTime >= Cast(@SolutionStartDateTime As varchar(30)) AND DateTime <= Cast(@SolutionEndDateTime As varchar(30)) AND wwRetrievalMode = 'CYCLIC' AND wwResolution = 1000);				

				SET @SolutionName = (Select sSolutionName From ProcessCIPSolutionNumberLookup Where iSolutionNumber = @SolutionNumberPrev);

                Insert Into @SolutionTemporaryTableVariable 
                Values(@SolutionCount ,@SolutionStartDateTime, @SolutionEndDateTime, @SolutionName, @StepTimeInMinutes, @SupplyTemperature, @SupplyConductivity);
                
                SET @SolutionStartedButNotYetEnded = 0;
              END          

            /* This Is The Record For This SOlution */
            SET @SolutionCount = @SolutionCount + 1;
            
            /* Update Temporary Table Variable With The Solution's Start Times */
            SET @SolutionStartDateTime = @DateTime;
            
            SET @SolutionStartedButNotYetEnded = 1;
 
          END
          
        IF @SolutionNumber = 0
          BEGIN
            /* Make Sure At Least 1 Valid Solution Has Been Seen Before Writing To The Temporary Table */
            IF @SolutionCount > 0
              BEGIN
                SET @SolutionEndDateTime = @DateTime;            

				SET @StepTimeInMinutes = DATEDIFF(mi, @SolutionStartDateTime, @SolutionEndDateTime);

				SET @SupplyTemperature = (SELECT AVG(Value) FROM History WHERE TagName = 'TT_007\OutEngFltr' AND DateTime >= Cast(@SolutionStartDateTime As varchar(30)) AND DateTime <= Cast(@SolutionEndDateTime As varchar(30)) AND wwRetrievalMode = 'CYCLIC' AND wwResolution = 1000);
				SET @SupplyConductivity = (SELECT AVG(Value) FROM History WHERE TagName = 'CIT_113\OutEngFltr' AND DateTime >= Cast(@SolutionStartDateTime As varchar(30)) AND DateTime <= Cast(@SolutionEndDateTime As varchar(30)) AND wwRetrievalMode = 'CYCLIC' AND wwResolution = 1000);				

				SET @SolutionName = (Select sSolutionName From ProcessCIPSolutionNumberLookup Where iSolutionNumber = @SolutionNumberPrev);

                Insert Into @SolutionTemporaryTableVariable 
                Values(@SolutionCount ,@SolutionStartDateTime, @SolutionEndDateTime, @SolutionName, @StepTimeInMinutes, @SupplyTemperature, @SupplyConductivity);
                
                SET @SolutionStartedButNotYetEnded = 0;
              END
          END
      END  

    /* Save The Value Of The Previous Solution Number Before Retrieving The Next Record */  
    SET @SolutionNumberPrev = @SolutionNumber;
    
    FETCH NEXT FROM Batch_Cursor
    INTO @DateTime, @SolutionNumber
  END
  
  CLOSE Batch_Cursor
  DEALLOCATE Batch_Cursor
  
  /* Write The Final Solution To The Temporary Table If It Has Not Yet Been Done.
  The Way The Solution Number Query Usually Works Is That It Gives The Record When The 
  Last Solution Started But Not The Record When It Ended.  Therefor The Following Code
  If Different Than That Above Because It Uses The Batch End Time For The End Time 
  Of The Final Solution And It Can't Use The Prev Solution Number But Instead The Last One Read. */
  IF @SolutionStartedButNotYetEnded = 1
    BEGIN
      SET @SolutionEndDateTime = @BatchEndDateTime;            

      SET @StepTimeInMinutes = DATEDIFF(mi, @SolutionStartDateTime, @SolutionEndDateTime);

	  SET @SupplyTemperature = (SELECT AVG(Value) FROM History WHERE TagName = 'TT_007\OutEngFltr' AND DateTime >= Cast(@SolutionStartDateTime As varchar(30)) AND DateTime <= Cast(@SolutionEndDateTime As varchar(30)) AND wwRetrievalMode = 'CYCLIC' AND wwResolution = 1000);
	  SET @SupplyConductivity = (SELECT AVG(Value) FROM History WHERE TagName = 'CIT_113\OutEngFltr' AND DateTime >= Cast(@SolutionStartDateTime As varchar(30)) AND DateTime <= Cast(@SolutionEndDateTime As varchar(30)) AND wwRetrievalMode = 'CYCLIC' AND wwResolution = 1000);				

  	  SET @SolutionName = (Select sSolutionName From ProcessCIPSolutionNumberLookup Where iSolutionNumber = @SolutionNumber);

      Insert Into @SolutionTemporaryTableVariable 
      Values(@SolutionCount ,@SolutionStartDateTime, @SolutionEndDateTime, @SolutionName, @StepTimeInMinutes, @SupplyTemperature, @SupplyConductivity);
    END
  
  Select 'Solution ' + Convert(varchar(4), iSolutionCount) As sSolutionTitle, sSolutionName, rStepTime, rSupplyTemperature, rSupplyConductivity From @SolutionTemporaryTableVariable;

