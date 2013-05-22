IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_ProtocolSearchExtended_IDadv1]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_ProtocolSearchExtended_IDadv1]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/****** Object:   dbo.usp_ProtocolSearchExtended_IDadv1    Script Date: 9/6/2005 3:20:00 PM ******/
/*	NCI - National Cancer Institute
*	
*	File Name:	
*	usp_ProtocolSearchExtended_IDadv1.sql
*
*	CT search using ID and Link	
*	Objects Used:
*	
*	Change History:
*	9/9/2005 		Min	Script Created
*	To Do:
*
*/
CREATE PROCEDURE usp_ProtocolSearchExtended_IDadv1
	(	

	@IDstringHash int =  null,
	@isLInk bit = null,
 	@DrugID 		varchar(8000)	= NULL,  	-- (+) coma separated list of CDR IDs
	@InstitutionID		varchar(8000)	= NULL,  	-- (+) coma separated list of ID 
	@InvestigatorID		varchar(8000)	= NULL,  	-- (+) coma separated list of ID 
	@LeadOrganizationID	varchar(8000)	= NULL,  	-- (+) coma separated list of ID 
	@idstring varchar(8000)	= NULL,  
	--@format  = NULL,
	@CancerType 		varchar(8000) 	= NULL,  	-- (+) coma separated list of CDR IDs
 	@CancerTypeStage 	varchar(8000) 	= NULL,  	-- (+) coma separated list of CDR IDs
	@TrialType 		varchar(100) = NULL,
	@TrialStatus		char(1) 	= 'Y', 		-- (+) "Y" - Active, "N" - Closed
	@IsNIHClinicalCenterTrial char(1)	= NULL, 		-- (+) "Y" means isNIH ("N" and NULL - meand does not matter)
	@IsNew			char(1)		= NULL, 		-- (+) "Y" means new ("N" and NULL - meand does not matter)
	@DrugSearchFormula	varchar(100)	= 'OR',  	-- 'OR' - default, 'AND' - drug combination
	@Phase		varchar(100)	= NULL,  	-- (+) coma separated list of string
	

	@AlternateProtocolID	varchar(8000)	= NULL,  	-- (+) coma separated list of Protocol IDs
	@ZIP			varchar(10)	= NULL,		-- (+) 00000-0000
	@ZIPProximity		int		= NULL,		-- proximity mile radius
	@City			varchar(50)	= NULL,		-- (+) city 
	@State			varchar(50)	= NULL,		-- (+) state
	@Country		varchar(50)	= NULL,		-- (+) country

	@VAMilitaryOrganization	varchar(8000)	= NULL,  	

	@TrialSponsor		varchar(8000)	= NULL,  	-- (+) coma separated list of string
	@SpecialCategory varchar(1000) = null  ,
	@drug varchar(8000)	= NULL,
	@Institution  varchar(8000)	= NULL,		
	@Investigator  varchar(8000)	= NULL,		
	@LeadOrganization varchar(8000)	= NULL,
	@treatmenttype varchar(8000)	= NULL,

	@AbstractVersion	varchar(50)	= 'Professional', -- (+) Professional or Patient

	@ParameterOne		varchar(8000)	= NULL,  	-- reserved parameter "SimpleSearch" 
	@ParameterTwo		varchar(8000)	= NULL,  	-- reserved parameter
	@ParameterThree		varchar(8000)	= NULL,  	-- reserved parameter

	@ReportMessage 		varchar(8000) = '' OUTPUT, 	-- (+) returns nothing "" or message discribed why we get zero result.
	@ProtocolSearchID	int = NULL OUTPUT, 		-- (+) returns search ID which identifies search 
	@ShowDetailReportMessage  char(1)	= 'N',	  	-- Show Detail Report Message. 
	@GetCachedSearchResult	bit = 1,		-- If set to '1' than function will get cached search result 
			-- if possible, otherwise search will be performed. If set to 
							-- '0' than search will be performed and cache data 
						-- will be updated.  
	@isReRun bit = 0


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
		@SysProtocolSearchID int,
		@IDstring_stepOne varchar(8000),
		@searchtype varchar(50),
		@diagnosisid varchar(8000)


		
		
	

	--**********************************
	-- PRINT 'Step 100 - Create temporary tables'
	create table #Result (
		ProtocolID	int		-- CDRProtocolID
	)
	
	
	--table will include Protocols found by Alternate IDs 
	create table #tmpAltSearch  (
		ProtocolID int
	)

	create table #intervention
	(protocolid int primary key)

	set @diagnosisid = COALESCE(@cancerTYpestage, @cancerType)


	

	--**********************************
	-- PRINT 	'Step 55 - Set values'
	SET 	@tmpDelimeter = ','
	SET 	@ContactInfoSearchStatus = 0 	-- 0 - no serch was performed
						-- 1 - City, State, Country, Zip, Zip Proximity
						-- 2 - Investigator, LeadOrganization, Institution
	SET 	@SearchStartTime = GETDATE()
	SET 	@SysProtocolSearchID = NULL
	

	--table will include Protocols found by Alternate IDs 
	declare @tmpAltContact table (
		ProtocolID int,
		ProtocolContactInfoID int
	)

	declare @ContactInfoResult table (
		ProtocolID int,
		ProtocolContactInfoID	int		
	)
	declare @isClosedAlternateIDonly bit 
	set @isClosedAlternateIDonly = 0
	--**********************************
	--PRINT 'Step 150 - Log ProtocolSearch: usp_SaveProtocolSearchParameters_AdvID'  


		EXEC dbo.usp_SaveProtocolSearchParameters_AdvID
		@CancerType = @cancertype, 
	 	@CancerTypeStage =@cancerTypeStage, 
		@trialType = @trialtype,
		@TrialStatus = @TrialStatus, 		
		@InstitutionID = @InstitutionID,  		
		@InvestigatorID = @InvestigatorID,  		
		@LeadOrganizationID = @LeadOrganizationID,  	
		@IsNIHClinicalCenterTrial = @IsNIHClinicalCenterTrial,
		@IsNew = @IsNew,
		@TreatmentType = @TreatmentType,
		@DrugSearchFormula = @DrugSearchFormula,
	 	@DrugID = @DrugID,
		@Phase = @Phase,
		@AbstractVersion = @AbstractVersion,
		@ParameterOne = @ParameterOne,		
		@ParameterTwo = @ParameterTwo,
		@ParameterThree = @ParameterThree,
		@idstring = @idstring,
		@ShowDetailReportMessage = @ShowDetailReportMessage,
		@SearchType = @searchType, 
		@CheckCache = @GetCachedSearchResult, -- '1' if we need to perform search for available Cache result
		@IsCachedSearchResultAvailable = @IsCachedSearchResultAvailable OUTPUT,  	-- '1' If Cashed Search Result available
		@ProtocolSearchID = @ProtocolSearchID OUTPUT 	,	-- Input/Output parameters returns search ID which identifies search, if provided together with @CheckCache than, cache will be checked for data availability  
		@AlternateProtocolID=@AlternateProtocolID,  	
		@zip=@ZIP,	
		@ZIPProximity=@ZIPProximity,	
		@city =@City,	
		@state=@State,	
		@country=@Country,	
		@VAMilitaryOrganization=@VAMilitaryOrganization	,  	
		@TrialSponsor=@TrialSponsor,
		@SpecialCategory = @SpecialCategory,
		@drug = @drug,
		@Institution  = @institution,
		@Investigator  = @investigator,
		@LeadOrganization = @LeadOrganization,
		@isLInk = @isLInk,
		@IDstringHash = @IDstringHash

		
		

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
			--PRINT 'Step 180 - Clean the cache if we inforced to refine search'

			DELETE 	dbo.ProtocolSearchSysCache
			WHERE 	ProtocolSearchID = @ProtocolSearchID

			DELETE 	dbo.ProtocolSearchContactCache
			WHERE 	ProtocolSearchID = @ProtocolSearchID
		END


		--**********************************
		 --PRINT 'Step 200 - Set defaul values'
		SET 	@ResultRowCount = 0


		-- Active or clesed Statuses always exists so we will not monitore resultset for them
		-- But we will do it for all other criterial

		SET 	@TrialStatus 	= ISNULL( NULLIF( RTRIM(LTRIM(@TrialStatus)), ''), 'Y' )			
		SET 	@TrialType 	= nullif(RTRIM(LTRIM(@TrialType)),'ALL') 
		SET 	@DiagnosisID 	= NULLIF( LTRIM( @DiagnosisID ), '' )	






if 
		(@trialType = 'ALL' or @trialType  is null )
		and (@TrialStatus = 'N' )
		and  (@IsNIHClinicalCenterTrial = 'N' or @IsNIHClinicalCenterTrial is NULL)
		and (@IsNew = 'N' or @isNew  is null)
		and (@AlternateProtocolID is not NULL)
		and 
		(COALESCE(@CancerType, 
	 	@CancerTypeStage , 
		@TreatmentType ,
		@Phase ,
		@zip,	
		@city ,	
		@state,	
		@country,
		@TrialSponsor,
		@SpecialCategory,
		@drug ,
		@Institution  ,
		@Investigator ,
		@LeadOrganization) is null)
			set @isClosedAlternateIDOnly  = 1 

		if @isClosedAlternateIDOnly = 1
		begin 
			print 'alter ONLY search'
			IF 	NULLIF( CHARINDEX( ';', @AlternateProtocolID ), 0 ) 
							IS NOT NULL 
						BEGIN
							SET @tmpDelimeter = ';'
						END
						ELSE BEGIN
							SET @tmpDelimeter = ','
						END
			declare @alterResult table (ProtocolID int )
			insert into @alterResult 
			select distinct p.protocolid from dbo.protocol p  WITH ( READUNCOMMITTED )  inner join dbo.protocolAlternateid a WITH ( READUNCOMMITTED )  on p.protocolid  = a.protocolid
					inner join
						(SELECT '%'
						+ REPLACE( REPLACE( LTRIM(RTRIM( ObjectID )), ' ', ''), '-', '')  
						+ '%' 
						AS 'Pattern'	
					FROM dbo.udf_GetDelimiterSeparatedIDs ( @AlternateProtocolID, @tmpDelimeter )
					) AS tmpID
					ON REPLACE( REPLACE( IDString, ' ', ''), '-', '') like Pattern
				where isActiveprotocol  = 0  --AND IDType NOT IN ('GUID', 'CDRKey', 'PDQKey')

			SET 	@ResultRowCount = @@ROWCOUNT

			if  @ResultRowCount = 0
			begin
				UPDATE  dbo.ProtocolSearch
				SET 	Requested = Requested + 1,
					IsCachedSearchResultAvailable = 1,
					IsCachedContactsAvailable = 0 
				WHERE 	ProtocolSearchID = @ProtocolSearchID
	
				EXEC dbo.usp_LogProtocolSearchExecutionTime 
					@ProtocolSearchID = @ProtocolSearchID ,
					@ResultCount = 0,
					@StartTime = @SearchStartTime,
					@Message = 'ZERO Result for parameters: AnternateProtocolID'		
					
			end
			else
			begin
				-- PRINT 'Step 1350 - no we do not need to minimize #result subset by Cached Contacts, lets get all data from Result table'
				INSERT INTO dbo.ProtocolSearchSysCache WITH (rowlock) (
					ProtocolSearchID,
					ProtocolID
					) 
				SELECT	@ProtocolSearchID,
					ProtocolID
				FROM 	@alterResult
	
				SET	@ResultRowCount = @@ROWCOUNT
							
				-- PRINT ' Step 9800 - Update Statistics '
				UPDATE  dbo.ProtocolSearch
				SET 	Requested = Requested + 1,
				IsCachedSearchResultAvailable = 1,
				IsCachedContactsAvailable =   @ContactInfoSearchStatus 	
				WHERE 	ProtocolSearchID = @ProtocolSearchID
	
				-- no protocols found for provided @InstitutionID parameters
				EXEC dbo.usp_LogProtocolSearchExecutionTime 
				@ProtocolSearchID = @ProtocolSearchID ,
				@ResultCount = @ResultRowCount,
				@StartTime = @SearchStartTime,
				@Message = 'Normal Search Execution. Cache data is not used'	
				
		
			end	
			if @isReRun = 0 
			SELECT 	@ProtocolSearchID AS 'ProtocolSearchID',
				@ResultRowCount AS 'ResultCount'
			return

		end 







		--**********************************
		-- PRINT 'Step 205 - Run usp_ProtocolSearchSys_StepOne1 to get System Cache'
		
		
		set @IDstring_stepOne =  isnull(@diagnosisid,'') + '&T='+ isnull(@TrialType,'ALL') + '&C=' + @trialStatus

		
		

		
		EXEC dbo.usp_ProtocolSearchSys_StepOneID1 
			@IDstring = @IDstring_stepOne,
			@cancertype = @cancerType,
			@cancertypeStage = @cancerTypeStage,						
			@TrialType = @TrialType,
			@TrialStatus = @TrialStatus,
			@GetCachedSearchResult = @GetCachedSearchResult,
			@SysProtocolSearchID = @sysProtocolSearchID OUTPUT,
			@ResultRowCount	= @ResultRowCount OUTPUT	



		-- Find out howm many rows we have in resultset
		IF @ResultRowCount <= 0
		BEGIN
			UPDATE 	dbo.ProtocolSearch
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

			INSERT INTO #result 		
			SELECT 	ProtocolID 
			FROM 	dbo.ProtocolSearchSysCache WITH (READUNCOMMITTED)
			WHERE 	ProtocolSearchID = @SysProtocolSearchID
		END




		--**********************************
		-- PRINT 'Step 510 - do we have any SpecialCategory' 

		SET 	@SpecialCategory	= NULLIF( LTRIM(RTRIM( @SpecialCategory )), 'ALL' )	
		SET 	@SpecialCategory	= NULLIF( RTRIM( @SpecialCategory ), '' )	

		

		IF @SpecialCategory is not null
		BEGIN
		--**********************************
		-- PRINT 'Step 511 - yes we do, lets check for SpecialCategory
			declare @specialCategoryProtocolids table (protocolid int)
			insert into @specialCategoryProtocolids 
			SELECT	ProtocolID
					FROM	dbo.protocolSpecialCategory  PSC WITH ( READUNCOMMITTED ) 
					INNER JOIN (
						SELECT 	LTRIM(RTRIM( objectID )) AS 'Pattern'
						FROM	dbo.udf_GetComaSeparatedIDs( @SpecialCategory )
						) AS tmp
						ON PSC.protocolSpecialCategory = tmp.Pattern 
			DELETE  #Result 
				WHERE  ProtocolID NOT IN (select protocolid from @specialCategoryProtocolids)

				SET @tmpResultRowCount = @@ROWCOUNT 



			--PRINT 'Clinicalt Rtials not found for provided SC'		
			IF 	@ResultRowCount <= @tmpResultRowCount 
			BEGIN
				UPDATE 	dbo.ProtocolSearch
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


		--**********************************
		-- PRINT 'Step 520 - Ok we got ' + convert(varchar, @ResultRowCount )+ ' trials back '  
		 --PRINT 'Step 530 - do we have any AlternateProtocolIDs'

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

			declare @alternateIDprotocolIDS table (protocolid int)
			IF @TrialStatus	= 'Y'
			BEGIN
				
				insert into @alternateIDprotocolIDS
				SELECT	ProtocolID
						FROM	dbo.vwProtocolAlternateIDActive AS PID WITH ( READUNCOMMITTED ) 
							INNER JOIN (
								SELECT '%' 
									+ REPLACE( REPLACE( LTRIM(RTRIM( ObjectID )), ' ', ''), '-', '')  
									+ '%' 
									AS 'Pattern'	
								FROM dbo.udf_GetDelimiterSeparatedIDs ( @AlternateProtocolID, @tmpDelimeter )
								) AS tmpID
								ON REPLACE( REPLACE( IDString, ' ', ''), '-', '') like Pattern
				DELETE  #Result 
				WHERE  ProtocolID NOT IN (select protocolid from @alternateIDprotocolIDS)
	
				SET @tmpResultRowCount = @@ROWCOUNT 


			END
			ELSE BEGIN
					insert into @alternateIDprotocolIDS
				SELECT	ProtocolID
						FROM	dbo.ProtocolAlternateID AS PID WITH ( READUNCOMMITTED ) 
							INNER JOIN (
								SELECT '%' 
									+ REPLACE( REPLACE( LTRIM(RTRIM( ObjectID )), ' ', ''), '-', '')  
									+ '%' 
									AS 'Pattern'	
								FROM dbo.udf_GetDelimiterSeparatedIDs ( @AlternateProtocolID, @tmpDelimeter )
								) AS tmpID
								ON REPLACE( REPLACE( IDString, ' ', ''), '-', '') like Pattern
				DELETE  #Result 
				WHERE  ProtocolID NOT IN (select protocolid from @alternateIDprotocolIDS)

				SET @tmpResultRowCount = @@ROWCOUNT 

			END

			--PRINT 'Clinicalt Rtials not found for provided Altid'		
			IF 	@ResultRowCount <= @tmpResultRowCount 
			BEGIN
				UPDATE  dbo.ProtocolSearch
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
		 --PRINT 'Step 620 - do we have any Drug'
		IF ISNULL( LTRIM(RTRIM( @DrugID )), '') <> '' 
		BEGIN
			-- PRINT 'Step 625 - yes we do, Check for Drugs: ' + @DrugID
			-- by Default we will have 'OR'
			SET @DrugSearchFormula = UPPER( LTRIM(RTRIM(@DrugSearchFormula)) ) 
		

			IF @DrugSearchFormula = 'AND'
				

			BEGIN
				 --PRINT 'Step 625.B - AND Condition'
					

				set 	@Iteration = 1
				
				DECLARE Drug_Cursor CURSOR FOR 
					SELECT objectid AS 'DrugSearchPattern'
					FROM	dbo.udf_GetComaSeparatedIDs( @DrugID )
				
				OPEN Drug_Cursor
				FETCH NEXT FROM Drug_Cursor INTO @DrugSearchPattern 
			
				WHILE @@FETCH_STATUS = 0
				BEGIN
					 
					IF @Iteration = 1 
					BEGIN
						-- Prepopulate Initial Protocol Drug Result  
						IF @TrialStatus	= 'Y'
						BEGIN
							INSERT INTO #tmpAltSearch
							SELECT 	distinct ProtocolID
							FROM	dbo.vwProtocolDrugActive WITH ( READUNCOMMITTED )
							WHERE 	DrugID = @DrugSearchPattern
								AND ProtocolID IN (
									SELECT ProtocolID FROM #result
									)
						END 
						ELSE BEGIN
							INSERT INTO #tmpAltSearch
							SELECT distinct	ProtocolID
							FROM	dbo.ProtocolDrug WITH ( READUNCOMMITTED )
							WHERE 	DrugID = @DrugSearchPattern
								AND ProtocolID IN (
									SELECT ProtocolID FROM #result
									)
						END

					END
					ELSE BEGIN

						IF @TrialStatus	= 'Y'
						BEGIN
							DELETE 	
							FROM 	#tmpAltSearch
							WHERE 	ProtocolID NOT IN (
									SELECT 	distinct ProtocolID
									FROM	dbo.vwProtocolDrugActive WITH ( READUNCOMMITTED )
									WHERE 	DrugID = @DrugSearchPattern
										AND ProtocolID IN (
											SELECT ProtocolID FROM #result
											)
									)
						END 
						ELSE BEGIN
							DELETE 	
							FROM 	#tmpAltSearch
							WHERE 	ProtocolID NOT IN (
									SELECT 	distinct ProtocolID
									FROM	dbo.ProtocolDrug WITH ( READUNCOMMITTED )
									WHERE 	DrugID = @DrugSearchPattern
										AND ProtocolID IN (
											SELECT ProtocolID FROM #result
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
				FROM 	#result
				WHERE 	ProtocolID NOT IN (
						SELECT ProtocolID FROM #tmpAltSearch
						)

				SET 	@tmpResultRowCount = @@ROWCOUNT 
			END
			ELSE BEGIN
				-- OR Condition 
				--PRINT 'Step 625.B - OR Condition'

				IF @TrialStatus	= 'Y'
				BEGIN
					INSERT INTO #tmpAltSearch
					SELECT 	distinct ProtocolID
					FROM	dbo.vwProtocolDrugActive AS PD WITH ( READUNCOMMITTED )
						INNER JOIN (		
							SELECT objectid AS 'DrugSearchPattern'
							FROM	dbo.udf_GetComaSeparatedIDs( @DrugID )
							) AS D
						ON 
						DrugID = DrugSearchPattern
				END
				ELSE BEGIN
					INSERT INTO #tmpAltSearch
					SELECT 	distinct ProtocolID
					FROM	dbo.ProtocolDrug AS PD WITH ( READUNCOMMITTED )
						INNER JOIN (		
							SELECT objectid AS 'DrugSearchPattern'
							FROM	dbo.udf_GetComaSeparatedIDs( @DrugID )
							) AS D
						ON 
						DrugID = DrugSearchPattern
				END
				
			
				DELETE  #result 
				WHERE  ProtocolID NOT IN (
						SELECT 	ProtocolID
						FROM #tmpAltSearch
						)
	
				SET 	@tmpResultRowCount = @@ROWCOUNT 
			--print 'after drug, @tmpResultRowCount  ' + convert(varchar,isnull(@tmpResultRowCount,0),100)
			END
			
			-- check for result
			IF 	@ResultRowCount <= @tmpResultRowCount 
			BEGIN
				UPDATE  dbo.ProtocolSearch
				SET 	Requested = Requested + 1,
					IsCachedSearchResultAvailable = 1,
					IsCachedContactsAvailable = 0 
				WHERE 	ProtocolSearchID = @ProtocolSearchID

				EXEC dbo.usp_LogProtocolSearchExecutionTime 
					@ProtocolSearchID = @ProtocolSearchID ,
					@ResultCount = 0,
					@StartTime = @SearchStartTime,
					@Message = 'ZERO Result for parameters: DrugID'		

				if @isReRun = 0 
				SELECT 	@ProtocolSearchID AS 'ProtocolSearchID',
					0 AS 'ResultCount'

				RETURN
			END 
			
			SET @ResultRowCount = @ResultRowCount - @tmpResultRowCount 
			--print 'after drug, @ResultRowCount  ' + convert(varchar,isnull(@ResultRowCount,0),100)

		END


		--**********************************
		-- PRINT 'Step 645 - is it @IsNIHClinicalCenterTrial '
		If @IsNIHClinicalCenterTrial= 'Y'
		BEGIN
			-- PRINT 'Step 650 - yes it is, Check for NIH Clinical Center Trials'
			DELETE  #result 
			WHERE  	ProtocolID NOT IN (
					SELECT ProtocolID 
					FROM dbo.Protocol WITH ( READUNCOMMITTED )
					WHERE IsNIHClinicalCenterTrial = 1
					)
			SET @tmpResultRowCount = @@ROWCOUNT 
			
			IF 	@ResultRowCount <= @tmpResultRowCount 
			BEGIN
				UPDATE  dbo.ProtocolSearch
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
			--print 'after nih, @ResultRowCount  ' + convert(varchar,isnull(@ResultRowCount,0),100)
		END

		--**********************************
		-- PRINT 'Step 695 - are we looking for IsNew trials'
		If @IsNEw = 'Y'
		BEGIN
			-- PRINT 'Step 700 - yes we are, Check for New Clinical Trials'
			DELETE  #result 
			WHERE  	ProtocolID NOT IN (
					SELECT ProtocolID 
					FROM dbo.Protocol WITH ( READUNCOMMITTED )
					WHERE IsNew = 1
					)
			SET @tmpResultRowCount = @@ROWCOUNT 
			
			IF 	@ResultRowCount <= @tmpResultRowCount 
			BEGIN
				UPDATE  dbo.ProtocolSearch
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
					FROM	ProtocolPhase  ( READUNCOMMITTED )
						where phase in
							(SELECT  case  ObjectID when 'phase I' then 1 when 'phase II' then 2 when 'phase III' then 3 when 'phase IV' then 4 else null end
							FROM	dbo.udf_GetComaSeparatedIDs(@Phase)
							) 
							
					)

			SET @tmpResultRowCount = @@ROWCOUNT 
	
			IF @ResultRowCount <= @tmpResultRowCount 
			--IF @tmpResultRowCount <= 0 
			BEGIN
				UPDATE  dbo.ProtocolSearch
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

		--print 'after phase, @ResultRowCount  ' + convert(varchar(100),isnull(@ResultRowCount,0))
		END

	
		--**********************************
		-- PRINT 	'Step 795 - are we looking for @TreatmentType'

		SET  @TreatmentType = NULLIF( LTRIM(RTRIM( @TreatmentType )), '')

		IF @TreatmentType IS NOT NULL 
		BEGIN
			-- PRINT 'Step 800 - yes, Check for Treatment Type'

		insert into #intervention
		SELECT distinct	ProtocolID
					FROM 	dbo.ProtocolModality WITH 	( READUNCOMMITTED )
					WHERE 	ModalityID IN (
							-- get list of selected modalities
							SELECT 	objectid
							FROM	dbo.udf_GetComaSeparatedIDs( @TreatmentType ) 
							)
							

			DELETE  #result 
			WHERE  ProtocolID NOT IN (select protocolid from #intervention)
			

			SET 	@tmpResultRowCount =  @@ROWCOUNT 

			IF  @ResultRowCount < = @tmpResultRowCount 
			BEGIN
				UPDATE  dbo.ProtocolSearch
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
			declare		@sponsorProtocolIDs table (protocolid int)
			insert into @sponsorProtocolIDs
			SELECT 	 ProtocolID 
					FROM	dbo.ProtocolSponsors  ( READUNCOMMITTED )
						where SponsorID in
							(SELECT  sponsorid 
							FROM	dbo.udf_getsponsorID(@trialSponsor)
							) 

			DELETE  #Result 
			WHERE  ProtocolID NOT IN (select protocolid from @sponsorProtocolIDs)
									
					
		
			SET @tmpResultRowCount = @@ROWCOUNT 
			
			IF  @ResultRowCount < = @tmpResultRowCount 
			BEGIN
				UPDATE  dbo.ProtocolSearch
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
				 --PRINT 'Step 1100 - Perform Search by @City, @State, @Country'
			
				IF 	@Country = 'U.S.A.'
					AND @State IS NOT NULL 
				BEGIN
					-- PRINT 'Step 1102 - Country is U.S.A. and State is not null'

					IF @City IS NOT NULL 
					BEGIN
						/***************************************************************************/
						INSERT INTO @ContactInfoResult ( ProtocolID, ProtocolContactInfoID )
						SELECT 	PCI.ProtocolID,
							PCI.ProtocolContactInfoID 
						FROM	dbo.vwUSAProtocolcontactInfo AS PCI WITH ( READUNCOMMITTED )
							INNER JOIN dbo.udf_GetComaSeparatedIDs( @State ) AS S
								ON S.ObjectID = PCI.State 
								AND PCI.ProtocolID IN (
									SELECT 	ProtocolID
									FROM 	#Result
									)
								AND PCI.City = @City 
								--AND PCI.OrganizationRole NOT IN ( 'Primary', 'Secondary' )
							-- do check only for given protocols
				
						SET @tmpResultRowCount = @@ROWCOUNT 
						-- PRINT '          - step is done, lets move on'
					END
					ELSE BEGIN
						/***************************************************************************/
						INSERT INTO @ContactInfoResult ( ProtocolID, ProtocolContactInfoID )
						SELECT 	PCI.ProtocolID,
							PCI.ProtocolContactInfoID 
						FROM	(
							SELECT 	ProtocolID,
								ProtocolContactInfoID,
								State  
							FROM 	dbo.vwUSAProtocolcontactInfo WITH ( READUNCOMMITTED )
							WHERE 	--OrganizationRole NOT IN ( 'Primary', 'Secondary' ) AND
								 ProtocolID IN (
									SELECT 	ProtocolID
									FROM 	#Result
									)
							) AS PCI
							INNER JOIN dbo.udf_GetComaSeparatedIDs( @State ) AS S
								ON S.ObjectID = PCI.State 
				
						SET @tmpResultRowCount = @@ROWCOUNT 
					END
				END
				ELSE BEGIN
					-- PRINT 'Step 1106 - Country is NON U.S.A.'
					-- select distinct OrganizationRole FROM 	dbo.ProtocolContactInfo	
					INSERT INTO @ContactInfoResult ( ProtocolID, ProtocolContactInfoID )
					SELECT 	ProtocolID,
						ProtocolContactInfoID 
					FROM 	dbo.ProtocolTrialSite	WITH ( READUNCOMMITTED )
					WHERE 	-- OrganizationRole NOT IN ( 'Primary', 'Secondary' ) AND
						
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
				PRINT '          - yes, then lets Perform Search by @ZIP and by @ZIPProximity'
				
				IF @ZIPProximity IS NOT NULL
				BEGIN
					--PRINT 'Step 1110-A - search by @ZIP and by @ZIPProximity'
					INSERT INTO @ContactInfoResult ( ProtocolID, ProtocolContactInfoID )
					SELECT 	ProtocolID,
						ProtocolContactInfoID 
					FROM 	dbo.udf_GetProximalUSAContactInfo ( @ZIP, @ZIPProximity, @trialStatus )
					WHERE 	ProtocolID IN (
							SELECT 	ProtocolID
							FROM 	#Result
							)

					-- make sure that you prevent result from CityStateCountry search 
					SET @tmpResultRowCount = @tmpResultRowCount + @@ROWCOUNT  --why?



				END
				ELSE BEGIN
				--	PRINT 'Step 1110-B - just search by ZIP'
					-- just search by ZIP 
					INSERT INTO @ContactInfoResult ( ProtocolID, ProtocolContactInfoID )
					SELECT 	ProtocolID,
						ProtocolContactInfoID 
					FROM 	dbo.vwUSAProtocolcontactInfo WITH ( READUNCOMMITTED )
					WHERE 	--OrganizationRole NOT IN ( 'Primary', 'Secondary' ) and
						 ZIP = @ZIP
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
				UPDATE  dbo.ProtocolSearch
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




	
		--*************************************************

		-- PRINT 'Step 1117 - Check for @InvestigatorID, @LeadOrganizationID, @InstitutionID' 
		--*************************************************
		SET 	@InvestigatorID 	= NULLIF( LTRIM( @InvestigatorID ), '') 
		SET 	@LeadOrganizationID 	= NULLIF( LTRIM( @LeadOrganizationID ), '') 
		SET 	@InstitutionID	= NULLIF( LTRIM( @InstitutionID ), '') 
		
				
		IF 	@InvestigatorID IS NOT NULL
			OR 
			@LeadOrganizationID IS NOT NULL
			OR 
			@InstitutionID IS NOT NULL
		BEGIN
			SET @ContactInfoSearchStatus = 2 -- check description above
		
		--	 PRINT 'Step 1200 - Perform Search by Investigator and Lead Organization'
		
			IF  @LeadOrganizationID IS NOT NULL
			BEGIN
				-- PRINT '          - (A) we have list of Orgs'
				INSERT INTO @tmpAltContact ( ProtocolID, ProtocolContactInfoID)
				SELECT 	CI.ProtocolID,
					CI.ProtocolContactInfoID
				FROM 	dbo.ProtocolLeadorg AS CI WITH ( READUNCOMMITTED )
						INNER JOIN dbo.udf_GetComaSeparatedIDs( @LeadOrganizationID) AS S
						ON CI.organizationID = LTRIM(RTRIM( S.ObjectID ))
				where 	--CI.OrganizationRole IN ( 'Primary', 'Secondary') and
						-- restricted by resulting protocols
						 CI.ProtocolID IN (
							SELECT 	ProtocolID
							FROM 	#result
							)
				
				SET  @tmpResultRowCount = @@ROWCOUNT
				IF @tmpResultRowCount = 0 
				BEGIN
					-- no protocols found for provided LeadOrganization parameters
					UPDATE  dbo.ProtocolSearch
					SET 	Requested = Requested + 1,
						IsCachedSearchResultAvailable = 1,
						IsCachedContactsAvailable = 0 
					WHERE 	ProtocolSearchID = @ProtocolSearchID
	
					EXEC dbo.usp_LogProtocolSearchExecutionTime 
						@ProtocolSearchID = @ProtocolSearchID ,
						@ResultCount = 0,
						@StartTime = @SearchStartTime,
						@Message = 'ZERO Result for parameters: InvestigatorID, LeadOrgID and InstitutionID '		
					if @isReRun = 0 
					SELECT 	@ProtocolSearchID AS 'ProtocolSearchID',
						0 AS 'ResultCount'

					RETURN 
				END 
		
			END
			
			IF @InvestigatorID IS NOT NULL
			BEGIN
				-- PRINT '          - (C) and Investigators'
				INSERT INTO @tmpAltContact ( ProtocolID, ProtocolContactInfoID)
				SELECT 	C.ProtocolID,
					C.ProtocolContactInfoID
				FROM	dbo.udf_GetComaSeparatedIDs( @InvestigatorID ) AS S
					INNER JOIN dbo.vwprotocolInvestigator AS C WITH ( READUNCOMMITTED )
						on c.personid = s.objectid
								-- restricted by resulting protocols
						AND C.ProtocolID IN (
							SELECT 	ProtocolID
							FROM 	#result
							)
		
				SET @tmpResultRowCountTwo = @@ROWCOUNT
				IF @tmpResultRowCountTwo = 0 
				BEGIN
					-- no protocols found for provided investigator parameters
					UPDATE  dbo.ProtocolSearch
					SET 	Requested = Requested + 1,
						IsCachedSearchResultAvailable = 1,
						IsCachedContactsAvailable = 0 
					WHERE 	ProtocolSearchID = @ProtocolSearchID
	
					EXEC dbo.usp_LogProtocolSearchExecutionTime 
						@ProtocolSearchID = @ProtocolSearchID ,
						@ResultCount = 0,
						@StartTime = @SearchStartTime,
						@Message = 'ZERO Result for parameters: InvestigatorID '		
			
					if @isReRun = 0 
					SELECT 	@ProtocolSearchID AS 'ProtocolSearchID',
						0 AS 'ResultCount'

					RETURN 
				END 
		
				SET @tmpResultRowCount = @tmpResultRowCount - @tmpResultRowCountTwo
			END	
		
			IF @InstitutionID IS NOT NULL
			BEGIN
				
				INSERT INTO @tmpAltContact ( ProtocolID, ProtocolContactInfoID)
				SELECT 	CI.ProtocolID, 
					CI.ProtocolContactInfoID
				FROM 	(
					dbo.ProtocolTrialSite AS CI WITH ( READUNCOMMITTED )
					INNER JOIN 	 dbo.udf_GetComaSeparatedIDs ( @InstitutionID) S
						ON CI.OrganizationID = s.objectid
						AND CI.OrganizationRole = 3
						-- restricted by resulting protocols
						AND CI.ProtocolID IN (
							SELECT 	ProtocolID
							FROM 	#result
							)
					) 
				
						
				SET @tmpResultRowCountTwo = @@ROWCOUNT
				IF @tmpResultRowCountTwo = 0 
				BEGIN
						-- no protocols found for provided @InstitutionID parameters
					UPDATE  dbo.ProtocolSearch
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
		-- PRINT '          - @ContactInfoSearchStatus must be >= 2 uif we did additional search by @InvestigatorID, @LeadOrganizationID, @InstitutionID'
		-- PRINT '          - @ContactInfoSearchStatus is ' + convert(varchar, @ContactInfoSearchStatus)


		IF @ContactInfoSearchStatus >= 2
		BEGIN
			-- PRINT 'yes we need to delete protocols that do not match parameters'
			
			DELETE 	@ContactInfoResult  
			WHERE 	ProtocolID NOT IN 
					(
					SELECT 	ProtocolID 
					FROM 	@tmpAltContact
					)
		
			 
			INSERT 	@ContactInfoResult  ( ProtocolID, ProtocolContactInfoID )
			SELECT 	ProtocolID, 
				ProtocolContactInfoID 
			FROM 	@tmpAltContact
		END

		-- *******************************************************************
		-- PRINT 'Step 1300 - Cache Search Results'

		IF 	NOT @AbstractVersion = 'Professional' 
			OR 
			NOT @AbstractVersion = 'Patient'
		BEGIN
			SET 	@AbstractVersion = 'Professional' 
		END
		
		-- PRINT 'Step 1295 - Check do we need to minimize #result subset by Cached Contacts '



		IF @ContactInfoSearchStatus <> 0
		BEGIN
			 --PRINT '- yes we need, lets get protocols that match Cached Contacts '

			INSERT INTO dbo.ProtocolSearchSysCache(
				ProtocolSearchID,
				ProtocolID		
				)
			SELECT	
				DISTINCT  	
				@ProtocolSearchID,
				ProtocolID
			FROM 	@ContactInfoResult	

			SET	@ResultRowCount = @@ROWCOUNT

			 --PRINT 'Step 1350 - Cache Contact Info Search Results'

			INSERT INTO dbo.ProtocolSearchContactCache(
				ProtocolSearchID,
				ProtocolContactInfoID,
				ProtocolID
				)
			SELECT DISTINCT 
				@ProtocolSearchID,
				ProtocolContactInfoID,
				ProtocolID
			FROM 	@ContactInfoResult  		

		END
		ELSE BEGIN
			-- PRINT 'Step 1350 - no we do not need to minimize #result subset by Cached Contacts, lets get all data from Result table'
			INSERT INTO dbo.ProtocolSearchSysCache(
				ProtocolSearchID,
				ProtocolID
				)
			SELECT	@ProtocolSearchID,
				ProtocolID
			FROM 	#result

			SET	@ResultRowCount = @@ROWCOUNT
		END
			
		-- PRINT ' Step 9800 - Update Statistics '
		UPDATE  dbo.ProtocolSearch
		SET 	Requested = Requested + 1,
			IsCachedSearchResultAvailable = 1,
			IsCachedContactsAvailable =   @ContactInfoSearchStatus 	
		WHERE 	ProtocolSearchID = @ProtocolSearchID

		-- no protocols found for provided @InstitutionID parameters
		EXEC dbo.usp_LogProtocolSearchExecutionTime 
			@ProtocolSearchID = @ProtocolSearchID ,
			@ResultCount = @ResultRowCount,
			@StartTime = @SearchStartTime,
			@Message = 'Normal Search Execution. Cache data is not used'		
	END
	ELSE BEGIN
		-- PRINT ' Step 9850 - Check how many records in the cache'
		SELECT 	@ResultRowCount = count(*) 
		FROM 	dbo.ProtocolSearchSysCache WITH (READUNCOMMITTED)
		WHERE 	ProtocolSearchID = @ProtocolSearchID

		-- PRINT ' Step 9900 - Update Statistics '
		UPDATE  dbo.ProtocolSearch
		SET 	Requested = Requested + 1
		WHERE 	ProtocolSearchID = @ProtocolSearchID

		-- no protocols found for provided @InstitutionID parameters
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
drop table #result
drop table #tmpAltSearch
drop table #intervention
END



GO
GRANT EXECUTE ON [dbo].[usp_ProtocolSearchExtended_IDadv1] TO [websiteuser_role]
GO
