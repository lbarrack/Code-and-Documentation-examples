USE [Runtime]
GO
/****** Object:  StoredProcedure [dbo].[ProcessCIP4Report]    Script Date: 05/17/2013 16:26:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


ALTER Procedure [dbo].[ProcessCIP4Report]   
  
As
  declare @BatchRunIndex varchar(100);
  declare @SQLQueryString nvarchar(2000);
  declare @BatchStartDateTime datetime2(7);
  declare @BatchEndDateTime datetime2(7);
  declare @BatchNumberString varchar(50);
  declare @WFISolution4StartTime datetime2(7);
  declare @WFISolution4EndTime datetime2(7);
  declare @WFISolution4DrainStepEndTime datetime2(7);
  declare @15SecondsBeforeWFISolution4DrainStepEndTime datetime2(7);  
  declare @RunNumber bigint;
  declare @PassFailStatus varchar(4);  
  declare @ActiveRecipeName varchar(82);
  declare @ValidationStatus nvarchar(15);
  declare @ReportStatusMessage nvarchar(500);    
  declare @V81TankLetter varchar(82);
  
  declare @V81ExpirationDateTime datetime2(7);
  declare @TankExpirationDateTime datetime2(7);  
  declare @CIP1_exptime_sp real;
  declare @CIP3_exptime_sp real;
  declare @CIP4_exptime_sp real;
  declare @PhaseStartDateTime datetime2(7);
  declare @CIPExpirationDateTime datetime2(7);
  
  declare @CIP4FinalConductivity real;
  declare @CIP4FinalConductivityMax real;  
  declare @CIP4WFIRinseCondPassFailSetptAvg real;
  declare @CIP4WFIRinseCondPassFailSetptThreshold real;    
    
  SET NOCOUNT ON
    
  SET @BatchRunIndex = (Select CIP4Report From ProcessReportUserParameters Where HostName = HOST_NAME() AND UserID = SUSER_SNAME());

  SET @BatchNumberString = (Select sBatchNumberString From ProcessReportingBatchRunLookup Where sBatchRunIndex = @BatchRunIndex);
  SET @RunNumber = (Select iRunNumber From ProcessReportingBatchRunLookup Where sBatchRunIndex = @BatchRunIndex);
  SET @BatchStartDateTime = (Select dtBatchStartDateTime From ProcessReportingBatchRunLookup Where sBatchRunIndex = @BatchRunIndex);
  SET @BatchEndDateTime = (Select dtBatchEndDateTime From ProcessReportingBatchRunLookup Where sBatchRunIndex = @BatchRunIndex);


  SET @CIP3_exptime_sp = (Select Value From History Where TagName = 'CIP3_exptime_sp' AND DateTime = @BatchStartDateTime);
  SET @CIP1_exptime_sp = (Select Value From History Where TagName = 'CIP1_exptime_sp' AND DateTime = @BatchStartDateTime);

  SET @TankExpirationDateTime = DATEADD(hh, @CIP1_exptime_sp, @BatchEndDateTime);
  SET @V81ExpirationDateTime = DATEADD(hh, @CIP3_exptime_sp, @BatchEndDateTime);
  SET @CIP4_exptime_sp = (Select Value From History Where TagName = 'CIP4_exptime_sp' AND DateTime = @BatchStartDateTime);
  SET @PhaseStartDateTime = (Select Min(DateTime) From History Where TagName = 'Phase_Number' AND Value = 64 AND DateTime >= @BatchStartDateTime AND DateTime <= @BatchEndDateTime);


  SET @V81TankLetter = (Select vValue From History Where TagName = 'V81_Tank_Letter' AND DateTime = @BatchStartDateTime);

  IF @V81TankLetter IS NULL
  BEGIN
	SET @V81TankLetter = '';
  END

  IF @PhaseStartDateTime IS NULL
    BEGIN
      /* Use These Alternate SET Statements In Case The Phase Start And End Times Required For The Report Could Not Be Found.  If This Is Done Then Display An Error Message On The Report. */
      SET @PhaseStartDateTime = @BatchStartDateTime;  
      SET @ReportStatusMessage = 'The Recorded Data For The Selected Batch Does Not Contain The Correct Phases For This Report.  The Data Displayed Represents The Data Recorded For The Entire Duration Of The Batch Instead Of The Data For The Phases That Are Requred.  Consequently The Data Can Be Used For Troubleshooting Purposes But May Make Some Of The Calculated Fields Invalid.';    
    END
  ELSE
    SET @ReportStatusMessage = '';



  IF @CIP4_exptime_sp IS NULL
    BEGIN

      SET @CIP4_exptime_sp = '';
      SET @CIPExpirationDateTime = '';
  
    END  
  ELSE
    SET @CIPExpirationDateTime = DATEADD(hh, @CIP4_exptime_sp, @BatchEndDateTime);



  SET @CIP4WFIRinseCondPassFailSetptAvg = (Select CIP3WFIRinseCondPassFailSetptAvg From ProcessReportSettings);
  SET @CIP4WFIRinseCondPassFailSetptThreshold = (Select CIP3WFIRinseCondPassFailSetptThreshold From ProcessReportSettings);

  /* Find The Average And Max Conductivity For The Last 15 Seconds Of The Drain Step Where WFI Solution #3 Is In Use And The Subphase is 76 */
  SET @WFISolution4StartTime = (Select Min(DateTime) From History Where TagName = 'cskdSeqeNu' AND Value = 3 AND DateTime >= @BatchStartDateTime AND DateTime <= @BatchEndDateTime AND wwRetrievalMode = 'CYCLIC' AND wwResolution = 1000);    
  SET @WFISolution4EndTime = (Select Max(DateTime) From History Where TagName = 'cskdSeqeNu' AND Value = 3 AND DateTime >= @BatchStartDateTime AND DateTime <= @BatchEndDateTime AND wwRetrievalMode = 'CYCLIC' AND wwResolution = 1000);
  SET @WFISolution4DrainStepEndTime = (Select Max(DateTime) From History Where TagName = 'Subphase1_Name' AND Value = 135 AND DateTime >= @WFISolution4StartTime AND DateTime <= @WFISolution4EndTime AND wwRetrievalMode = 'CYCLIC' AND wwResolution = 1000);  
  
  SET @15SecondsBeforeWFISolution4DrainStepEndTime = DATEADD(ss, -15, @WFISolution4DrainStepEndTime);    
  SET @CIP4FinalConductivity = (Select Avg(Value) From History Where TagName = 'CIT_008\OutEngFltr' AND DateTime >= @15SecondsBeforeWFISolution4DrainStepEndTime AND DateTime <= @WFISolution4DrainStepEndTime AND wwRetrievalMode = 'CYCLIC' AND wwResolution = 1000);  
  SET @CIP4FinalConductivityMax = (Select Max(Value) From History Where TagName = 'CIT_008\OutEngFltr' AND DateTime >= @15SecondsBeforeWFISolution4DrainStepEndTime AND DateTime <= @WFISolution4DrainStepEndTime AND wwRetrievalMode = 'CYCLIC' AND wwResolution = 1000);  
      
  /* If The Final Conductivity Is Less Less Than Or Equal To Both The Average And The Threshold Setpoints Then The Run Is Considered To Pass. */
  /*If (@CIP4FinalConductivity <= @CIP4WFIRinseCondPassFailSetptAvg) AND (@CIP4FinalConductivityMax <= @CIP4WFIRinseCondPassFailSetptThreshold)
    SET @PassFailStatus = 'PASS'
  Else
    SET @PassFailStatus = 'FAIL'  */  
    
 SET @PassFailStatus = ''
    
  SET @ActiveRecipeName = (Select vValue From History Where TagName = 'Active_RecipeName' AND DateTime = @BatchStartDateTime);
  SET @ValidationStatus = (Select sValidationStatus From ProcessReportingBatchRunLookup Where sBatchRunIndex = @BatchRunIndex);  
  
  /* The Validation Status Is Only Shown On The Report Is The Status Was Not "Validated" */
  IF @ValidationStatus = 'Validated'
    SET @ValidationStatus = ''   
  
  /* Query For The Maximum Fo Value For Each Temperature During A Specific Batch Of The Batch.  The Fo Value Is Cleared Sometimes Before The End Timestamp So A Single Timestamp Won't Show The Total Accumulated Fo Number. */
  /* edited query string*/
  /*
  SET @SQLQueryString = 'SELECT "' + @BatchNumberString + '" As sBatchNumberString, ' + Convert(varchar(30), @RunNumber) + ' As iRunNumber, "' + Convert(varchar(19), @BatchStartDateTime) + '" As dtBatchStartDateTime, "' + Convert(varchar(19), @BatchEndDateTime) + '" As dtBatchEndDateTime, "' + @ActiveRecipeName + '" As sActiveRecipeName, "' + Convert(varchar(19), @CIPExpirationDateTime) + '" As CIPExpirationDateTime, "' + Convert(varchar(1), @V81TankLetter) + '" As sV81TankLetter, "' + Convert(varchar(12),@ValidationStatus) + '" As sValidationStatus, "' + Convert(varchar(500), @ReportStatusMessage) + '" As sReportStatusMessage, * FROM OPENQUERY(INSQL, ''SELECT CIP4_Acidsupcond_sp, CIP4_Acidsuptemp_sp, CIP4_Caussupcond_sp, CIP4_Caussuptemp_sp, CIP4_RODIsuptemp_sp, CIP4_WFIsuptemp_sp FROM Runtime.dbo.WideHistory WHERE DateTime = "' + Convert(varchar(30), @BatchStartDateTime) + '" AND wwRetrievalMode = "Delta"'')'
*/
  /* original unmodified Query String */
  
  SET @SQLQueryString = 'SELECT "' + @BatchNumberString + '" As sBatchNumberString, ' + Convert(varchar(30), @RunNumber) + ' As iRunNumber, "' + Convert(varchar(19), @BatchStartDateTime) + '" As dtBatchStartDateTime, "' + Convert(varchar(19), @BatchEndDateTime) + '" As dtBatchEndDateTime, "' + @ActiveRecipeName + '" As sActiveRecipeName, "'+ Convert(varchar(19), @CIPExpirationDateTime) + '" As CIPExpirationDateTime, "'+ Convert(varchar(19), @V81ExpirationDateTime) + '" As V81ExpirationDateTime, "'+ Convert(varchar(19), @TankExpirationDateTime) + '" As TankExpirationDateTime, "' + Convert(varchar(1), @V81TankLetter) + '" As sV81TankLetter, "' + Convert(varchar(10), @CIP4FinalConductivity) + '" As CIP4FinalConductivity, "' + Convert(varchar(10), @CIP4WFIRinseCondPassFailSetptAvg) + '" As CIP4WFIRinseCondPassFailSetptAvg, "' + Convert(varchar(10), @CIP4WFIRinseCondPassFailSetptThreshold) + '" As CIP4WFIRinseCondPassFailSetptThreshold, "' + Convert(varchar(4), @PassFailStatus) + '" As sPassFailStatus, "' + Convert(varchar(15), @ValidationStatus) + '" As sValidationStatus, "' + Convert(varchar(500), @ReportStatusMessage) + '" As sReportStatusMessage, * FROM OPENQUERY(INSQL, ''SELECT CIP4_Acidsupcond_sp, CIP4_Acidsuptemp_sp, CIP4_Caussupcond_sp, CIP4_Caussuptemp_sp, CIP4_RODIsuptemp_sp, CIP4_WFIsuptemp_sp FROM Runtime.dbo.WideHistory WHERE DateTime = "' + Convert(varchar(30), @BatchStartDateTime) + '" AND wwRetrievalMode = "Delta"'')'
	
/*remove */

  Exec(@SQLQueryString)  
  

