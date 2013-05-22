IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_SaveProtocolSearchParameters_AdvID]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_SaveProtocolSearchParameters_AdvID]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****** Object:  Stored Procedure dbo.usp_SaveProtocolSearchParameters_AdvID    Script Date: 9/22/2005 5:14:48 PM ******/

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
*	
*	8/19/2005 	Min		CT link and ID search
*
*/


CREATE PROCEDURE dbo.usp_SaveProtocolSearchParameters_AdvID --Advanced
	(	
	@IDstring varchar(8000) = null,
	@TrialType varchar(8000) = NULL,
	@TrialStatus varchar(8000) = NULL,
	@InstitutionID varchar(8000) = NULL,
	@InvestigatorID varchar(8000) = NULL,
	@LeadOrganizationID varchar(8000) = NULL, 
	@IsNIHClinicalCenterTrial char(1) 	= NULL, 		
	@IsNew			char(1) 	= NULL, 
	@TreatmentType  varchar(8000) = NULL,
	@DrugID varchar(8000) = NULL,
	@Phase varchar(8000) = NULL,
	@AbstractVersion	varchar(50) 	= NULL, 	
	@ParameterOne  varchar(8000) = NULL,
	@ParameterTwo  varchar(8000) = NULL,
	@ParameterThree varchar(8000) = NULL,
	@ShowDetailReportMessage char(1) 	= NULL,	  	
	@SearchType		varchar(50) 	= NULL,	
	@DrugSearchFormula	varchar(100)	= 'OR', 
	

	@CancerType 		varchar(8000) 	= NULL,  	-- (+) coma separated list of CDR IDs
 	@CancerTypeStage 	varchar(8000) 	= NULL,  	-- (+) coma separated list of CDR IDs

	@CheckCache 		bit = 0, 				-- '1' if we need to perform search for available Cache result
	@IsCachedSearchResultAvailable bit = 0 OUTPUT,  	-- '1' If Cashed Search Result available
	@ProtocolSearchID	int = NULL OUTPUT, 		-- Input/Output parameters returns search ID which identifies search, if provided together with @CheckCache than, cache will be checked for data availability  


	@AlternateProtocolID	varchar(8000)	= NULL,  	-- (+) coma separated list of Protocol IDs
	@ZIP			varchar(10)	= NULL,		-- (+) 00000-0000
	@ZIPProximity		int		= NULL,		-- proximity mile radius
	@City			varchar(50)	= NULL,		-- (+) city 
	@State			varchar(50)	= NULL,		-- (+) state
	@Country		varchar(50)	= NULL,		-- (+) country

	@VAMilitaryOrganization	varchar(8000)	= NULL,  	-- (+) coma separated list of OrganizationIDs

	@TrialSponsor		varchar(8000)	= NULL,  	-- (+) coma separated list of string
	@SpecialCategory varchar(1000) = null  ,
	@drug varchar(8000)	= NULL,
	@Institution  varchar(8000)	= NULL,
	@Investigator  varchar(8000)	= NULL,
	@LeadOrganization varchar(8000)	= NULL,
	@isLInk bit = null,
	@idstringhash int = null


	)
AS
BEGIN


	SET NOCOUNT ON

	--**********************************************************************************************************
	-- PRINT 'Step 10 - Declare variables'
	DECLARE @tmpBit bit,
		@tmpGotCache bit



	--**********************************************************************************************************
	 --PRINT 'Step 20 - Check do we need to log Protocol Search Parameters'
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
		where iscachedSearchResultAvailable = 1 and idstringHash = @idstringHash

		)

	
		--print 'existing protccolsearchid ' + convert(varchar, @protocolsearchid, 10)

		IF @ProtocolSearchID IS NULL		
		BEGIN
			--**********************************************************************************************************
			-- PRINT 'Step 30 - Log Protocol Search Parameters'
			
			INSERT INTO dbo.ProtocolSearch
			(	
				TrialType,
				TrialStatus,
				InstitutionID,
				InvestigatorID,
				LeadOrganizationID,
				IsNIHClinicalCenterTrial,
				IsNew,
				TreatmentType,
				DrugID,
				Phase,
				AbstractVersion,
				ParameterOne,
				ParameterTwo,
				ParameterThree,
				ShowDetailReportMessage,
				DrugSearchFormula,
				SearchType,
				idstring,
				AlternateProtocolID,  	
				ZIP,	
				ZIPProximity,	
				City			,	
				State			,	
				Country		,	
				VAMilitaryOrganization	,  	
				TrialSponsor		,  	
				SpecialCategory,
				drug,
				Institution,
				Investigator,
				LeadOrganization,
				CancerType, 
			 	CancerTypeStage,
				isLink,
				idstringhash



			) VALUES (
				@TrialType,
				@TrialStatus,
				@InstitutionID,
				@InvestigatorID,
				@LeadOrganizationID,
				@IsNIHClinicalCenterTrial,
				@IsNew,
				@TreatmentType,
				@DrugID,
				@Phase,
				@AbstractVersion,
				@ParameterOne,
				@ParameterTwo,
				@ParameterThree,
				@ShowDetailReportMessage,
				@DrugSearchFormula,
				@SearchType,
				@IDstring,
				@AlternateProtocolID	,  	
				@ZIP			,	
				@ZIPProximity		,	
				@City			,	
				@State			,	
				@Country		,	
				@VAMilitaryOrganization	,  	
				@TrialSponsor		,  	
				@SpecialCategory,
				@drug,
				@Institution,
				@Investigator,
				@LeadOrganization,
				@cancerType,
				@cancerTypeStage,
				@isLink,
				@idstringhash

			)
			SET @ProtocolSearchID = @@IDENTITY

		END
		ELSE 
		BEGIN

			set @protocolsearchid = 
			(select 	TOP 1
			ProtocolSearchID
			from dbo.protocolsearch with 	( readuncommitted )
			where iscachedSearchResultAvailable = 1 and --idstring like @idstring 
				idstringHash = @idstringHash
				 
				and 
				(
				(isLink = 1
				and ISNULL( convert( varchar(900), CancerType), '') = isnull(@cancertype,'')
				and ISNULL( convert( varchar(900), CancerTypeStage ), '') = isnull(@cancertypestage,'')
				and ISNULL( convert( varchar(900), TreatmentType ), '') = isnull(@treatmentType, '')
				and isnull(trialtype,'') = isnull(@trialType, '')
				and isnull(trialstatus, '') =  isnull(@trialstatus, '')
				and ISNULL( Phase , '') = ISNULL( @Phase , '')
				and ISNULL( IsNIHClinicalCenterTrial , '') = ISNULL( @IsNIHClinicalCenterTrial , '')
				and ISNULL( IsNew , '') = ISNULL( @IsNew , '')
				and ISNULL( convert( varchar(900), TreatmentType ), '') = isnull(@treatmentType, '')
				and isnull(drugid, '') =isnull(@drugid,'')  
				and isnull(institutionid, '') = isnull(@institutionid, '')
				and isnull(investigatorid, '') = isnull(@investigatorid, '')
				and isnull(leadorganizationid, '') = isnull(@leadOrganizationid, '')
				and ISNULL( DrugSearchFormula, '') =ISNULL( @DrugSearchFormula, '')				
				)	
				or
				( isLink is null
				and ISNULL( convert( varchar(900), CancerType), '') = isnull(@cancertype,'')
				and ISNULL( convert( varchar(900), CancerTypeStage ), '') = isnull(@cancertypestage,'')
				and ISNULL( convert( varchar(900), AlternateProtocolID ), '') = isnull(@AlternateProtocolID , '')
				and ISNULL( convert( varchar(900), TreatmentType ), '') = isnull(@treatmentType, '')
				and isnull(trialtype,'') = isnull(@trialType, '')
				and isnull(trialstatus, '') =  isnull(@trialstatus, '')
				and ISNULL( Phase , '') = ISNULL( @Phase , '')
				and ISNULL( IsNIHClinicalCenterTrial , '') = ISNULL( @IsNIHClinicalCenterTrial , '')
				and ISNULL( IsNew , '') = ISNULL( @IsNew , '')
				and ISNULL( convert( varchar(900), Drug ), '')=  isnull(@drug,'')
				and ISNULL( ZIP , '') = ISNULL( @ZIP , '')
				and ISNULL( ZIPProximity , '') = ISNULL( @ZIPProximity , '')
				and ISNULL( City , '') = isnull(@city, '')
				and ISNULL( State , '') = ISNULL( @State , '')
				and ISNULL( Country , '') = ISNULL( @Country , '')
				and ISNULL( DrugSearchFormula, '') =ISNULL( @DrugSearchFormula, '')
				and ISNULL(SpecialCategory, '') = ISNULL(@SpecialCategory, '')
				and ISNULL( convert( varchar(900), ParameterOne ), '') = isnull(@parameterOne,'')
				and ISNULL( convert( varchar(900), ParameterThree ), '')= isnull(@parameterThree,'')
				and ISNULL( convert( varchar(900), TrialSponsor) , '') =  isnull(@trialSponsor,'')
				and ISNULL( convert( varchar(900), Institution ), '') = isnull(@institution,'')
				and ISNULL( convert( varchar(900), Investigator ), '') = isnull(@investigator,'')
				and ISNULL( convert( varchar(900), LeadOrganization ), '') =  isnull(@leadOrganization, '')
								)
			)		

		)
			

		if @protocolsearchid is not null
		    begin
			SET @tmpGotCache = 1
	
			IF EXISTS (
				SELECT TOP 1 *   --ProtocolSearchID
				FROM	dbo.ProtocolSearch WITH( READUNCOMMITTED ) 
				WHERE 
					ProtocolSearchID = @ProtocolSearchID 			
					AND convert( varchar(8000), ParameterTwo ) <> @ParameterTwo
					AND ParameterTwo IS NOT NULL
				)
			BEGIN
				-- Update value in ParameterTwo field
				-- because it represent some display informationand may change from time to time	
				UPDATE 	dbo.ProtocolSearch 
				SET 		ParameterTwo = @ParameterTwo 
				FROM		dbo.ProtocolSearch 
				WHERE 	ProtocolSearchID = @ProtocolSearchID 			
			END
		    end	
		    else
			begin
			INSERT INTO dbo.ProtocolSearch
			(	TrialType,
				TrialStatus,
				InstitutionID,
				InvestigatorID,
				LeadOrganizationID,
				IsNIHClinicalCenterTrial,
				IsNew,
				TreatmentType,
				DrugID,
				Phase,
				AbstractVersion,
				ParameterOne,
				ParameterTwo,
				ParameterThree,
				ShowDetailReportMessage,
				DrugSearchFormula,
				SearchType,
				idstring,
				AlternateProtocolID,  	
				ZIP,	
				ZIPProximity,	
				City			,	
				State			,	
				Country		,	
				VAMilitaryOrganization	,  	
				TrialSponsor		,  	
				SpecialCategory,
				drug,
				Institution,
				Investigator,
				LeadOrganization,
				CancerType, 
			 	CancerTypeStage,
				isLink,
				idstringhash



			) VALUES (
				@TrialType,
				@TrialStatus,
				@InstitutionID,
				@InvestigatorID,
				@LeadOrganizationID,
				@IsNIHClinicalCenterTrial,
				@IsNew,
				@TreatmentType,
				@DrugID,
				@Phase,
				@AbstractVersion,
				@ParameterOne,
				@ParameterTwo,
				@ParameterThree,
				@ShowDetailReportMessage,
				@DrugSearchFormula,
				@SearchType,
				@IDstring,
				@AlternateProtocolID	,  	
				@ZIP			,	
				@ZIPProximity		,	
				@City			,	
				@State			,	
				@Country		,	
				@VAMilitaryOrganization	,  	
				@TrialSponsor		,  	
				@SpecialCategory,
				@drug,
				@Institution,
				@Investigator,
				@LeadOrganization,
				@cancerType,
				@cancerTypeStage,
				@isLink,
				@idstringhash

			)
			SET @ProtocolSearchID = @@IDENTITY

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
		--PRINT 'Step 50 - Check do we have Caches Protocol Search Result available.'
		
		SELECT 	@tmpBit = IsCachedSearchResultAvailable
		FROM 	dbo.ProtocolSearch 
		WHERE 	ProtocolSearchID = @ProtocolSearchID 
		
		
		SET @IsCachedSearchResultAvailable = ISNULL( @tmpBit, 0)
		
	END
--print 'At last in adv ' + convert(varchar,isnull(@ProtocolSearchID,0),100)
END



GO
