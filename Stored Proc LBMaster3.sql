USE [SampleDatabase]
GO
/****** Object:  StoredProcedure [US].[sp_update_Workday_US_Benefits_SpendingAcct]    Script Date: 01/25/2016 14:46:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		L.Barrack
-- Create date:     01-28-2016
-- Modified from existing procedure
-- Description:	Tracking changes for Workday
-- =============================================
CREATE PROCEDURE [US].[sp_update_Workday_US_Benefits_SpendingAcct]
AS
BEGIN
--	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    
    ---------------------------------------------------------------------------------------------
    -- Drop temp tables if they exist
    ---------------------------------------------------------------------------------------------
    IF OBJECT_ID('tempdb..#Workday_US_Benefits_SpendingAcct_CURRENT') IS NOT NULL
    DROP TABLE #Workday_US_Benefits_SpendingAcct_CURRENT;

    IF OBJECT_ID('tempdb..#Workday_US_Benefits_SpendingAcct_CHANGES') IS NOT NULL
    DROP TABLE #Workday_US_Benefits_SpendingAcct_CHANGES;


    ---------------------------------------------------------------------------------------------
    -- Snapshot the view into static temp table
    ---------------------------------------------------------------------------------------------
    CREATE TABLE #Workday_US_Benefits_SpendingAcct_CURRENT(
	
	[Employee ID] [varchar](50) NOT NULL,
	[Employee Company][varchar](100) NULL,
	[Employee Cost Center][varchar](100) NULL,
	[Employee Sub Cost-Center][varchar](100) NULL,
	[Event Date][varchar](100) NULL,
	[Benefit Deduction Periods Remaining][varchar](100) NULL,
	[Remaining Period Frquency][varchar](100) NULL,
	[Coverage Begin Date][varchar](100) NULL,
	[Original Coverage Begin Date][varchar](100) NULL,
	[Deduction Begin Date][varchar](100) NULL,
	[Original Deduction Begin Date][varchar](100) NULL,
	[Spending Account Plan ID][varchar](200)NOT NULL,
	[YTD Contribution Amount][varchar](100) NULL,
	[Annual Contribution][varchar](100) NULL,
	[Employee Cost][varchar](100) NULL,
	[Frequency][varchar](100) NULL,
	[Beneficiary ID][varchar](100) NULL,
	[Primary Percentage][varchar](100) NULL,
	[Contingent Percentage][varchar](100) NULL,
	
	);
	
     INSERT INTO #Workday_US_Benefits_SpendingAcct_CURRENT
     
     SELECT distinct
      
	   [Employee ID]
      ,[Employee Company]
      ,[Employee Cost Center]
      ,[Employee Sub Cost-Center]
      ,[Event Date]
      ,[Benefit Deduction Periods Remaining]
      ,[Remaining Period Frquency]
      ,[Coverage Begin Date]
      ,[Original Coverage Begin Date]
      ,[Deduction Begin Date]
      ,[Original Deduction Begin Date]
      ,[Spending Account Plan ID]
      ,[YTD Contribution Amount]
      ,[Annual Contribution]
      ,[Employee Cost]
      ,[Frequency]
      ,[Beneficiary ID]
      ,[Primary Percentage]
      ,[Contingent Percentage]
	
	   
	

     FROM [GlobalHR].[dbo].[Workday_US_Benefits_SpendingAcct];
     
    ---------------------------------------------------------------------------------------------
    -- Process Data Changes
    ---------------------------------------------------------------------------------------------
    CREATE TABLE #Workday_US_Benefits_SpendingAcct_CHANGES(
     -- keys and eff date 
	[Employee ID] [char](10) NOT NULL,
	
	[Spending Account Plan ID][varchar](200)NOT NULL,
	[EFFECTIVE_DATE] [datetime] NOT NULL
	);

	--
	-- Find all records in real table that were changed since last run
	--
	INSERT INTO #Workday_US_Benefits_SpendingAcct_CHANGES
	SELECT 
     -- keys and eff date 
       H.[Employee ID]
     
      ,H.[Spending Account Plan ID]
      ,H.[EFFECTIVE_DATE]
	FROM 
		#Workday_US_Benefits_SpendingAcct_CURRENT T 
	INNER JOIN 
		US.Workday_US_Benefits_SpendingAcct_HISTORY H
	ON
	      
	  T.[Employee ID]    	  			=	H.[Employee ID]
	  	
	  AND T.[Spending Account Plan ID]	=	H.[Spending Account Plan ID]					
	  
	 AND GETDATE() BETWEEN H.EFFECTIVE_DATE AND H.EFFECTIVE_UNTIL
	WHERE
		                        
		   isnull(T.[Employee Company], '')					<>				 isnull(H.[Employee Company], '')						
		OR isnull(T.[Employee Cost Center], '')					<>				 isnull(H.[Employee Cost Center], '')					
		OR isnull(T.[Employee Sub Cost-Center], '')				<>				 isnull(H.[Employee Sub Cost-Center], '')				
		OR isnull(T.[Event Date], '')						<>				 isnull(H.[Event Date], '')	
		OR isnull(T.[Benefit Deduction Periods Remaining], '')			<>				 isnull(H.[Benefit Deduction Periods Remaining], '')
		OR isnull(T.[Remaining Period Frquency], '')				<>				 isnull(H.[Remaining Period Frquency], '')			
		OR isnull(T.[Coverage Begin Date], '')					<>				 isnull(H.[Coverage Begin Date], '')					
		OR isnull(T.[Original Coverage Begin Date], '')				<>				 isnull(H.[Original Coverage Begin Date], '')			
		OR isnull(T.[Deduction Begin Date], '')					<>				 isnull(H.[Deduction Begin Date], '')					
		OR isnull(T.[Original Deduction Begin Date], '')			<>				 isnull(H.[Original Deduction Begin Date], '')
		OR isnull(T.[Spending Account Plan ID], '')				<>				 isnull(H.[Spending Account Plan ID], '')	
		OR isnull(T.[YTD Contribution Amount], '')				<>				 isnull(H.[YTD Contribution Amount], '')	
		OR isnull(T.[Annual Contribution], '')					<>				 isnull(H.[Annual Contribution], '')		
		OR isnull(T.[Employee Cost], '')					<>				 isnull(H.[Employee Cost], '')			
		OR isnull(T.[Frequency], '')						<>				 isnull(H.[Frequency], '')				
		OR isnull(T.[Beneficiary ID], '')					<>				 isnull(H.[Beneficiary ID], '')	
		OR isnull(T.[Primary Percentage], '')					<>				 isnull(H.[Primary Percentage], '')		
		OR isnull(T.[Contingent Percentage], '')				<>				 isnull(H.[Contingent Percentage], '')	
					
							
		
						
	-- Retire the old version of historical records (Update the "Effective Until" Date)
	--
	UPDATE US.Workday_US_Benefits_SpendingAcct_HISTORY
	SET
          EFFECTIVE_UNTIL =  convert(varchar, getdate()-1, 101)
	FROM
		#Workday_US_Benefits_SpendingAcct_CHANGES TT
	INNER JOIN
		US.Workday_US_Benefits_SpendingAcct_HISTORY TH
	ON
	   
			TT.[Employee ID]					=	TH.[Employee ID]	
				
		 AND TT.[Spending Account Plan ID]	=	TH.[Spending Account Plan ID]				
	     
	 	AND GETDATE() BETWEEN TH.EFFECTIVE_DATE AND TH.EFFECTIVE_UNTIL


	--
	-- Handle same day changes.....
	-- By deleting the prior change of the day.
	--
	DELETE FROM US.Workday_US_Benefits_SpendingAcct_HISTORY 
	WHERE
		EFFECTIVE_DATE = convert(varchar, getdate(), 101)
	AND	EFFECTIVE_UNTIL     = convert(varchar, getdate()-1, 101)

	--
	-- Create new version of historical records to reflect changes as of today
	--
	INSERT INTO US.Workday_US_Benefits_SpendingAcct_HISTORY
	SELECT 
    
		 T.[Employee ID]
		,T.[Employee Company]
		,T.[Employee Cost Center]
		,T.[Employee Sub Cost-Center]
		,T.[Event Date]
		,T.[Benefit Deduction Periods Remaining]
		,T.[Remaining Period Frquency]
		,T.[Coverage Begin Date]
		,T.[Original Coverage Begin Date]
		,T.[Deduction Begin Date]
		,T.[Original Deduction Begin Date]
		,T.[Spending Account Plan ID]
		,T.[YTD Contribution Amount]
		,T.[Annual Contribution]
		,T.[Employee Cost]
		,T.[Frequency]
		,T.[Beneficiary ID]
		,T.[Primary Percentage]
		,T.[Contingent Percentage]
		
      ,CONVERT(VARCHAR, GETDATE(), 101)	
      ,'12/31/2099'
	FROM
		#Workday_US_Benefits_SpendingAcct_CHANGES TT
	INNER JOIN
		#Workday_US_Benefits_SpendingAcct_CURRENT T
	ON

			TT.[Employee ID]					=		T.[Employee ID]
	    	
		AND TT.[Spending Account Plan ID]	=	T.[Spending Account Plan ID]
	 
		

	DROP TABLE #Workday_US_Benefits_SpendingAcct_CHANGES

	--------------------------------------------------------------------------------------------------------------
	--   Add brand new historical records that had no prior versions
	--------------------------------------------------------------------------------------------------------------
	INSERT INTO US.Workday_US_Benefits_SpendingAcct_HISTORY
	SELECT 
	
 		 T.[Employee ID]
		,T.[Employee Company]
		,T.[Employee Cost Center]
		,T.[Employee Sub Cost-Center]
		,T.[Event Date]
		,T.[Benefit Deduction Periods Remaining]
		,T.[Remaining Period Frquency]
		,T.[Coverage Begin Date]
		,T.[Original Coverage Begin Date]
		,T.[Deduction Begin Date]
		,T.[Original Deduction Begin Date]
		,T.[Spending Account Plan ID]
		,T.[YTD Contribution Amount]
		,T.[Annual Contribution]
		,T.[Employee Cost]
		,T.[Frequency]
		,T.[Beneficiary ID]
		,T.[Primary Percentage]
		,T.[Contingent Percentage]
	 
		 
	
	     
	 ,CONVERT(VARCHAR, GETDATE(), 101)	
	 ,'12/31/2099'
	FROM
		#Workday_US_Benefits_SpendingAcct_CURRENT T
	LEFT OUTER JOIN
		US.Workday_US_Benefits_SpendingAcct_HISTORY H
	ON
	  
	     T.[Employee ID]					    =	    H.[Employee ID]
	  	
		AND T.[Spending Account Plan ID]	=	H.[Spending Account Plan ID]
	 AND GETDATE() BETWEEN H.EFFECTIVE_DATE AND H.EFFECTIVE_UNTIL
	WHERE
		H.[Employee ID] IS NULL

	---------------------------------------------------------------------------------------------------------------------
	-- Retire records in history table if user deleted matching record in real table. 
	---------------------------------------------------------------------------------------------------------------------
	UPDATE US.Workday_US_Benefits_SpendingAcct_HISTORY
	SET
		EFFECTIVE_UNTIL =  CONVERT(VARCHAR, GETDATE(), 101)
	FROM
		US.Workday_US_Benefits_SpendingAcct_HISTORY TH
	LEFT OUTER JOIN
		#Workday_US_Benefits_SpendingAcct_CURRENT T
	ON
	   
			TH.[Employee ID]				    =		T.[Employee ID]
	   
		AND TH.[Spending Account Plan ID]	=	T.[Spending Account Plan ID]
	  
	
	---------------------------------------------------------------------------------
	-- PUT ALL VALUES USED Clustered Primary Key
	-------------------------------------------------------------------------------------
	WHERE
	    GETDATE() BETWEEN TH.EFFECTIVE_DATE AND TH.EFFECTIVE_UNTIL AND
	   T.[Employee ID] IS NULL 
		
		


END

