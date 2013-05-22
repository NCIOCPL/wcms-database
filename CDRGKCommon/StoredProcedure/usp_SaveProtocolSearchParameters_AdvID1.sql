IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_SaveProtocolSearchParameters_AdvID1]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_SaveProtocolSearchParameters_AdvID1]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****** Object:  Stored Procedure dbo.usp_SaveProtocolSearchParameters_Adv1    Script Date: 9/18/2005 12:15:14 PM ******/


/*	NCI - National Cancer Institute
*	
*	Purpose: 
*		used only in stepone
*		- Save Protocol Search Parameters 
*		- ReturnSearchID
*		- Tell Dis the cached search result available or not
*				
*
*	Objects Used:
*
*	Change History:
*	
*	8/19/2005 	Min		CT link and ID search
*
*/


CREATE PROCEDURE dbo.usp_SaveProtocolSearchParameters_AdvID1 --Advanced
	(	
	@IDstring varchar(8000) = null,
	--@IDstringHash int =null,
	@TrialType varchar(8000) = NULL,
	@TrialStatus varchar(8000) = NULL,
	@ParameterOne  varchar(8000) = NULL,
	@SearchType		varchar(50) 	= NULL,	
	@CancerType 		varchar(8000) 	= NULL,  	-- (+) coma separated list of CDR IDs
 	@CancerTypeStage 	varchar(8000) 	= NULL,  	-- (+) coma separated list of CDR IDs
	@CheckCache 		bit = 0, 				-- '1' if we need to perform search for available Cache result
	@IsCachedSearchResultAvailable bit = 0 OUTPUT,  	-- '1' If Cashed Search Result available
	@ProtocolSearchID	int = NULL OUTPUT 		-- Input/Output parameters returns search ID which identifies search, if provided together with @CheckCache than, cache will be checked for data availability  

	)
AS
BEGIN


	SET NOCOUNT ON

	--**********************************************************************************************************
	-- PRINT 'Step 10 - Declare variables'
	DECLARE @tmpBit bit,
		@tmpGotCache bit


	
	--**********************************************************************************************************
	-- PRINT 'Step 20 - Check do we need to log Protocol Search Parameters'
	-- select * from ProtocolSearch

	IF @ProtocolSearchID IS NULL 
	BEGIN 
		--**********************************************************************************************************
		--print 'Check do we have similar searched already cached '

		SET @ProtocolSearchID = (

		select 	TOP 1
		ProtocolSearchID
		from dbo.protocolsearch 
		with 	( readuncommitted )
		where iscachedSearchResultAvailable = 1 and idstring like @idstring
			--IDstringHash = @IDstringHash

		)
		
		
		

		IF @ProtocolSearchID IS NULL		
		BEGIN
			--**********************************************************************************************************
			-- PRINT 'Step 30 - Log Protocol Search Parameters'
			
			INSERT INTO dbo.ProtocolSearch
			(	TrialType,
				TrialStatus,
				ParameterOne,
				SearchType,
				idstring,
				CancerType, 
			 	CancerTypeStage



			) VALUES (
				--@diagnosisid,
				@TrialType,
				@TrialStatus,
				@ParameterOne,
				@SearchType,
				@IDstring,
				@cancerType,
				@cancerTypeStage

			)
			SET @ProtocolSearchID = @@IDENTITY

		END


	END
	--**********************************************************************************************************
	-- PRINT 'Step 40 - Don''t Log Protocol Search Parameters.'
	
	IF 	@CheckCache = 1
		OR 
		@tmpGotCache = 1
	BEGIN
		--**********************************************************************************************************
		--PRINT 'Step 50 - Check do we have Caches Protocol Search Result available.'
		
		SELECT 	@tmpBit = IsCachedSearchResultAvailable
		FROM 	dbo.ProtocolSearch 
		WHERE 	ProtocolSearchID = @ProtocolSearchID 
		
		
		SET @IsCachedSearchResultAvailable = ISNULL( @tmpBit, 0)
		
	END
--print 'At last in adv ' + convert(varchar,isnull(@ProtocolSearchID,0),100)
END


GO
