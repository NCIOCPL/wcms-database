IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_ProtocolSearchSimpleExtended]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_ProtocolSearchSimpleExtended]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****** Object:  Stored Procedure dbo.usp_ProtocolSearchSimpleExtended    Script Date: 12/14/2005 12:09:38 PM ******/

/****** Object:  Stored Procedure dbo.usp_ProtocolSearchSimpleExtended    Script Date: 8/3/2005 10:44:19 AM ******/


/*	NCI - National Cancer Institute
*	
*	Purpose:	
*	Stored procedure perform Simple Clinical Trial Search against Active Protocols Only
*
*	Objects Used:
*
*	Change History:
*	5/28/2003 	Alex Pidlisnyy	Script Created
*	7/7/2003 	Alex Pidlisnyy	Update with the new functionality
*					SCR#36 Do not use Lead Organization Personnel location data to determine if there is a match when location criteria are specified.  
*	12/4/2003	Alex 		Add Phase in to search Result
*	4/2/2004	Alex 		Change cache logic
*	4/6/2004	Alex 		Use usp_ProtocolSearchSys_StepOne to get System Cache
*	10/14/2004	Lijia		add 
*
*	12/14/2005	Min			Change ZIP part search
*	To Do:
*	 - Check did we use WITH (READUNCOMMITTED)
*
*/

CREATE PROCEDURE dbo.usp_ProtocolSearchSimpleExtended
	(	
	@CancerType 		varchar(8000),			-- (+) coma separated list of CDR IDs 
 	@CancerTypeStage 	varchar(8000)	= NULL,		-- (+) coma separated list of CDR IDs 
	@TrialType		varchar(100) 	= NULL,  	-- (+) coma separated list of Type Names
	
	@ZIP			varchar(10)	= NULL,		-- (+) 00000-0000
	@ZIPProximity		int		= NULL,		-- proximity mile radius

	@ParameterOne		varchar(8000)   = 'SimpleSearch',  -- reserved parameter by default set to "SimpleSearch", but we may change the value if we want 
	@ParameterTwo		varchar(8000)	= NULL,  	-- reserved parameter
	@ParameterThree		varchar(8000)	= NULL,  	-- reserved parameter
	
	@GetCachedSearchResult	bit = 1,			-- If set to '1' than function will get cached search result 
								-- if possible, otherwise search will be performed. If set to 
								-- '0' than search will be performed and cache data 
								-- will be updated.  
	@IsNIHClinicalCenterTrial char(1)	= NULL,

	@ProtocolSearchID	int = NULL OUTPUT,		-- Input/Output parameter. If supplied than 
								-- storedproc will look for cached data for 
								-- given ProtocolSearchID. 
	@isReRun bit = 0
	)
AS
BEGIN
	set nocount on

	--**********************************************************************************************************
	-- declare variables
	DECLARE @IsCachedSearchResultAvailable bit,
		@IsCachedContactsAvailable bit,
		@ResultCount int,
		@SearchStartTime datetime,
		@TrialStatus varchar(1) ,
		@SysProtocolSearchID int,
		@ResultRowCount int,
		@tmpResultRowCount int
	
	declare @ContactInfoResult table (
		ProtocolID int,
		ProtocolContactInfoID	int		
	)

	SET 	@SearchStartTime = GETDATE()
	SET 	@TrialStatus 	= 'Y' -- always active trials
	SET 	@SysProtocolSearchID = NULL
	SET 	@ResultRowCount = NULL
	SET 	@IsCachedContactsAvailable = NULL				

	--**********************************************************************************************************
	-- PRINT 'ProtocolSearchSimple: Step 1 - Log ProtocolSearch'


	-- PRINT 'Step 100 - Create temporary tables'
	declare @result table (
		ProtocolID	int		-- CDRProtocolID
	)


	EXEC usp_SaveProtocolSearchParameters_Adv
		@CancerType = @CancerType,
	 	@CancerTypeStage = @CancerTypeStage,
		@TrialType = @TrialType,
		@TrialStatus = @TrialStatus, 
		@ZIP = @ZIP,
		@ZIPProximity = @ZIPProximity,
		@ParameterOne = @ParameterOne, -- 'SimpleSearch'
		@ParameterTwo = @ParameterTwo,
		@ParameterThree = @ParameterThree,
		@SearchType = 'SimpleExtended', 
		@IsNIHClinicalCenterTrial = @IsNIHClinicalCenterTrial,
		@CheckCache = @GetCachedSearchResult, -- '1' if we need to perform search for available Cache result
		@IsCachedSearchResultAvailable = @IsCachedSearchResultAvailable OUTPUT,  	-- '1' If Cashed Search Result available
		@ProtocolSearchID = @ProtocolSearchID OUTPUT 		-- Input/Output parameters returns search ID which identifies search, if provided together with @CheckCache than, cache will be checked for data availability  


	SET 	@IsCachedSearchResultAvailable = ISNULL( @IsCachedSearchResultAvailable, 0 )
	SET 	@GetCachedSearchResult = ISNULL( @GetCachedSearchResult, 0 )

	IF 	( @IsCachedSearchResultAvailable <> 1 ) 
		OR
		( @GetCachedSearchResult <> 1 )
	BEGIN
			-- PRINT 'ProtocolSearchSimple: Step 2 - Perform Search'
			IF @GetCachedSearchResult = 0
			BEGIN
				-- PRINT 'ProtocolSearchSimple: Step 20 - Clean the cache if we inforced to refine search'
				DELETE 	ProtocolSearchSysCache
				WHERE 	ProtocolSearchID = @ProtocolSearchID

				DELETE 	ProtocolSearchContactCache
				WHERE 	ProtocolSearchID = @ProtocolSearchID
			END
		
			--**********************************************************************************************************
			-- PRINT 'ProtocolSearchSimple: Step 3 -  - Correct values'
			SET @TrialType 		= NULLIF( UPPER(LTRIM(RTRIM( @TrialType ))), 'ALL' )
			SET @TrialType 		= NULLIF( LTRIM( @TrialType ), '' )	
			SET @CancerType 	= NULLIF( LTRIM( @CancerType ), '' )	
			SET @ZIP 		=  LEFT( LTRIM(RTRIM( @ZIP )), 5)
		
			--**********************************************************************************************************
			-- Active or clesed Statuses always exists so we will not monitore resultset for them
			-- But we will do it for all other criterial
		
			--**********************************
			-- PRINT 'Step 4 - Run usp_ProtocolSearchSys_StepOne to get System Cache'
			EXEC dbo.usp_ProtocolSearchSys_StepOne
				@CancerType = @CancerType,
		 		@CancerTypeStage = @CancerTypeStage,
				@TrialType = @TrialType,
				@TrialStatus = @TrialStatus,
				@GetCachedSearchResult = @GetCachedSearchResult,
				@SysProtocolSearchID = @SysProtocolSearchID OUTPUT,
				@ResultRowCount	= @ResultRowCount OUTPUT	

			-- Find out howm many rows we have in resultset
			print 'usp_ProtocolSearchSys_StepOne  '
			print  convert(varchar(30),@ResultRowCount)
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
				INSERT INTO @result 		
					SELECT 	ProtocolID 
						FROM 	ProtocolSearchSysCache WITH (READUNCOMMITTED)
							WHERE 	ProtocolSearchID = @SysProtocolSearchID	
				END

			--**********************************
			--PRINT 'Step 5 - is it @IsNIHClinicalCenterTrial '
			If UPPER(LTRIM(RTRIM( @IsNIHClinicalCenterTrial ))) = 'Y'
				BEGIN
						-- PRINT 'Step 6 - yes it is, Check for NIH Clinical Center Trials'
						DELETE  @result 
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
	
			--------- 12/14 Min change ZIP search
			--**********************************
			-- PRINT 'Step 1110 - lets check do we need to search by @ZIP'
			
			IF @ZIP IS NULL
				BEGIN
					--PRINT 'ProtocolSearchSimple: Step 7 - No ZIP was provided'
					INSERT INTO ProtocolSearchSysCache(
								ProtocolSearchID,
								ProtocolID
								)
						SELECT 	@ProtocolSearchID,
								ProtocolID
							FROM	@result 
					SET @ResultCount = @@rowcount
				
				END 	
				ELSE BEGIN
					--PRINT '          - yes, then lets Perform Search by @ZIP and by @ZIPProximity'
					IF @ZIPProximity IS NOT NULL
						BEGIN
						--PRINT 'Step 1110-A - search by @ZIP and by @ZIPProximity'
						INSERT INTO @ContactInfoResult ( ProtocolID, ProtocolContactInfoID )
						SELECT 	ProtocolID,
								ProtocolContactInfoID 
							FROM 	dbo.udf_GetProximalUSAContactInfo ( @ZIP, @ZIPProximity, @trialStatus )
							WHERE 	ProtocolID IN (
										SELECT 	ProtocolID
											FROM 	@result
										)
									
						SET @tmpResultRowCount =  @@ROWCOUNT  
						END
						ELSE BEGIN
							--	PRINT 'Step 1110-B - just search by ZIP'
							-- just search by ZIP 
							INSERT INTO @ContactInfoResult ( ProtocolID, ProtocolContactInfoID )
							SELECT 	ProtocolID,
									ProtocolContactInfoID 
								FROM 	dbo.vwUSAProtocoltrialsite WITH ( READUNCOMMITTED )
								where ZIP = @ZIP
								and ProtocolID IN (
												SELECT 	ProtocolID
													FROM 	@result
													)
							-- make sure that you prevent result from CityStateCountry search 
							SET @tmpResultRowCount =  @@ROWCOUNT
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
								@Message = 'ZERO Result for parameters:  ZIP and ZIPProximity '		
			
						if @isReRun = 0 
								SELECT 	@ProtocolSearchID AS 'ProtocolSearchID',
										0 AS 'ResultCount'

						RETURN
						END 
			
					INSERT INTO dbo.ProtocolSearchSysCache(
									ProtocolSearchID,
									ProtocolID		
									)
								SELECT	
									DISTINCT  @ProtocolSearchID,ProtocolID
									FROM 	@ContactInfoResult	

					SET	@ResultCount = @@ROWCOUNT
					
					--PRINT 'Step 1350 - Cache Contact Info Search Results'

					INSERT INTO dbo.ProtocolSearchContactCache(
									ProtocolSearchID,
									ProtocolContactInfoID,
									ProtocolID
									)
								SELECT DISTINCT @ProtocolSearchID,ProtocolContactInfoID,ProtocolID
									FROM 	@ContactInfoResult  		
								set @IsCachedContactsAvailable =1
		
			END   --END FOR IS ZIP IS NULL

			EXEC dbo.usp_LogProtocolSearchExecutionTime 
					@ProtocolSearchID = @ProtocolSearchID ,
					@ResultCount = @ResultCount,
					@StartTime = @SearchStartTime,
					@Message = 'Simple Search Run. Cache data is not used'		

			-- PRINT ' ProtocolSearchSimple: Step 120 - Update Statistics '
			UPDATE 	ProtocolSearch
			SET 	IsCachedSearchResultAvailable = 1,
					IsCachedContactsAvailable = @IsCachedContactsAvailable,
					Requested = Requested + 1
			WHERE 	ProtocolSearchID = @ProtocolSearchID

			-- PRINT ' ProtocolSearchSimple: Step 120 - Get result back '
			If @IsReRun = 0
				SELECT 	@ProtocolSearchID AS 'ProtocolSearchID',
					@ResultCount AS 'ResultCount'
			return
	
	END  -- No cache data 
	ELSE BEGIN
		SELECT 	@ResultCount = count(*) 
		FROM	ProtocolSearchSysCache WITH (READUNCOMMITTED)
		WHERE 	ProtocolSearchID = @ProtocolSearchID

		UPDATE  dbo.ProtocolSearch
		SET 	Requested = Requested + 1
		WHERE 	ProtocolSearchID = @ProtocolSearchID		
		
		-- no protocols found for provided @Institution parameters
		EXEC dbo.usp_LogProtocolSearchExecutionTime 
			@ProtocolSearchID = @ProtocolSearchID ,
			@ResultCount = @ResultCount,
			@StartTime = @SearchStartTime,
			@Message = 'Simple Search Run. Cache data is used'		
		
		if @isReRun = 0 
				SELECT 	@ProtocolSearchID AS 'ProtocolSearchID',
						@ResultCount AS 'ResultCount'
		return
	END




END





GO
GRANT EXECUTE ON [dbo].[usp_ProtocolSearchSimpleExtended] TO [websiteuser_role]
GO
