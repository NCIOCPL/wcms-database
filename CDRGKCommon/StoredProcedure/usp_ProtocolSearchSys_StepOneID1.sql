IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_ProtocolSearchSys_StepOneID1]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_ProtocolSearchSys_StepOneID1]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****** Object:  Stored Procedure dbo.usp_ProtocolSearchSys_StepOneID1    Script Date: 9/18/2005 12:15:14 PM ******/

/*	NCI - National Cancer Institute
*	
*	Purpose:	
*	Stored procedure perform System subsearch using IDstring
*
*	Objects Used:
*
*	Related Objects:
*
*	Change History:
*	8/19/2005 	Min		CT link and ID search
*/

CREATE PROCEDURE dbo.usp_ProtocolSearchSys_StepOneID1
	(	
	--@diagnosisID varchar(8000) = null,
	@cancerType varchar(8000) = null,
	@cancerTypeStage varchar(8000) = null,
	@TrialType		varchar(300) 	= NULL,  	
	@TrialStatus		char(1) 	= 'Y', 		-- (+) "0" - Active, "1" - Closed
	
	@GetCachedSearchResult	bit = 1,				-- If set to '1' than function will get cached search result 
						-- if possible, otherwise search will be performed. If set to 
								-- '0' than search will be performed and cache data 
								-- will be updated.  
	@idstring varchar(8000) = null,
	--@IDstringHash int = null,
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
		@LogMessage varchar(50),
		@diagnosisid varchar(8000)
	declare @trialStatusBit bit 
	set @trialStatusBit =  case  @TrialStatus when 'N' then 0 else 1 end

	--**********************************
	-- PRINT 	'Step 55 - Set values'
	SET	@SearchStartTime = GETDATE()
	SET	@LogMessage = ''


	--**********************************
	-- PRINT 'Step 150 - Log ProtocolSearch'


	EXEC dbo.usp_SaveProtocolSearchParameters_AdvID1
		@cancerType =@cancerTYpe,
		@cancerTypeStage =@cancerTYpeStage,
		@TrialType = @TrialType,
		@TrialStatus = @TrialStatus,
		@SearchType = 'System_StepOneID', 
		@ParameterOne = 'System_StepOneID',	
		@IDstring=@idstring,
		--@IDstringHash = @IDstringHash,
		@CheckCache = @GetCachedSearchResult, -- '1' if we need to perform search for available Cache result
		@IsCachedSearchResultAvailable = @IsCachedSearchResultAvailable OUTPUT, -- '1' If Cashed Search Result available
		@ProtocolSearchID = @SysProtocolSearchID OUTPUT -- Input/Output parameters returns search ID which identifies search, if provided together with @CheckCache than, cache will be checked for data availability  

	

	set @diagnosisid = COALESCE(@cancerTYpestage,@cancerType)

	

	--**********************************
	 --PRINT 	'Step 160 - Check do we need to perform search'

	IF 	( ISNULL( @IsCachedSearchResultAvailable, 0 ) <> 1 ) 
		OR
		( ISNULL( @GetCachedSearchResult, 0 ) <> 1 )
	BEGIN -- 00 +
		--**********************************
	--	PRINT 'Step 170 - Yes lets start Search'
		
		IF @GetCachedSearchResult = 0
		BEGIN -- A1 +
			--**********************************
			-- PRINT 'Step 180 - Clean the cache if we inforced to refine search'
		
			DELETE 	dbo.ProtocolSearchSysCache
			WHERE 	ProtocolSearchID = @SysProtocolSearchID
		
			DELETE 	dbo.ProtocolSearchContactCache
			WHERE 	ProtocolSearchID = @SysProtocolSearchID
		END -- A1 -
		
		
		--**********************************
		-- PRINT 'Step 200 - Set defaul values'
		SET 	@ResultRowCount = 0
		
		-- Active or clesed Statuses always exists so we will not monitore resultset for them
		-- But we will do it for all other criterial
		
	
		SET 	@TrialType 	= NULLIF( LTRIM(RTRIM( @TrialType )), 'ALL' )
		SET 	@TrialType 	= NULLIF( LTRIM(@TrialType), '' )	


		SET 	@Diagnosisid = nuLLIF( LTRIM( @Diagnosisid ), '' )	

		
		--**********************************
		-- PRINT 'Step 200 - Check are we looking for "All types of Cancer" and "Any type of Trials"'
		IF 	@Diagnosisid IS NULL -- All types of Cancer 
			AND 
			@TrialType IS NULL -- Any type of Trials
		BEGIN -- A +
			--**********************************
			 --PRINT 'Step 500 - Yes we are looking for "All types of Cancer" and "Any type of Trials"'
			INSERT INTO dbo.ProtocolSearchSysCache WITH( ROWLOCK )
				(
				ProtocolSearchID,
				ProtocolID
				)
			SELECT 	@SysProtocolSearchID,
				P.ProtocolID
			FROM	dbo.Protocol AS P WITH ( READUNCOMMITTED )
			WHERE 	P.IsActiveProtocol = @TrialStatusBit
	
			SET 	@ResultRowCount = @@ROWCOUNT
			
		END -- A -
		ELSE BEGIN -- B+
			--**********************************
			-- PRINT 'Step 510 - Check IS (@DiagnosisID IS NULL) AND (@TrialType IS NOT NULL) '
			IF 	@Diagnosisid IS NULL -- All types of Cancer 
				AND 
				@TrialType IS NOT NULL -- Selected types of trials
			BEGIN  -- C +
				--**********************************
				-- PRINT 'Step 510(A) - Yes look for "Any types of Cancer" and "Selected types of trials"'
			
				-- OPTIMIZED [3/22/2003 RC] --				
			
			
				INSERT INTO dbo.ProtocolSearchSysCache WITH( ROWLOCK )
					(
					ProtocolSearchID,
					ProtocolID
					)
				SELECT 	distinct 
					@SysProtocolSearchID,
					ProtocolID 
				FROM 	dbo.ProtocolStudyCategory AS PSC WITH ( READUNCOMMITTED )
				WHERE   PSC.StudyCategoryID in
					(select studycategoryid from dbo.udf_getstudyCategoryID(@TrialType))
					AND PSC.ProtocolID IN (
						SELECT 	P.ProtocolID
						FROM	dbo.Protocol AS P WITH ( READUNCOMMITTED )
						WHERE 	P.IsActiveProtocol = @TrialStatusBit
						)
				SET 	@ResultRowCount = @@ROWCOUNT
				
			END -- C-
			ELSE BEGIN --D+
				--**********************************
				-- PRINT 'Step 510(B) - No, condition "Any types of Cancer" and "Selected types of trials" not satisfied '
				-- PRINT '            - lets check for particular cancer type and any type of tryal'
				IF 	@DiagnosisID IS NOT NULL -- Selected types of Cancer 
					AND 
					@TrialType IS NULL -- All types of Trials
				BEGIN -- E+
					--**********************************
					-- PRINT 'Step 510(B-1) - Ok, we have "particular cancer type" and "any type of tryal"'
					
						-- OPTIMIZED [3/22/2003 RC] --				
						

						INSERT INTO dbo.ProtocolSearchSysCache WITH( ROWLOCK )
							(
							ProtocolSearchID,
							ProtocolID
							)
						SELECT 	distinct 
							@SysProtocolSearchID,
							PTC.ProtocolID 
						FROM 	dbo.ProtocolTypeOfCancer AS PTC WITH ( READUNCOMMITTED )
							inner join dbo.udf_GetDelimiterSeparatedIDs(@diagnosisID, ',') s							
						        on	PTC.DiagnosisID = s.objectid
							where PTC.ProtocolID IN (
								SELECT 	P.ProtocolID
								FROM	dbo.Protocol AS P WITH ( READUNCOMMITTED )
								WHERE 	P.IsActiveProtocol = @TrialStatusBit
								)
						
						SET 	@ResultRowCount = @@ROWCOUNT
						
					
					END -- E-

				ELSE BEGIN -- I+
					--**********************************
					-- PRINT 'Step 510(C-1) - Selected types of Cancer && Selected types of Trials'
						
						-- OPTIMIZED [3/22/2003 RC] --				

						
		
						INSERT INTO dbo.ProtocolSearchSysCache WITH( ROWLOCK )
							(
							ProtocolSearchID,
							ProtocolID
							)
						SELECT 	distinct 
							@SysProtocolSearchID,
							PSC.ProtocolID 
						FROM 	dbo.ProtocolTypeOfCancer AS PTC	WITH ( READUNCOMMITTED ) inner join
							dbo.udf_GetComaSeparatedIDs ( @Diagnosisid ) d
							on d.objectid = PTC.diagnosisid 
							inner join dbo.ProtocolStudyCategory AS PSC WITH ( READUNCOMMITTED )
							on  psc.protocolid = ptc.protocolid
													
						WHERE   PSC.StudyCategoryID in
							(select studycategoryid from dbo.udf_GetComaSeparatedIDs(@TrialType) t
								  inner join studycategory sc on sc.studycategoryname = t.objectid	 )
							AND PSC.ProtocolID IN (
								SELECT 	P.ProtocolID
								FROM	dbo.Protocol AS P WITH ( READUNCOMMITTED )
								WHERE 	P.IsActiveProtocol = @TrialStatusBit
							)
						SET 	@ResultRowCount = @@ROWCOUNT

				END -- I-
			END -- D
			
		END -- B

		SET	@LogMessage = 'System Search. Re-run Search and populate new result.'		

	END -- 00
	ELSE BEGIN -- 11
		--PRINT ' Step 9850 - Check how many records in the cache'
		SELECT 	@ResultRowCount = count(*) 
		FROM 	dbo.ProtocolSearchSysCache WITH (NOLOCK)
		WHERE 	ProtocolSearchID = @SysProtocolSearchID

		SET	@LogMessage = 'Fast System Search. Cache data is used.'		
	END -- 11

	--PRINT ' Step 9800 - Update Statistics '
	UPDATE 	dbo.ProtocolSearch
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
