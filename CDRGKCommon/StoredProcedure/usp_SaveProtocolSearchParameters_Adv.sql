IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_SaveProtocolSearchParameters_Adv]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_SaveProtocolSearchParameters_Adv]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****** Object:  Stored Procedure dbo.usp_SaveProtocolSearchParameters_Adv    Script Date: 7/18/2005 12:15:14 PM ******/


/*	NCI - National Cancer Institute
*	
*	Purpose: 
*		- Save Protocol Search Parameters and 
*		- ReturnSearchID
*		- Tell Dis the cached search result available or not
*				
*
*	Objects Used:
*
*	Change History:
*	1/22/2003 	Alex Pidlisnyy	Script Created
*	7/7/2003 	Alex Pidlisnyy	Add parameters @DrugSearchFormula, @SearchType
*	12/31/2003	John Do		Script Changed
*	7/19/2005 	Min		Add ProtocolSpecialCategory parameter
*
*/


CREATE PROCEDURE dbo.usp_SaveProtocolSearchParameters_Adv --Advanced
	(	
	@CancerType 		varchar(8000) 	= NULL,  	-- (+) coma separated list of CDR IDs
 	@CancerTypeStage 	varchar(8000) 	= NULL,  	-- (+) coma separated list of CDR IDs
	@TrialType		varchar(100) 	= NULL,  	-- (+) coma separated list of Type Names
	@TrialStatus		char(1) 	= NULL, 	-- (+) "Y" - Active, "N" - Closed
	@AlternateProtocolID	varchar(8000) 	= NULL,  	-- (+) coma separated list of Protocol IDs
	
	@ZIP			varchar(10) 	= NULL,		-- (+) 00000-0000
	@ZIPProximity		int 		= NULL,			-- proximity mile radius
	@City			varchar(50) 	= NULL,		-- (+) city 
	@State			varchar(50) 	= NULL,		-- (+) state
	@Country		varchar(50) 	= NULL,		-- (+) country
	@Institution		varchar(8000) 	= NULL,  	-- coma separated list of Hospitals/Institution
	
	@Investigator		varchar(8000) 	= NULL,  	-- (+) coma separated list of string (GivenName+Space+SurName) 
	@LeadOrganization	varchar(8000) 	= NULL,  	-- (+) coma separated list of strings 

	@VAMilitaryOrganization	varchar(8000) 	= NULL,  	-- (+) coma separated list of OrganizationIDs

	@IsNIHClinicalCenterTrial char(1) 	= NULL, 		-- (+) "Y"  ("N" and NULL - meand does not matter)
	@IsNew			char(1) 	= NULL, 		-- (+) "Y"  ("N" and NULL - meand does not matter)
	@TreatmentType		varchar(8000) 	= NULL, 		-- (+) coma separated list of Modality CDR IDs
	@DrugSearchFormula	varchar(100)	= 'OR',  	-- 'OR' - default, 'AND' - drug combination
 	@Drug 			varchar(8000) 	= NULL,  	-- (+) coma separated list of CDR IDs
	@Phase			varchar(100) 	= NULL,  		-- (+) coma separated list of string
	@TrialSponsor		varchar(100) 	= NULL,  		-- (+) coma separated list of string
	@AbstractVersion	varchar(50) 	= NULL, 		-- (+) Professional or Patient

	@ParameterOne		varchar(8000) 	= NULL,  	-- Reserved parameter. "SimpleSearch" 
	@ParameterTwo		varchar(8000)	= NULL,  	-- Reserved parameter. Check usp_ProtocolSearch for more details
	@ParameterThree		varchar(8000) 	= NULL,  	-- Reserved parameter. Check usp_ProtocolSearch for more details

	@ShowDetailReportMessage char(1) 	= NULL,	  	-- Show Detail Report Message. 
	@SearchType		varchar(50) 	= NULL,		 

	-- **************************** Below is StoredProc related Parameters **************************** 

	@CheckCache 		bit = 0, 				-- '1' if we need to perform search for available Cache result
	@SpecialCategory 	varchar(1000) =  null,			----Gao 7/18 SC
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
		-- Check do we have similar searched already cached 
		SET @ProtocolSearchID = (
				select 	TOP 1
					ProtocolSearchID
				from 	vw_CachedProtocolSearch
				WHERE 	CancerType = ISNULL( @CancerType , '' )
					AND CancerTypeStage = ISNULL( @CancerTypeStage , '' )
					AND TrialType = ISNULL( @TrialType , '' )
					AND TrialStatus = ISNULL( @TrialStatus , '' )
					AND AlternateProtocolID = ISNULL( @AlternateProtocolID , '' )
					AND ZIP = ISNULL( @ZIP , '' )
					AND ZIPProximity = ISNULL( @ZIPProximity , '' )
					AND City = ISNULL( @City , '' )
					AND State = ISNULL( @State , '' )
					AND Country = ISNULL( @Country , '' )
					AND Institution = ISNULL( @Institution , '' )
					AND Investigator = ISNULL( @Investigator , '' )
					AND LeadOrganization = ISNULL( @LeadOrganization , '' )
					AND VAMilitaryOrganization = ISNULL(  @VAMilitaryOrganization , '' )
					AND IsNIHClinicalCenterTrial = ISNULL( @IsNIHClinicalCenterTrial, '' )
					AND IsNew = ISNULL( @IsNew , '' )
					AND TreatmentType = ISNULL( @TreatmentType, '' )
					AND Drug = ISNULL( @Drug , '' )
					AND Phase = ISNULL( @Phase , '' )
					AND TrialSponsor = ISNULL( @TrialSponsor , '' )
					AND AbstractVersion = ISNULL( @AbstractVersion , '' )
					AND ParameterOne = ISNULL( @ParameterOne , '' )
					--* do not check for ParameterTwo because it represent some display informationand may change from time to time	
					--* AND ParameterTwo = ISNULL( @ParameterTwo , '' )
					AND ParameterThree = ISNULL( @ParameterThree , '' )
					AND DrugSearchFormula = ISNULL( @DrugSearchFormula, '') 
					--* AND SearchType = ISNULL( @SearchType, '') 
					And SpecialCategory = ISNULL(@SpecialCategory,'')
					---- Gao 7/18 SC
			)		
	
		IF @ProtocolSearchID IS NULL		
		BEGIN
			--**********************************************************************************************************
			-- PRINT 'Step 30 - Log Protocol Search Parameters'
			INSERT INTO ProtocolSearch
			(
				CancerType,
				CancerTypeStage,
				TrialType,
				TrialStatus,
				AlternateProtocolID,
				ZIP,
				ZIPProximity,
				City,
				State,
				Country,
				Institution,
				Investigator,
				LeadOrganization,
				VAMilitaryOrganization,
				IsNIHClinicalCenterTrial,
				IsNew,
				TreatmentType,
				Drug,
				Phase,
				TrialSponsor,
				AbstractVersion,
				ParameterOne,
				ParameterTwo,
				ParameterThree,
				ShowDetailReportMessage,
				DrugSearchFormula,
				SearchType,
				SpecialCategory   ---- Gao 7/18 SC

			) VALUES (
				@CancerType,
				@CancerTypeStage,
				@TrialType,
				@TrialStatus,
				@AlternateProtocolID,
				@ZIP,
				@ZIPProximity,
				@City,
				@State,
				@Country,
				@Institution,
				@Investigator,
				@LeadOrganization,
				@VAMilitaryOrganization,
				@IsNIHClinicalCenterTrial,
				@IsNew,
				@TreatmentType,
				@Drug,
				@Phase,
				@TrialSponsor,
				@AbstractVersion,
				@ParameterOne,
				@ParameterTwo,
				@ParameterThree,
				@ShowDetailReportMessage,
				@DrugSearchFormula,
				@SearchType,
				@SpecialCategory  ---- Gao 7/18 SC
			)
			SET @ProtocolSearchID = @@IDENTITY
		END
		ELSE BEGIN
			-- we got the ProtocolSearchID
			SET @tmpGotCache = 1
	
			IF EXISTS (
				SELECT TOP 1 *   --ProtocolSearchID
				FROM	ProtocolSearch WITH( READUNCOMMITTED ) 
				WHERE 
					ProtocolSearchID = @ProtocolSearchID 			
					AND convert( varchar(8000), ParameterTwo ) <> @ParameterTwo
					AND ParameterTwo IS NOT NULL
				)
			BEGIN
				-- Update value in ParameterTwo field
				-- because it represent some display informationand may change from time to time	
				UPDATE 	ProtocolSearch 
				SET 		ParameterTwo = @ParameterTwo 
				FROM		ProtocolSearch 
				WHERE 	ProtocolSearchID = @ProtocolSearchID 			
			END
		END
	END
	--**********************************************************************************************************
	-- PRINT 'Step 40 - Don''t Log Protocol Search Parameters.'
	
	IF 	@CheckCache = 1
		OR 
		@tmpGotCache = 1
	BEGIN
		--**********************************************************************************************************
		-- PRINT 'Step 50 - Check do we have Caches Protocol Search Result available.'
		
		SELECT 	@tmpBit = IsCachedSearchResultAvailable
		FROM 	dbo.ProtocolSearch 
		WHERE 	ProtocolSearchID = @ProtocolSearchID 
		
		SET @IsCachedSearchResultAvailable = ISNULL( @tmpBit, 0)
		
	END
END


GO
