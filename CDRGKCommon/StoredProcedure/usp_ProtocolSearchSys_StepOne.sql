IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_ProtocolSearchSys_StepOne]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_ProtocolSearchSys_StepOne]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*	NCI - National Cancer Institute
*	
*	Purpose:	
*	Stored procedure perform System subsearch
*
*	Objects Used:
*
*	Related Objects:
*
*	Change History:
*	4/2/2004 	Alex Pidlisnyy	Script Created
*/

CREATE PROCEDURE dbo.usp_ProtocolSearchSys_StepOne
	(	
	@CancerType 		varchar(8000) 	= NULL,  	-- (+) coma separated list of CDR IDs
 	@CancerTypeStage 	varchar(8000) 	= NULL,  	-- (+) coma separated list of CDR IDs
	@TrialType		varchar(100) 	= NULL,  	-- (+) coma separated list of Type Names
	@TrialStatus		char(1) 	= 'Y', 		-- (+) "Y" - Active, "N" - Closed

	@GetCachedSearchResult	bit = 1,				-- If set to '1' than function will get cached search result 
								-- if possible, otherwise search will be performed. If set to 
								-- '0' than search will be performed and cache data 
								-- will be updated.  
	@SysProtocolSearchID	int 		= NULL OUTPUT, 	-- returns search ID which identifies System Search Cache
	@ResultRowCount		int 		= 0 OUTPUT 	-- returns result count  
	)
AS
BEGIN

	 SET NOCOUNT ON
	--**********************************
	--PRINT 	'Step 50 - Declare variables'
	DECLARE @IsCachedSearchResultAvailable bit,
		@SearchStartTime datetime,
		@LogMessage varchar(50)

	declare @trialStatusBit bit
	set @trialStatusBit =  case  @TrialStatus when 'N' then 0 else 1 end

	
	--**********************************
	-- PRINT 	'Step 55 - Set values'
	SET	@SearchStartTime = GETDATE()
	SET	@LogMessage = ''
	
	-- ADD ID BUCKETs [3/22/2004 RC] --
	CREATE TABLE #id  (
		anyid varchar(150)
	)

	CREATE CLUSTERED INDEX ind1 on #id (anyid)

	CREATE TABLE #id2  (
		anyid varchar(150)
	)

	CREATE CLUSTERED INDEX ind2 on #id2 (anyid)


	--**********************************
	-- PRINT 'Step 150 - Log ProtocolSearch'
	EXEC usp_SaveProtocolSearchParameters_Adv
		@CancerType = @CancerType,
		@CancerTypeStage = @CancerTypeStage,
		@TrialType = @TrialType,
		@TrialStatus = @TrialStatus,
		@SearchType = 'System_StepOne', 
		@ParameterOne = 'System_StepOne',	

		@CheckCache = @GetCachedSearchResult, -- '1' if we need to perform search for available Cache result
		@IsCachedSearchResultAvailable = @IsCachedSearchResultAvailable OUTPUT, -- '1' If Cashed Search Result available
		@ProtocolSearchID = @SysProtocolSearchID OUTPUT -- Input/Output parameters returns search ID which identifies search, if provided together with @CheckCache than, cache will be checked for data availability  


	-- select 	@IsCachedSearchResultAvailable as  '@IsCachedSearchResultAvailable',
	-- 	@GetCachedSearchResult as '@GetCachedSearchResult'

	--**********************************
	-- PRINT 	'Step 160 - Check do we need to perform search'

	IF 	( ISNULL( @IsCachedSearchResultAvailable, 0 ) <> 1 ) 
		OR
		( ISNULL( @GetCachedSearchResult, 0 ) <> 1 )
	BEGIN -- 00
		--**********************************
		PRINT 'Step 170 - Yes lets start Search'
		
		IF @GetCachedSearchResult = 0
		BEGIN -- A1
			--**********************************
			-- PRINT 'Step 180 - Clean the cache if we inforced to refine search'
		
			DELETE 	ProtocolSearchSysCache
			WHERE 	ProtocolSearchID = @SysProtocolSearchID
		
			DELETE 	ProtocolSearchContactCache
			WHERE 	ProtocolSearchID = @SysProtocolSearchID
		END -- A1
		
		
		--**********************************
		-- PRINT 'Step 200 - Set defaul values'
		SET 	@ResultRowCount = 0
		
		-- Active or clesed Statuses always exists so we will not monitore resultset for them
		-- But we will do it for all other criterial
		
		SET 	@TrialStatus 	= ISNULL( NULLIF( RTRIM(LTRIM(@TrialStatus)), ''), 'Y' )			
		SET 	@TrialType 	= NULLIF( UPPER(LTRIM(RTRIM( @TrialType ))), 'ALL' )
		SET 	@TrialType 	= NULLIF( LTRIM( @TrialType ), '' )	
		SET 	@CancerType 	= NULLIF( LTRIM( @CancerType ), '' )	
		SET 	@CancerTypeStage	= NULLIF( LTRIM(RTRIM( @CancerTypeStage	)), '' )	
		
		--**********************************
		-- PRINT 'Step 200 - Check are we looking for "All types of Cancer" and "Any type of Trials"'
		IF 	@CancerType IS NULL -- All types of Cancer 
			AND 
			@TrialType IS NULL -- Any type of Trials
		BEGIN -- A
			--**********************************
			-- PRINT 'Step 500 - Yes we are looking for "All types of Cancer" and "Any type of Trials"'
			INSERT INTO ProtocolSearchSysCache WITH( ROWLOCK )
				(
				ProtocolSearchID,
				ProtocolID
				)
			SELECT 	@SysProtocolSearchID,
				P.ProtocolID
			FROM	Protocol AS P WITH ( READUNCOMMITTED )
			WHERE 	P.IsActiveProtocol = @trialStatusBit
	
			SET 	@ResultRowCount = @@ROWCOUNT
		END -- A
		ELSE BEGIN -- B
			--**********************************
			-- PRINT 'Step 510 - Check IS (@CancerType IS NULL) AND (@TrialType IS NOT NULL) '
			IF 	@CancerType IS NULL -- All types of Cancer 
				AND 
				@TrialType IS NOT NULL -- Selected types of trials
			BEGIN  -- C
				--**********************************
				-- PRINT 'Step 510(A) - Yes look for "Any types of Cancer" and "Selected types of trials"'
			
				-- OPTIMIZED [3/22/2003 RC] --				
				TRUNCATE TABLE #id 
				INSERT #id
				SELECT ObjectID  FROM dbo.udf_GetComaSeparatedIDs ( @TrialType )
			
				INSERT INTO ProtocolSearchSysCache WITH( ROWLOCK )
					(
					ProtocolSearchID,
					ProtocolID
					)
				SELECT 	distinct 
					@SysProtocolSearchID,
					ProtocolID 
				FROM 	dbo.ProtocolStudyCategory AS PSC WITH ( READUNCOMMITTED ),
                                        #id                       AS i   WITH ( READUNCOMMITTED ),
						dbo.udf_getstudycategoryID(@trialType) g
			
				WHERE   g.studycategoryid  = PSC.studycategoryid 
										AND PSC.ProtocolID IN (
						SELECT 	P.ProtocolID
						FROM	Protocol AS P WITH ( READUNCOMMITTED )
						WHERE 	P.IsActiveProtocol =@trialStatusBit
						)
				SET 	@ResultRowCount = @@ROWCOUNT
			END -- C
			ELSE BEGIN --D
				--**********************************
				-- PRINT 'Step 510(B) - No, condition "Any types of Cancer" and "Selected types of trials" not satisfied '
				-- PRINT '            - lets check for particular cancer type and any type of tryal'
				IF 	@CancerType IS NOT NULL -- Selected types of Cancer 
					AND 
					@TrialType IS NULL -- All types of Trials
				BEGIN -- E
					--**********************************
					-- PRINT 'Step 510(B-1) - Ok, we have "particular cancer type" and "any type of tryal"'
					-- PRINT '              - lets check @CancerTypeStage'
					IF @CancerTypeStage IS NULL	
					BEGIN -- F
						--**********************************
						-- PRINT 'Step 510(B-1-1) @CancerTypeStage is NULL'
						
						-- OPTIMIZED [3/22/2003 RC] --				
						TRUNCATE TABLE #id 
						INSERT #id
						SELECT ObjectID  FROM dbo.udf_GetComaSeparatedIDs ( @CancerType )
		
						INSERT INTO ProtocolSearchSysCache WITH( ROWLOCK )
							(
							ProtocolSearchID,
							ProtocolID
							)
						SELECT 	distinct 
							@SysProtocolSearchID,
							ProtocolID 
						FROM 	dbo.ProtocolTypeOfCancer AS PTC WITH ( READUNCOMMITTED ),
							#id			 AS i   WITH ( READUNCOMMITTED )
						WHERE	PTC.DiagnosisID = i.anyid
							AND PTC.ProtocolID IN (
								SELECT 	P.ProtocolID
								FROM	Protocol AS P WITH ( READUNCOMMITTED )
								WHERE 	P.IsActiveProtocol = @trialStatusBit
								)
						
						SET 	@ResultRowCount = @@ROWCOUNT
					END -- F
					ELSE BEGIN -- G
						--**********************************
						-- PRINT 'Step 510(B-1-2) semms like stage info provided'
						-- in this case we looking right for more detail information - stages 
		
						-- OPTIMIZED [3/22/2003 RC] --				
						TRUNCATE TABLE #id 
						INSERT #id
						SELECT ObjectID  FROM dbo.udf_GetComaSeparatedIDs ( @CancerTypeStage )
		
						INSERT INTO ProtocolSearchSysCache WITH( ROWLOCK )
							(
							ProtocolSearchID,
							ProtocolID
							)
						SELECT 	distinct 
							@SysProtocolSearchID,
							ProtocolID 
						FROM 	dbo.ProtocolTypeOfCancer AS PTC	WITH ( READUNCOMMITTED ),
							#id			 AS i   WITH ( READUNCOMMITTED )
						WHERE	PTC.DiagnosisID = i.anyid
							AND ProtocolID IN (
								SELECT 	P.ProtocolID
								FROM	Protocol AS P WITH ( READUNCOMMITTED )
								WHERE 	P.IsActiveProtocol =@trialStatusBit
								)
						SET 	@ResultRowCount = @@ROWCOUNT
					END -- G
				END -- E
				ELSE BEGIN -- I
					--**********************************
					-- PRINT 'Step 510(C) - Ok, we do not satisfy conditions "particular cancer type" and "any type of tryal"'
					-- PRINT '              - lets check @CancerTypeStage'
					IF @CancerTypeStage IS NULL	
					BEGIN -- J
						--**********************************
						-- PRINT 'Step 510(C-1) - Selected types of Cancer && Selected types of Trials'
						
						-- OPTIMIZED [3/22/2003 RC] --				
						TRUNCATE TABLE #id 
						INSERT #id
						SELECT ObjectID  FROM dbo.udf_GetComaSeparatedIDs ( @CancerType )
		
						TRUNCATE TABLE #id2 
						INSERT #id2
						SELECT ObjectID  FROM dbo.udf_GetComaSeparatedIDs ( @TrialType )
		
						INSERT INTO ProtocolSearchSysCache WITH( ROWLOCK )
							(
							ProtocolSearchID,
							ProtocolID
							)
						SELECT 	distinct 
							@SysProtocolSearchID,
							ProtocolID 
						FROM 	dbo.ProtocolTypeOfCancer AS PTC	WITH ( READUNCOMMITTED ),
							#id                      AS i   WITH ( READUNCOMMITTED )
						WHERE 	PTC.DiagnosisID = i.anyid 
							AND ProtocolID IN (
								SELECT 	P.ProtocolID
								FROM	Protocol AS P WITH ( READUNCOMMITTED )
								WHERE 	P.IsActiveProtocol =@trialStatusBit
								)
							AND ProtocolID IN (
								SELECT ProtocolID 
								FROM dbo.ProtocolStudyCategory AS PSC WITH ( READUNCOMMITTED ),
								     #id2                       AS i2  WITH ( READUNCOMMITTED ),
									dbo.studycategory g 
								WHERE   g.studycategoryid  = PSC.studycategoryid and
									g.StudyCategoryName = i2.anyid
								)
						SET 	@ResultRowCount = @@ROWCOUNT
		
					END -- J
					ELSE BEGIN -- H
						--**********************************
						-- PRINT 'Step 510(C-2) - Selected types of Cancer && Selected types of Trials'
						-- looking for more detail info - stages
		
						-- OPTIMIZED [3/22/2003 RC] --																-- OPTIMIZED [3/22/2003 RC] --				
						TRUNCATE TABLE #id 
						INSERT #id
						SELECT ObjectID  FROM dbo.udf_GetComaSeparatedIDs ( @CancerTypeStage )
		
						TRUNCATE TABLE #id2 
						INSERT #id2
						SELECT ObjectID  FROM dbo.udf_GetComaSeparatedIDs ( @TrialType )
		
						INSERT INTO ProtocolSearchSysCache WITH( ROWLOCK )
							(
							ProtocolSearchID,
							ProtocolID
							)
						SELECT 	distinct 
							@SysProtocolSearchID,
							ProtocolID 
						FROM 	dbo.ProtocolTypeOfCancer AS PTC	WITH ( READUNCOMMITTED ),
                                                        #id                       AS i   WITH ( READUNCOMMITTED )
						WHERE 	PTC.DiagnosisID = i.anyid
								-- Get CancerType 
				
							AND ProtocolID IN (
								SELECT 	P.ProtocolID
								FROM	Protocol AS P WITH ( READUNCOMMITTED )
								WHERE 	P.IsActiveProtocol = @trialStatusBit
								)
							AND ProtocolID IN (
								SELECT ProtocolID 
								FROM dbo.ProtocolStudyCategory AS PSC WITH ( READUNCOMMITTED ),
								     #id2                       AS i2  WITH ( READUNCOMMITTED ),
								dbo.studycategory g 
								WHERE   g.studycategoryid  = PSC.studycategoryid and
									g.StudyCategoryName = i2.anyid)
						SET 	@ResultRowCount = @@ROWCOUNT
					END -- H
				END -- I
			END -- D
			-- Find out howm many rows we have in resultset
			-- IF @ResultRowCount <= 0
			-- BEGIN -- L
			--	SELECT 	@SysProtocolSearchID AS 'ProtocolSearchID',
			--		0 AS 'ResultCount'
			--	RETURN
			-- END -- L
		END -- B

		SET	@LogMessage = 'System Search. Re-run Search and populate new result.'		
	END -- 00
	ELSE BEGIN -- 11
		-- PRINT ' Step 9850 - Check how many records in the cache'
		SELECT 	@ResultRowCount = count(*) 
		FROM 	ProtocolSearchSysCache WITH (NOLOCK)
		WHERE 	ProtocolSearchID = @SysProtocolSearchID

		SET	@LogMessage = 'Fast System Search. Cache data is used.'		
	END -- 11

	-- PRINT ' Step 9800 - Update Statistics '
	UPDATE 	ProtocolSearch
	SET 	Requested = Requested + 1,
		IsCachedSearchResultAvailable = 1
	WHERE 	ProtocolSearchID = @SysProtocolSearchID

	-- no protocols found for provided @Institution parameters
	EXEC dbo.usp_LogProtocolSearchExecutionTime 
		@ProtocolSearchID = @SysProtocolSearchID,
		@ResultCount = @ResultRowCount,
		@StartTime = @SearchStartTime,
		@Message = @LogMessage 
END

GO
