IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_ProtocolSearchExtended]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_ProtocolSearchExtended]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****** Object:  Stored Procedure dbo.usp_ProtocolSearchExtended    Script Date: 7/18/2005 12:13:45 PM ******/

/*	NCI - National Cancer Institute
*	
*	Purpose:	
*	Stored procedure perform Clinical Trial Search 
*
*	Objects Used:
*
*	Related Objects:
*		- make sure that you did impact analysis fore the objects below:
*		usp_ReRunSearch
*		usp_GetProtocolsBySearchID
*
*	Change History:
*	5/27/2003 	Alex Pidlisnyy	Script Created
*	7/1/2003 	Alex Pidlisnyy	Add parameters @TrialSponsor, @DrugSearchFormula, @SearchType 
*	7/7/2003 	Alex Pidlisnyy	SCR#36 Do not use Lead Organization Personnel location data to determine if there is a match when location criteria are specified.  
*	7/15/2003 	Alex Pidlisnyy	Return ProtocolSearchID as an recordset in the case if no results was found
*	7/16/2003 	Alex Pidlisnyy	SCR# 49. Replace Control character Tab CHAR(9), Line feed CHAR(10) Carriage return CHAR(13) 
*					in the drug search string with the blank string to prevent incorrect 
*					result from happening. 	
*	12/4/2003	Alex 		Add Phase in to search Result
*	1/7/2004	Alex 		Add NCTID AlternateID Type to search 
*	2/14/2004	Alex 		Add statistic loging function. dbo.usp_LogProtocolSearchExecutionTime  
*	4/6/2004	Alex 		Use usp_ProtocolSearchSys_StepOne function 
*
*	- check are we storing @ResultRowCount information everywhere
*
*	7/19/2005 	Min		Add ProtocolSpecialCategory parameter
*/


CREATE PROCEDURE usp_ProtocolSearchExtended
	(	
	@CancerType 		varchar(8000) 	= NULL,  	-- (+) coma separated list of CDR IDs
 	@CancerTypeStage 	varchar(8000) 	= NULL,  	-- (+) coma separated list of CDR IDs
	@TrialType		varchar(100) 	= NULL,  	-- (+) coma separated list of Type Names
	@TrialStatus		char(1) 	= 'Y', 		-- (+) "Y" - Active, "N" - Closed
	@AlternateProtocolID	varchar(8000)	= NULL,  	-- (+) coma separated list of Protocol IDs
	
	@ZIP			varchar(10)	= NULL,		-- (+) 00000-0000
	@ZIPProximity		int		= NULL,		-- proximity mile radius
	@City			varchar(50)	= NULL,		-- (+) city 
	@State			varchar(50)	= NULL,		-- (+) state
	@Country		varchar(50)	= NULL,		-- (+) country
	@Institution		varchar(8000)	= NULL,  	-- coma separated list of Hospitals/Institution
	
	@Investigator		varchar(8000)	= NULL,  	-- (+) coma separated list of string (GivenName+Space+SurName) 
	@LeadOrganization	varchar(8000)	= NULL,  	-- (+) coma separated list of strings 

	@VAMilitaryOrganization	varchar(8000)	= NULL,  	-- (+) coma separated list of OrganizationIDs

	@IsNIHClinicalCenterTrial char(1)	= NULL, 	-- (+) "Y"  ("N" and NULL - meand does not matter)
	@IsNew			char(1)		= NULL, 	-- (+) "Y"  ("N" and NULL - meand does not matter)
	@TreatmentType		varchar(8000)	= NULL, 	-- (+) coma separated list of Modality CDR IDs
	@DrugSearchFormula	varchar(100)	= 'OR',  	-- 'OR' - default, 'AND' - drug combination
 	@Drug 			varchar(8000)	= NULL,  	-- (+) coma separated list of CDR IDs
	@Phase			varchar(100)	= NULL,  	-- (+) coma separated list of string
	@TrialSponsor		varchar(8000)	= NULL,  	-- (+) coma separated list of string
	@AbstractVersion	varchar(50)	= 'Professional', -- (+) Professional or Patient

	@ParameterOne		varchar(8000)	= NULL,  	-- reserved parameter "SimpleSearch" 
	@ParameterTwo		varchar(8000)	= NULL,  	-- reserved parameter
	@ParameterThree		varchar(8000)	= NULL,  	-- reserved parameter

	@ReportMessage 		varchar(8000) = '' OUTPUT, 	-- (+) returns nothing "" or message discribed why we get zero result.
	@ProtocolSearchID	int = NULL OUTPUT, 		-- (+) returns search ID which identifies search 
	@ShowDetailReportMessage char(1)	= 'N',	  	-- Show Detail Report Message. 

	@GetCachedSearchResult	bit = 1,			-- If set to '1' than function will get cached search result 
								-- if possible, otherwise search will be performed. If set to 
								-- '0' than search will be performed and cache data 
								-- will be updated.  

	@SpecialCategory varchar(1000) = null  ,     --Gao 7/18 SC
	@IsReRun bit = 0

	)
AS
BEGIN
	SET NOCOUNT ON  
	--**********************************
	-- PRINT 	'Step 50 - Declare variables'
	DECLARE @ResultRowCount int,
		@tmpResultRowCount int,
		@tmpResultRowCountTwo int,
		@ContactInfoSearchStatus int, 
		@IsCachedSearchResultAvailable bit,
		@tmpDelimeter varchar(1),
		@DrugSearchPattern varchar(8000),
		@Iteration int,
		@SearchStartTime datetime,
		@SysProtocolSearchID int

	
	--**********************************
	-- PRINT 	'Step 55 - Set values'
	SET 	@tmpDelimeter = ','
	SET 	@ContactInfoSearchStatus = 0 	-- 0 - no serch was performed
						-- 1 - City, State, Country, Zip, Zip Proximity
						-- 2 - Investigator, LeadOrganization, Institution
	SET 	@SearchStartTime = GETDATE()
	SET 	@SysProtocolSearchID = NULL
	
	--**********************************
	-- PRINT 'Step 100 - Create temporary tables'
	CREATE TABLE #Result (
		ProtocolID	int		-- CDRProtocolID
	)

	--table will include Protocols found by Alternate IDs 
	CREATE TABLE #tmpAltSearch (
		ProtocolID int
	)

	--table will include Protocols found by Alternate IDs 
	CREATE TABLE #tmpAltContact (
		ProtocolID int,
		ProtocolContactInfoID int
	)

	CREATE TABLE #ContactInfoResult (
		ProtocolID int,
		ProtocolContactInfoID	int		
	)

	--**********************************
	-- PRINT 'Step 150 - Log ProtocolSearch'  
	EXEC usp_SaveProtocolSearchParameters_Adv
		@CancerType = @CancerType,
		@CancerTypeStage = @CancerTypeStage,
		@TrialType = @TrialType,
		@TrialStatus = @TrialStatus,
		@AlternateProtocolID = @AlternateProtocolID,
		@ZIP = @ZIP,
		@ZIPProximity = @ZIPProximity,
		@City = @City,
		@State = @State,
		@Country = @Country,
		@Institution = @Institution,
		@Investigator = @Investigator,
		@LeadOrganization = @LeadOrganization,
		@VAMilitaryOrganization = @VAMilitaryOrganization,
		@IsNIHClinicalCenterTrial = @IsNIHClinicalCenterTrial,
		@IsNew = @IsNew,
		@TreatmentType = @TreatmentType,
		@DrugSearchFormula = @DrugSearchFormula,
		@Drug = @Drug,
		@Phase = @Phase,
		@TrialSponsor = @TrialSponsor,
		@AbstractVersion = @AbstractVersion,
		@ParameterOne = @ParameterOne,
		@ParameterTwo = @ParameterTwo,
		@ParameterThree = @ParameterThree,
		@ShowDetailReportMessage = @ShowDetailReportMessage,
		@SearchType = 'Advanced', 

		@CheckCache = @GetCachedSearchResult, -- '1' if we need to perform search for available Cache result
		@SPecialCategory = @SpecialCategory,  ----Gao 7/18 SC
		@IsCachedSearchResultAvailable = @IsCachedSearchResultAvailable OUTPUT,  	-- '1' If Cashed Search Result available
		@ProtocolSearchID = @ProtocolSearchID OUTPUT 		-- Input/Output parameters returns search ID which identifies search, if provided together with @CheckCache than, cache will be checked for data availability  

	--**********************************
	-- PRINT 	'Step 160 - Check do we need to perform search' ----GaoComment

	IF 	( ISNULL( @IsCachedSearchResultAvailable, 0 ) <> 1 ) 
		OR
		( ISNULL( @GetCachedSearchResult, 0 ) <> 1 )
	BEGIN
		--**********************************
		-- PRINT 'Step 170 - Yes lets start Search'

		IF @GetCachedSearchResult = 0
		BEGIN
			--**********************************
			-- PRINT 'Step 180 - Clean the cache if we inforced to refine search'

			DELETE 	ProtocolSearchSysCache
			WHERE 	ProtocolSearchID = @ProtocolSearchID

			DELETE 	ProtocolSearchContactCache
			WHERE 	ProtocolSearchID = @ProtocolSearchID
		END


		--**********************************
		-- PRINT 'Step 200 - Set defaul values'
		SET 	@ResultRowCount = 0
		SET 	@VAMilitaryOrganization = NULLIF( LTRIM( @VAMilitaryOrganization ), '') 

		-- Active or clesed Statuses always exists so we will not monitore resultset for them
		-- But we will do it for all other criterial

		SET 	@TrialStatus 	= ISNULL( NULLIF( RTRIM(LTRIM(@TrialStatus)), ''), 'Y' )			
		SET 	@TrialType 	= NULLIF( UPPER(LTRIM(RTRIM( @TrialType ))), 'ALL' )
		SET 	@TrialType 	= NULLIF( LTRIM( @TrialType ), '' )	
		SET 	@CancerType 	= NULLIF( LTRIM( @CancerType ), '' )	
		SET 	@CancerTypeStage	= NULLIF( LTRIM(RTRIM( @CancerTypeStage	)), '' )	

		--**********************************
		-- PRINT 'Step 205 - Run usp_ProtocolSearchSys_StepOne to get System Cache'
		EXEC dbo.usp_ProtocolSearchSys_StepOne
			@CancerType = @CancerType,
		 	@CancerTypeStage = @CancerTypeStage,
			@TrialType = @TrialType,
			@TrialStatus = @TrialStatus,
			@GetCachedSearchResult = @GetCachedSearchResult,
			@SysProtocolSearchID = @SysProtocolSearchID OUTPUT,
			@ResultRowCount	= @ResultRowCount OUTPUT	

		-- Find out howm many rows we have in resultset
		IF @ResultRowCount <= 0
		BEGIN
			UPDATE 	ProtocolSearch
			SET 	Requested = Requested + 1,
				IsCachedSearchResultAvailable = 1,
				IsCachedContactsAvailable = 0 
			WHERE 	ProtocolSearchID = @ProtocolSearchID

			EXEC dbo.usp_LogProtocolSearchExecutionTime 
				@ProtocolSearchID = @ProtocolSearchID ,
				@ResultCount = 0,
				@StartTime = @SearchStartTime,
				@Message = 'ZERO Result for parameters: TrialType and CancerType'		
			if @isReRun = 0
			SELECT 	@ProtocolSearchID AS 'ProtocolSearchID', 
				0 AS 'ResultCount'

			RETURN
		END
		ELSE BEGIN
			-- Get System Cache into Result Table
			INSERT INTO #Result 		
			SELECT 	ProtocolID 
			FROM 	ProtocolSearchSysCache WITH (READUNCOMMITTED)
			WHERE 	ProtocolSearchID = @SysProtocolSearchID	
		END



----------------------Gao 7/18 SC

		--**********************************

		--	 PRINT 'Step 510 - do we have any SpecialCategory' 

		SET 	@SpecialCategory	= NULLIF( LTRIM(RTRIM( @SpecialCategory )), 'ALL' )	
		SET 	@SpecialCategory	= NULLIF( RTRIM( @SpecialCategory ), '' )	

		print @SpecialCategory ----GaoComment

		IF @SpecialCategory is not null
		BEGIN
		--**********************************
		-- PRINT 'Step 511 - yes we do, lets check for SpecialCategory
			DELETE  #Result 
				WHERE  ProtocolID NOT IN (
					SELECT	ProtocolID
					FROM	protocolSpecialCategory  PSC WITH ( READUNCOMMITTED ) 
					INNER JOIN (
						SELECT 	LTRIM(RTRIM( objectID )) AS 'Pattern'
						FROM	udf_GetComaSeparatedIDs( @SpecialCategory )
						) AS tmp
						ON PSC.protocolSpecialCategory = tmp.Pattern 
					)

				SET @tmpResultRowCount = @@ROWCOUNT 


			--PRINT 'Clinicalt Rtials not found for provided search criteria'		
			IF 	@ResultRowCount <= @tmpResultRowCount 
			BEGIN
				UPDATE 	ProtocolSearch
				SET 	Requested = Requested + 1,
					IsCachedSearchResultAvailable = 1,
					IsCachedContactsAvailable = 0 
				WHERE 	ProtocolSearchID = @ProtocolSearchID

				EXEC dbo.usp_LogProtocolSearchExecutionTime 
					@ProtocolSearchID = @ProtocolSearchID ,
					@ResultCount = 0,
					@StartTime = @SearchStartTime,
					@Message = 'ZERO Result for parameters: SpecialCategory'		
				if @isReRun = 0
				SELECT 	@ProtocolSearchID AS 'SpecialCategory',
					0 AS 'ResultCount'

				RETURN
			END 
			
			-- Delete Protocols which do not meet search creteria
	
			SET @ResultRowCount = @ResultRowCount - @tmpResultRowCount
		END

---------------------------------------
























		--**********************************
		-- PRINT 'Step 520 - Ok we got ' + convert(varchar, @ResultRowCount )+ ' trials back '  
		-- PRINT 'Step 530 - do we have any AlternateProtocolIDs'

		IF NULLIF( RTRIM( @AlternateProtocolID ) , '') IS NOT NULL
		BEGIN
			--**********************************
			-- PRINT 'Step 600 - yes we do, lets check for AlternateProtocolIDs'
			
			IF 	NULLIF( CHARINDEX( ';', @AlternateProtocolID ), 0 ) 
				IS NOT NULL 
			BEGIN
				SET @tmpDelimeter = ';'
			END
			ELSE BEGIN
				SET @tmpDelimeter = ','
			END

			IF @TrialStatus	= 'Y'
			BEGIN
				DELETE  #Result 
				WHERE  ProtocolID NOT IN (
						SELECT	ProtocolID
						FROM	vwProtocolAlternateIDActive AS PID WITH ( READUNCOMMITTED ) 
							INNER JOIN (
								SELECT '%' 
									+ REPLACE( REPLACE( LTRIM(RTRIM( ObjectID )), ' ', ''), '-', '')  
									+ '%' 
									AS 'Pattern'	
								FROM dbo.udf_GetDelimiterSeparatedIDs ( @AlternateProtocolID, @tmpDelimeter )
								) AS tmpID
								ON REPLACE( REPLACE( IDString, ' ', ''), '-', '') like Pattern
					)
	
				SET @tmpResultRowCount = @@ROWCOUNT 
			END
			ELSE BEGIN
				DELETE  #Result 
				WHERE  ProtocolID NOT IN (
						SELECT	ProtocolID
						FROM	ProtocolAlternateID AS PID WITH ( READUNCOMMITTED ) 
							INNER JOIN (
								SELECT '%' 
									+ REPLACE( REPLACE( LTRIM(RTRIM( ObjectID )), ' ', ''), '-', '')  
									+ '%' 
									AS 'Pattern'	
								FROM dbo.udf_GetDelimiterSeparatedIDs ( @AlternateProtocolID, @tmpDelimeter )
								) AS tmpID
								ON REPLACE( REPLACE( IDString, ' ', ''), '-', '') like Pattern
								--AND IDType IN ( 'Primary', 'Alternate', 'Secondary', 'NCI alternate', 'NCTID' )
								--AND IDType NOT IN ('GUID', 'CDRKey', 'PDQKey')
								--AND IDTypeID NOT IN (5,7 ,10 )
					)
				SET @tmpResultRowCount = @@ROWCOUNT 
			END

			--PRINT 'Clinicalt Rtials not found for provided search criteria'		
			IF 	@ResultRowCount <= @tmpResultRowCount 
			BEGIN
				UPDATE 	ProtocolSearch
				SET 	Requested = Requested + 1,
					IsCachedSearchResultAvailable = 1,
					IsCachedContactsAvailable = 0 
				WHERE 	ProtocolSearchID = @ProtocolSearchID

				EXEC dbo.usp_LogProtocolSearchExecutionTime 
					@ProtocolSearchID = @ProtocolSearchID ,
					@ResultCount = 0,
					@StartTime = @SearchStartTime,
					@Message = 'ZERO Result for parameters: AnternateProtocolID'		
				if @isReRun = 0
				SELECT 	@ProtocolSearchID AS 'ProtocolSearchID',
					0 AS 'ResultCount'

				RETURN
			END 
			
			-- Delete Protocols which do not meet search creteria
	
			SET @ResultRowCount = @ResultRowCount - @tmpResultRowCount
		END

		--**********************************
		-- PRINT 'Step 620 - do we have any Drug'
		IF ISNULL( LTRIM(RTRIM( @Drug )), '') <> '' 
		BEGIN
			-- PRINT 'Step 625 - yes we do, Check for Drugs: ' + @Drug
			-- by Default we will have 'OR'
			SET @DrugSearchFormula = UPPER( LTRIM(RTRIM(@DrugSearchFormula)) ) 
			IF @DrugSearchFormula = 'AND'
			BEGIN
				-- PRINT 'Step 625.B - AND Condition'

				set 	@Iteration = 1
				
				DECLARE Drug_Cursor CURSOR FOR 
					SELECT '%' + UPPER( REPLACE( REPLACE( REPLACE( REPLACE( REPLACE( REPLACE( ObjectID, ' ', ''), '-', ''), ',', ''), CHAR(9) ,''), CHAR(10) ,''), CHAR(13) ,'') ) + '%' AS 'DrugSearchPattern'
					FROM	dbo.udf_GetDelimiterSeparatedIDs( @Drug, ';' )
				
				OPEN Drug_Cursor
				FETCH NEXT FROM Drug_Cursor INTO @DrugSearchPattern 
			
				WHILE @@FETCH_STATUS = 0
				BEGIN
					-- PRINT @DrugSearchPattern 
					IF @Iteration = 1 
					BEGIN
						-- Prepopulate Initial Protocol Drug Result  
						IF @TrialStatus	= 'Y'
						BEGIN
							INSERT INTO #tmpAltSearch
							SELECT 	ProtocolID
							FROM	vwProtocolDrugActive pd WITH ( READUNCOMMITTED ) 
									inner join termdrug td WITH ( READUNCOMMITTED )  on td.termid  = pd.drugid
							WHERE 	DrugName like @DrugSearchPattern
								AND ProtocolID IN (
									SELECT ProtocolID FROM #Result
									)
						END 
						ELSE BEGIN
							INSERT INTO #tmpAltSearch
							SELECT 	ProtocolID
							FROM	ProtocolDrug  pd WITH ( READUNCOMMITTED ) 
									inner join termdrug td WITH ( READUNCOMMITTED )  on td.termid  = pd.drugid
							WHERE 	DrugName like @DrugSearchPattern
								AND ProtocolID IN (
									SELECT ProtocolID FROM #Result
									)
						END
					END
					ELSE BEGIN
						-- 
						IF @TrialStatus	= 'Y'
						BEGIN
							DELETE 	
							FROM 	#tmpAltSearch
							WHERE 	ProtocolID NOT IN (
									SELECT 	ProtocolID
									FROM	vwProtocolDrugActive pd WITH ( READUNCOMMITTED )  
									inner join termdrug td WITH ( READUNCOMMITTED )  on td.termid  = pd.drugid
									WHERE 	DrugName like @DrugSearchPattern
										AND ProtocolID IN (
											SELECT ProtocolID FROM #Result
											)
									)
						END 
						ELSE BEGIN
							DELETE 	
							FROM 	#tmpAltSearch
							WHERE 	ProtocolID NOT IN (
									SELECT 	ProtocolID
									FROM	ProtocolDrug  pd WITH ( READUNCOMMITTED )
									inner join termdrug td WITH ( READUNCOMMITTED ) on td.termid  = pd.drugid
									WHERE 	DrugName like @DrugSearchPattern
										AND ProtocolID IN (
											SELECT ProtocolID FROM #Result
											)
									)
						END
					END
					
					SET @Iteration = @Iteration + 1
				
					FETCH NEXT FROM Drug_Cursor INTO @DrugSearchPattern 
				END
				
				CLOSE Drug_Cursor
				DEALLOCATE Drug_Cursor

				DELETE 	
				FROM 	#Result
				WHERE 	ProtocolID NOT IN (
						SELECT ProtocolID FROM #tmpAltSearch
						)

				SET 	@tmpResultRowCount = @@ROWCOUNT 
			END
			ELSE BEGIN
				-- OR Condition 
				-- PRINT 'Step 625.B - OR Condition'

				IF @TrialStatus	= 'Y'
				BEGIN
					INSERT INTO #tmpAltSearch
					SELECT 	ProtocolID
					FROM	vwProtocolDrugActive AS PD WITH ( READUNCOMMITTED ) 
									inner join termdrug td WITH ( READUNCOMMITTED )  on td.termid  = pd.drugid
						INNER JOIN (		
							SELECT '%' + UPPER( REPLACE( REPLACE( REPLACE( REPLACE( REPLACE( REPLACE( ObjectID, ' ', ''), '-', ''), ',', ''), CHAR(9) ,''), CHAR(10) ,''), CHAR(13) ,'') ) + '%' AS 'DrugSearchPattern'
							--SELECT '%' + UPPER( REPLACE( REPLACE( REPLACE( ObjectID, ' ', ''), '-', ''), ',', '')) + '%' AS 'DrugSearchPattern'
							FROM	dbo.udf_GetDelimiterSeparatedIDs( @Drug, ';' )
							) AS D
						ON 
						td.DrugName like DrugSearchPattern
				END
				ELSE BEGIN
					INSERT INTO #tmpAltSearch
					SELECT 	ProtocolID
					FROM	ProtocolDrug AS PD WITH ( READUNCOMMITTED )  
									inner join termdrug td WITH ( READUNCOMMITTED )  on td.termid  = pd.drugid
						INNER JOIN (		
							SELECT '%' + UPPER( REPLACE( REPLACE( REPLACE( REPLACE( REPLACE( REPLACE( ObjectID, ' ', ''), '-', ''), ',', ''), CHAR(9) ,''), CHAR(10) ,''), CHAR(13) ,'') ) + '%' AS 'DrugSearchPattern'
							--SELECT '%' + UPPER( REPLACE( REPLACE( REPLACE( ObjectID, ' ', ''), '-', ''), ',', '')) + '%' AS 'DrugSearchPattern'
							FROM	dbo.udf_GetDelimiterSeparatedIDs( @Drug, ';' )
							) AS D
						ON 
						td.DrugName like DrugSearchPattern
				END

				DELETE  #Result 
				WHERE  ProtocolID NOT IN (
						SELECT 	ProtocolID
						FROM #tmpAltSearch
						)
	
				SET 	@tmpResultRowCount = @@ROWCOUNT 
			END
			
			-- check for result
			IF 	@ResultRowCount <= @tmpResultRowCount 
			BEGIN
				UPDATE 	ProtocolSearch
				SET 	Requested = Requested + 1,
					IsCachedSearchResultAvailable = 1,
					IsCachedContactsAvailable = 0 
				WHERE 	ProtocolSearchID = @ProtocolSearchID

				EXEC dbo.usp_LogProtocolSearchExecutionTime 
					@ProtocolSearchID = @ProtocolSearchID ,
					@ResultCount = 0,
					@StartTime = @SearchStartTime,
					@Message = 'ZERO Result for parameters: Drug'		

				if @isReRun = 0
				SELECT 	@ProtocolSearchID AS 'ProtocolSearchID',
					0 AS 'ResultCount'

				RETURN
			END 
			
			SET @ResultRowCount = @ResultRowCount - @tmpResultRowCount 
		END
	
		--**********************************
		-- PRINT 'Step 645 - is it @IsNIHClinicalCenterTrial '
		If UPPER(LTRIM(RTRIM( @IsNIHClinicalCenterTrial ))) = 'Y'
		BEGIN
			-- PRINT 'Step 650 - yes it is, Check for NIH Clinical Center Trials'
			DELETE  #Result 
			WHERE  	ProtocolID NOT IN (
					SELECT ProtocolID 
					FROM Protocol WITH ( READUNCOMMITTED )
					WHERE IsNIHClinicalCenterTrial = 1
					)
			SET @tmpResultRowCount = @@ROWCOUNT 
			
			IF 	@ResultRowCount <= @tmpResultRowCount 
			BEGIN
				UPDATE 	ProtocolSearch
				SET 	Requested = Requested + 1,
					IsCachedSearchResultAvailable = 1,
					IsCachedContactsAvailable = 0 
				WHERE 	ProtocolSearchID = @ProtocolSearchID

				EXEC dbo.usp_LogProtocolSearchExecutionTime 
					@ProtocolSearchID = @ProtocolSearchID ,
					@ResultCount = 0,
					@StartTime = @SearchStartTime,
					@Message = 'ZERO Result for parameters: IsNIHClinicalCenter '		
				if @isReRun = 0
				SELECT 	@ProtocolSearchID AS 'ProtocolSearchID',
					0 AS 'ResultCount'

				RETURN
			END
	
			SET @ResultRowCount = @ResultRowCount - @tmpResultRowCount
		END
	
		--**********************************
		-- PRINT 'Step 695 - are we looking for IsNew trials'
		If ISNULL( LTRIM(RTRIM( @IsNew ) ), '') = 'Y'
		BEGIN
			-- PRINT 'Step 700 - yes we are, Check for New Clinical Trials'
			DELETE  #Result 
			WHERE  	ProtocolID NOT IN (
					SELECT ProtocolID 
					FROM Protocol WITH ( READUNCOMMITTED )
					WHERE IsNew = 1
					)
			SET @tmpResultRowCount = @@ROWCOUNT 
			
			IF 	@ResultRowCount <= @tmpResultRowCount 
			BEGIN
				UPDATE 	ProtocolSearch
				SET 	Requested = Requested + 1,
					IsCachedSearchResultAvailable = 1,
					IsCachedContactsAvailable = 0 
				WHERE 	ProtocolSearchID = @ProtocolSearchID

				EXEC dbo.usp_LogProtocolSearchExecutionTime 
					@ProtocolSearchID = @ProtocolSearchID ,
					@ResultCount = 0,
					@StartTime = @SearchStartTime,
					@Message = 'ZERO Result for parameters: IsNew'		
	
				if @isReRun = 0
				SELECT 	@ProtocolSearchID AS 'ProtocolSearchID',
					0 AS 'ResultCount'

				RETURN
			END
	
			SET @ResultRowCount = @ResultRowCount - @tmpResultRowCount
		END
	
		SET 	@Phase	= NULLIF( LTRIM(RTRIM( @Phase )), '' )	
		SET 	@Phase	= NULLIF( LTRIM(RTRIM( @Phase )), 'ALL' )	

		--**********************************
		-- PRINT 	'Step 745 - are we looking for @Phase'
		IF 	@Phase IS NOT NULL 

		BEGIN
			-- PRINT 'Step 750 - yes, Check for Protocol Phase'
			-- Perform Phase Pattern Search 
	
			DELETE  #Result 
			WHERE  ProtocolID NOT IN (
					SELECT 	ProtocolID 
					FROM	ProtocolPhase AS PP WITH ( READUNCOMMITTED )
						INNER JOIN (
							SELECT LTRIM(RTRIM( ObjectID )) AS 'Pattern'
							FROM	udf_GetComaSeparatedIDs( @Phase )
							) AS tmp
							ON case PP.Phase when 1 then 'Phase I' when 2 then 'Phase II' when 3 then 'Phase III' when 4 then 'Phase IV' else ' ' end = tmp.Pattern
					)

			SET @tmpResultRowCount = @@ROWCOUNT 
	
			IF @ResultRowCount <= @tmpResultRowCount 
			--IF @tmpResultRowCount <= 0 
			BEGIN
				UPDATE 	ProtocolSearch
				SET 	Requested = Requested + 1,
					IsCachedSearchResultAvailable = 1,
					IsCachedContactsAvailable = 0 
				WHERE 	ProtocolSearchID = @ProtocolSearchID

				EXEC dbo.usp_LogProtocolSearchExecutionTime 
					@ProtocolSearchID = @ProtocolSearchID ,
					@ResultCount = 0,
					@StartTime = @SearchStartTime,
					@Message = 'ZERO Result for parameters: Phase'		
				if @isReRun = 0
				SELECT 	@ProtocolSearchID AS 'ProtocolSearchID',
					0 AS 'ResultCount'

				RETURN
			END 
			
	
			SET @ResultRowCount = @ResultRowCount - @tmpResultRowCount
		END
	
		--**********************************
		-- PRINT 	'Step 795 - are we looking for @TreatmentType'

		SET  @TreatmentType = NULLIF( LTRIM(RTRIM( @TreatmentType )), '')

		IF @TreatmentType IS NOT NULL 
		BEGIN
			-- PRINT 'Step 800 - yes, Check for Treatment Type'

			DELETE  #Result 
			WHERE  ProtocolID NOT IN (
					SELECT 	ProtocolID
					FROM 	dbo.ProtocolModality WITH 	( READUNCOMMITTED )
					WHERE 	ModalityID IN (
							-- get list of selected modalities
							SELECT 	ObjectID 
							FROM	udf_GetComaSeparatedIDs( @TreatmentType )
						)
					)

			SET 	@tmpResultRowCount =  @@ROWCOUNT 

			IF  @ResultRowCount < = @tmpResultRowCount 
			BEGIN
				UPDATE 	ProtocolSearch
				SET 	Requested = Requested + 1,
					IsCachedSearchResultAvailable = 1,
					IsCachedContactsAvailable = 0 
				WHERE 	ProtocolSearchID = @ProtocolSearchID

				EXEC dbo.usp_LogProtocolSearchExecutionTime 
					@ProtocolSearchID = @ProtocolSearchID ,
					@ResultCount = 0,
					@StartTime = @SearchStartTime,
					@Message = 'ZERO Result for parameters: TreatmentType'		
	
				if @isReRun = 0
				SELECT 	@ProtocolSearchID AS 'ProtocolSearchID',
					0 AS 'ResultCount'

				RETURN
			END
			SET @ResultRowCount = @ResultRowCount - @tmpResultRowCount
		END

		--**********************************
		-- PRINT 	'Step 875 - are we looking for @TrialSponsor'
		SET 	@TrialSponsor	= NULLIF( LTRIM(RTRIM( @TrialSponsor )), 'ALL' )	
		SET 	@TrialSponsor	= NULLIF( RTRIM( @TrialSponsor ), '' )	

		IF 	@TrialSponsor IS NOT NULL 
		BEGIN
			-- PRINT 'Step 880 - yes, Check for Trial Sponsor'

			DELETE  #Result 
			WHERE  ProtocolID NOT IN (
					SELECT 	ProtocolID 
					FROM	dbo.ProtocolSponsors AS PS WITH ( READUNCOMMITTED )
							inner join dbo.udf_getsponsorid(@TrialSponsor) i on ps.sponsorid = i.sponsorid

--							inner join dbo.sponsor s on s.sponsorid  = PS.sponsorid
--						INNER JOIN (
--							SELECT 	LTRIM(RTRIM( ObjectID )) AS 'Pattern'
--							FROM	udf_GetComaSeparatedIDs( @TrialSponsor )
--							) AS tmp
--								ON s.SponsorName = tmp.Pattern 
					)
		
			SET @tmpResultRowCount = @@ROWCOUNT 
			
			IF  @ResultRowCount < = @tmpResultRowCount 
			BEGIN
				UPDATE 	ProtocolSearch
				SET 	Requested = Requested + 1,
					IsCachedSearchResultAvailable = 1,
					IsCachedContactsAvailable = 0 
				WHERE 	ProtocolSearchID = @ProtocolSearchID

				EXEC dbo.usp_LogProtocolSearchExecutionTime 
					@ProtocolSearchID = @ProtocolSearchID ,
					@ResultCount = 0,
					@StartTime = @SearchStartTime,
					@Message = 'ZERO Result for parameters: TrialSponsor'		

				if @isReRun = 0
				SELECT 	@ProtocolSearchID AS 'ProtocolSearchID',
					0 AS 'ResultCount'

				RETURN
			END 
			
			--Delete Protocols which do not meet search creteria
	
			SET @ResultRowCount = @ResultRowCount - @tmpResultRowCount
		END
	
		--*************************************************
		-- PRINT 'Step 900 - Location Search'

		SET 	@City		= NULLIF( RTRIM( LTRIM( @City ) ), '' )	
		SET 	@State		= NULLIF( RTRIM( @State ), '' )	
		SET 	@Country	= NULLIF( RTRIM( @Country ), '' )	
		SET 	@ZIP 		= NULLIF( LEFT( LTRIM(RTRIM( @ZIP )), 5), '')
		SET 	@ZIPProximity 	= NULLIF( @ZIPProximity, 0 )  
		
		IF 	@City IS NOT NULL 
			OR
			@State IS NOT NULL 
			OR

			@Country IS NOT NULL 
			OR 
			@ZIP IS NOT NULL -- if ZIP is NULL the we do not need to checl for @ZIPProximity
		BEGIN
			SET @ContactInfoSearchStatus = 1 -- check description above

			-- Perform other checking because @VAMilitaryOrganization NOT Provided 
			-- **********************************************************************************************************
		
			IF 	@City IS NOT NULL 
				OR
				@State IS NOT NULL 
				OR
				@Country IS NOT NULL 
			BEGIN
				-- PRINT 'Step 1000 - Start Location Search'
				-- PRINT 'Step 1100 - Perform Search by @City, @State, @Country'
			
				IF 	@Country = 'U.S.A.'
					AND @State IS NOT NULL 
				BEGIN
					-- PRINT 'Step 1102 - Country is U.S.A. and State is not null'

					IF @City IS NOT NULL 
					BEGIN
						/***************************************************************************/
						INSERT INTO #ContactInfoResult ( ProtocolID, ProtocolContactInfoID )
						SELECT 	PCI.ProtocolID,
							PCI.ProtocolContactInfoID 
						FROM	vwUSAProtocolcontactinfo AS PCI WITH ( READUNCOMMITTED )
							INNER JOIN udf_GetComaSeparatedIDs( @State ) AS S
								ON S.ObjectID = PCI.State 
								AND PCI.ProtocolID IN (
									SELECT 	ProtocolID
									FROM 	#Result
									)
								AND PCI.City = @City 
								
							-- do check only for given protocols
				
						SET @tmpResultRowCount = @@ROWCOUNT 
						-- PRINT '          - step is done, lets move on'
					END
					ELSE BEGIN
						/***************************************************************************/
						INSERT INTO #ContactInfoResult ( ProtocolID, ProtocolContactInfoID )
						SELECT 	PCI.ProtocolID,
							PCI.ProtocolContactInfoID 
						FROM	(
							SELECT 	ProtocolID,
								ProtocolContactInfoID,
								State  
							FROM 	vwUSAProtocolcontactInfo WITH ( READUNCOMMITTED )
							WHERE 	
								 ProtocolID IN (
									SELECT 	ProtocolID
									FROM 	#Result
									)
							) AS PCI
							INNER JOIN udf_GetComaSeparatedIDs( @State ) AS S
								ON S.ObjectID = PCI.State 
				
						SET @tmpResultRowCount = @@ROWCOUNT 
					END
				END
				ELSE BEGIN
					-- PRINT 'Step 1106 - Country is NON U.S.A.'
					-- select distinct OrganizationRole FROM 	dbo.ProtocolContactInfo	
					INSERT INTO #ContactInfoResult ( ProtocolID, ProtocolContactInfoID )
					SELECT 	ProtocolID,
						ProtocolContactInfoID 
					FROM 	dbo.ProtocolTrialsite	WITH ( READUNCOMMITTED )
					WHERE 	
						
						(
							( @City IS NOT NULL) 
							AND ( LTRIM(RTRIM( City )) = LTRIM(RTRIM( @City )) )
							OR ( @City IS NULL )
						)
						AND
						(
							( @State IS NOT NULL) 
							AND ( LTRIM(RTRIM( StateFullName )) = LTRIM(RTRIM( @State )) )
							OR ( @State IS NULL )
						)
						AND
						(
							( @Country IS NOT NULL) 
							AND ( LTRIM(RTRIM( Country )) = LTRIM(RTRIM( @Country )) )
							OR ( @Country IS NULL )
						)
						AND ProtocolID IN (
							SELECT 	ProtocolID
							FROM 	#Result
							)

			
					SET @tmpResultRowCount = @@ROWCOUNT
				END
			END
		
			--**********************************
			-- PRINT 'Step 1110 - lets check do we need to search by @ZIP'
			IF @ZIP IS NOT NULL
			BEGIN
				-- PRINT '          - yes, then lets Perform Search by @ZIP and by @ZIPProximity'
				IF @ZIPProximity IS NOT NULL
				BEGIN
					PRINT 'Step 1110-A - search by @ZIP and by @ZIPProximity'
					INSERT INTO #ContactInfoResult ( ProtocolID, ProtocolContactInfoID )
					SELECT 	ProtocolID,
						ProtocolContactInfoID 
					FROM 	dbo.udf_GetProximalUSAContactInfo ( @ZIP, @ZIPProximity, @TrialStatus  )
					WHERE 	ProtocolID IN (
							SELECT 	ProtocolID
							FROM 	#Result
							)
						-- make sure that you prevent result from CityStateCountry search 
					SET @tmpResultRowCount = @tmpResultRowCount + @@ROWCOUNT
				END
				ELSE BEGIN
					PRINT 'Step 1110-B - just search by ZIP'
					-- just search by ZIP 
					INSERT INTO #ContactInfoResult ( ProtocolID, ProtocolContactInfoID )
					SELECT 	ProtocolID,
						ProtocolContactInfoID 
					FROM 	dbo.vwUSAProtocolTrialSite WITH ( READUNCOMMITTED )
					WHERE 	ZIP = @ZIP
						AND ProtocolID IN (
							SELECT 	ProtocolID
							FROM 	#Result
							)

					-- make sure that you prevent result from CityStateCountry search 
					SET @tmpResultRowCount = @tmpResultRowCount + @@ROWCOUNT
				END		
			END
			
			IF @tmpResultRowCount <= 0 
			BEGIN
				-- nothing was found
				UPDATE 	ProtocolSearch
				SET 	Requested = Requested + 1,
					IsCachedSearchResultAvailable = 1,
					IsCachedContactsAvailable = 0 
				WHERE 	ProtocolSearchID = @ProtocolSearchID
	
				EXEC dbo.usp_LogProtocolSearchExecutionTime 
					@ProtocolSearchID = @ProtocolSearchID ,
					@ResultCount = 0,
					@StartTime = @SearchStartTime,
					@Message = 'ZERO Result for parameters: City, State, Country, ZIP and ZIPProximity '		

				if @isReRun = 0
				SELECT 	@ProtocolSearchID AS 'ProtocolSearchID',
					0 AS 'ResultCount'

				RETURN
			END 
			
		END

		-- PRINT 'Step 1117 - Check for @Investigator, @LeadOrganization, @Institution' 
		--*************************************************
		SET 	@Investigator 	= NULLIF( LTRIM( @Investigator ), '') 
		SET 	@LeadOrganization 	= NULLIF( LTRIM( @LeadOrganization ), '') 
		SET 	@Institution	= NULLIF( LTRIM( @Institution ), '') 
		
		--**********************************
		-- 11/27/2002 Lakshmi says:
		-- the specs did not indicate limiting to role of Principal Investigator -- the person can be Protocol Chair, 
		-- Protocol Co-chair, Study Coordinator, Research Coordinator, Research Nurse, Principal Investigator or 
		-- Co-Investigator. As Protocol Chair, Rosenberg will be present in the LeadOrgPersonnel element. 
		-- We should be able to use ProtPerson/PersonNameInformation to derive all names irrespective of roles. 
		
		IF 	@Investigator IS NOT NULL
			OR 
			@LeadOrganization IS NOT NULL
			OR 
			@Institution IS NOT NULL
		BEGIN
			SET @ContactInfoSearchStatus = 2 -- check description above
		
			-- PRINT 'Step 1200 - Perform Search by Investigator and Lead Organization'
		
			IF  @LeadOrganization IS NOT NULL
			BEGIN
				-- PRINT '          - (A) we have list of Orgs'
				INSERT INTO #tmpAltContact ( ProtocolID, ProtocolContactInfoID)
				SELECT 	CI.ProtocolID,
					CI.ProtocolContactInfoID
				FROM 	dbo.ProtocolLeadorg AS CI WITH ( READUNCOMMITTED )
					-- outer join changed to inner because we any way doing inner later.
					INNER JOIN dbo.OrganizationName AS AN WITH ( READUNCOMMITTED )
						ON CI.OrganizationID = AN.OrganizationID 
								-- restricted by resulting protocols
						AND CI.ProtocolID IN (
							SELECT 	ProtocolID
							FROM 	#Result
							)
					INNER JOIN ( select REPLACE( ObjectID, '''', '') AS 'ObjectID' from dbo.udf_GetDelimiterSeparatedIDs( @LeadOrganization, ';' )) AS S
						ON LTRIM(RTRIM( REPLACE( AN.[Name], '''', '') )) = LTRIM(RTRIM( S.ObjectID ))
				
				SET  @tmpResultRowCount = @@ROWCOUNT
				IF @tmpResultRowCount = 0 
				BEGIN
					-- no protocols found for provided LeadOrganization parameters
					UPDATE 	ProtocolSearch
					SET 	Requested = Requested + 1,
						IsCachedSearchResultAvailable = 1,
						IsCachedContactsAvailable = 0 
					WHERE 	ProtocolSearchID = @ProtocolSearchID
	
					EXEC dbo.usp_LogProtocolSearchExecutionTime 
						@ProtocolSearchID = @ProtocolSearchID ,
						@ResultCount = 0,
						@StartTime = @SearchStartTime,
						@Message = 'ZERO Result for parameters: Investigator, LeadOrg and Institution '		
	
					if @isReRun = 0
					SELECT 	@ProtocolSearchID AS 'ProtocolSearchID',
						0 AS 'ResultCount'

					RETURN 
				END 
		
			END
			
			IF @Investigator IS NOT NULL
			BEGIN
				-- PRINT '          - (C) and Investigators'
				INSERT INTO #tmpAltContact ( ProtocolID, ProtocolContactInfoID)
				SELECT 	C.ProtocolID,
					C.ProtocolContactInfoID
				FROM	dbo.udf_GetDelimiterSeparatedIDs( @Investigator, ';' ) AS S
					INNER JOIN dbo.vwProtocolInvestigator AS C WITH ( READUNCOMMITTED )
						ON (C.PersonGivenName + ' ' + C.PersonSurName) = LTRIM(RTRIM( S.ObjectID ))
						-- restricted by resulting protocols
						AND C.ProtocolID IN (
							SELECT 	ProtocolID
							FROM 	#Result
							)
		
				SET @tmpResultRowCountTwo = @@ROWCOUNT
				IF @tmpResultRowCountTwo = 0 
				BEGIN
					-- no protocols found for provided investigator parameters
					UPDATE 	ProtocolSearch
					SET 	Requested = Requested + 1,
						IsCachedSearchResultAvailable = 1,
						IsCachedContactsAvailable = 0 
					WHERE 	ProtocolSearchID = @ProtocolSearchID
	
					EXEC dbo.usp_LogProtocolSearchExecutionTime 
						@ProtocolSearchID = @ProtocolSearchID ,
						@ResultCount = 0,
						@StartTime = @SearchStartTime,
						@Message = 'ZERO Result for parameters: Investigator '		
	
					if @isReRun = 0
					SELECT 	@ProtocolSearchID AS 'ProtocolSearchID',
						0 AS 'ResultCount'

					RETURN 
				END 
		
				SET @tmpResultRowCount = @tmpResultRowCount - @tmpResultRowCountTwo
			END	
		
			IF @Institution IS NOT NULL
			BEGIN
				INSERT INTO #tmpAltContact ( ProtocolID, ProtocolContactInfoID)
				SELECT 	CI.ProtocolID, 
					CI.ProtocolContactInfoID
				FROM 	(
					dbo.ProtocolTrialSite AS CI WITH ( READUNCOMMITTED )
					INNER JOIN dbo.OrganizationName AS AN WITH ( READUNCOMMITTED )
						ON CI.OrganizationID = AN.OrganizationID 
						AND CI.OrganizationRole = 3
						-- restricted by resulting protocols
						AND CI.ProtocolID IN (
							SELECT 	ProtocolID
							FROM 	#Result
							)
					) 
					INNER JOIN 	(
							SELECT REPLACE( ObjectID, '''', '' ) AS 'ObjectID'
							FROM dbo.udf_GetDelimiterSeparatedIDs ( @Institution, ';' )
							) AS S
						ON  REPLACE( AN.[Name], '''', '' ) = LTRIM(RTRIM( S.ObjectID ))			
		
				SET @tmpResultRowCountTwo = @@ROWCOUNT
				IF @tmpResultRowCountTwo = 0 
				BEGIN
						-- no protocols found for provided @Institution parameters
					UPDATE 	ProtocolSearch
					SET 	Requested = Requested + 1,
						IsCachedSearchResultAvailable = 1,
						IsCachedContactsAvailable = 0 
					WHERE 	ProtocolSearchID = @ProtocolSearchID
	
					EXEC dbo.usp_LogProtocolSearchExecutionTime 
						@ProtocolSearchID = @ProtocolSearchID ,
						@ResultCount = 0,
						@StartTime = @SearchStartTime,
						@Message = 'ZERO Result for parameters: Institution '		
	
					if @isReRun = 0
					SELECT 	@ProtocolSearchID AS 'ProtocolSearchID',
						0 AS 'ResultCount'

					RETURN 
				END 
		
				SET @tmpResultRowCount = @tmpResultRowCount - @tmpResultRowCountTwo
			END
		END

		-- *******************************************************************
		-- PRINT 'Step 1290 - Check do we need to minimize #ContactInfoSearch subset'
		-- PRINT '          - @ContactInfoSearchStatus must be >= 2 uif we did additional search by @Investigator, @LeadOrganization, @Institution'
		-- PRINT '          - @ContactInfoSearchStatus is ' + convert(varchar, @ContactInfoSearchStatus)


		IF @ContactInfoSearchStatus >= 2
		BEGIN
			-- PRINT '          - yes we need'
			-- PRINT '          - delete protocols that do not match parameters'
			DELETE 	#ContactInfoResult  
			WHERE 	ProtocolID NOT IN 
					(
					SELECT 	ProtocolID 
					FROM 	#tmpAltContact
					)
		
			-- PRINT '          - add new records that was found'
			INSERT 	#ContactInfoResult  ( ProtocolID, ProtocolContactInfoID )
			SELECT 	ProtocolID, 
				ProtocolContactInfoID 
			FROM 	#tmpAltContact
		END

		-- *******************************************************************
		-- PRINT 'Step 1300 - Cache Search Results'

		IF 	NOT @AbstractVersion = 'Professional' 
			OR 
			NOT @AbstractVersion = 'Patient'
		BEGIN
			SET 	@AbstractVersion = 'Professional' 
		END
		
		-- PRINT 'Step 1295 - Check do we need to minimize #Result subset by Cached Contacts '
		IF @ContactInfoSearchStatus <> 0
		BEGIN
			-- PRINT '          - yes we need, lets get protocols that match Cached Contacts '

			INSERT INTO ProtocolSearchSysCache(
				ProtocolSearchID,
				ProtocolID		
				)
			SELECT	
				DISTINCT  	
				@ProtocolSearchID,
				ProtocolID
			FROM 	#ContactInfoResult	

			SET	@ResultRowCount = @@ROWCOUNT

			-- PRINT 'Step 1350 - Cache Contact Info Search Results'

			INSERT INTO ProtocolSearchContactCache(
				ProtocolSearchID,
				ProtocolContactInfoID,
				ProtocolID
				)
			SELECT DISTINCT 
				@ProtocolSearchID,
				ProtocolContactInfoID,
				ProtocolID
			FROM 	#ContactInfoResult  		

		END
		ELSE BEGIN
			-- PRINT 'Step 1350 - no we do not need to minimize #Result subset by Cached Contacts, lets get all data from Result table'
			INSERT INTO ProtocolSearchSysCache(
				ProtocolSearchID,
				ProtocolID
				)
			SELECT	@ProtocolSearchID,
				ProtocolID
			FROM 	#Result

			SET	@ResultRowCount = @@ROWCOUNT
		END
			
		-- PRINT ' Step 9800 - Update Statistics '
		UPDATE 	ProtocolSearch
		SET 	Requested = Requested + 1,
			IsCachedSearchResultAvailable = 1,
			IsCachedContactsAvailable =   @ContactInfoSearchStatus 	
		WHERE 	ProtocolSearchID = @ProtocolSearchID

		-- no protocols found for provided @Institution parameters
		EXEC dbo.usp_LogProtocolSearchExecutionTime 
			@ProtocolSearchID = @ProtocolSearchID ,
			@ResultCount = @ResultRowCount,
			@StartTime = @SearchStartTime,
			@Message = 'Normal Search Execution. Cache data is not used'		
	END
	ELSE BEGIN
		-- PRINT ' Step 9850 - Check how many records in the cache'
		SELECT 	@ResultRowCount = count(*) 
		FROM 	ProtocolSearchSysCache WITH (READUNCOMMITTED)
		WHERE 	ProtocolSearchID = @ProtocolSearchID

		-- PRINT ' Step 9900 - Update Statistics '
		UPDATE 	ProtocolSearch
		SET 	Requested = Requested + 1
		WHERE 	ProtocolSearchID = @ProtocolSearchID

		-- no protocols found for provided @Institution parameters
		EXEC dbo.usp_LogProtocolSearchExecutionTime 
			@ProtocolSearchID = @ProtocolSearchID ,
			@ResultCount = @ResultRowCount,
			@StartTime = @SearchStartTime,
			@Message = 'Fast Search. Re-using cache data'		
	END

	-- PRINT ' Step 9950 - Get result back '

	if @isReRun = 0 
	SELECT 	@ProtocolSearchID AS 'ProtocolSearchID',
		@ResultRowCount AS 'ResultCount'

	--**********************************
END



GO
GRANT EXECUTE ON [dbo].[usp_ProtocolSearchExtended] TO [websiteuser_role]
GO
