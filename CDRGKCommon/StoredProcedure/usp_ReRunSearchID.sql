IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_ReRunSearchID]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_ReRunSearchID]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/****** Object:  Stored Procedure dbo.usp_ReRunSearchID    Script Date: 9/12/2005 5:10:15 PM ******/

/****** Object:  Stored Procedure dbo.usp_ReRunSearchID    Script Date: 8/16/2005 3:58:38 PM ******/

/*************************************************************************************************************
* NCI - National Cancer Institute
* 
* 
* Purpose: 
* 
*
* Objects Used:
* 
*
* Change History:
*	7/19/2005 	Min		Add ProtocolSpecialCategory parameter
**	9/10/2005 	Min		CT link & ID search 
*************************************************************************************************************/



CREATE PROCEDURE dbo.usp_ReRunSearchID
(
	@ProtocolSearchID int
)
AS
BEGIN	
	set nocount on
	create table #table1 
	(	
		a int,
		b int
	)

	declare	
		@AbstractVersion	varchar(50),
		@ParameterOne		varchar(8000),
		@ParameterTwo		varchar(8000),
		@ParameterThree		varchar(8000),
		@SpecialCategory	varchar(1000), ---- Gao 7/18 SC
		@IsCachedsearchresultAvailable bit,
		@IsNIHClinicalCenterTrial char(1),
		@IsNew			char(1)	,
	@DrugSearchFormula	varchar(100), 
	@TrialStatus		char(1) ,
	@cancertype varchar(8000) ,
	@cancerTypeStage varchar(8000) ,
	@trialType 	varchar(1000) ,
	@InstitutionID		varchar(8000)	,  	-- coma separated list of Hospitals/Institution
	@InvestigatorID		varchar(8000)	,  	-- (+) coma separated list of string (GivenName+Space+SurName) 
	@LeadOrganizationID	varchar(8000)	,  	-- (+) coma separated list of strings 
	@TreatmentType	varchar(8000)	, 	-- (+) coma separated list of Modality CDR IDs
 	@DrugID 		varchar(8000)	,  	-- (+) coma separated list of CDR IDs
	@Phase		varchar(100)	,  	-- (+) coma separated list of string
	@idstring varchar(8000)	,
	@idstringHash int,
	@AlternateProtocolID	varchar(8000)	,  	-- (+) coma separated list of Protocol IDs
	@ZIP			varchar(10)	,		-- (+) 00000-0000
	@ZIPProximity		int		,		-- proximity mile radius
	@City			varchar(50)	,		-- (+) city 
	@State			varchar(50)	,		-- (+) state
	@Country		varchar(50)	,		-- (+) country
	@VAMilitaryOrganization	varchar(8000)	,  	-- (+) coma separated list of OrganizationIDs
	@TrialSponsor		varchar(8000),	 	-- (+) coma separated list of string
	@treatmenttypeName varchar(max),
	@keyword nvarchar(400)



	SELECT 	TOP 1
		@Phase = phase,
		@TrialType = TrialType, 
		@IsNIHClinicalCenterTrial = IsNIHClinicalCenterTrial, 
		@DrugSearchFormula = DrugSearchFormula,
		@TreatmentType = TreatmentType, 
		@TrialStatus = TrialStatus , 
		@IsNew = IsNew, 
		@TrialSponsor = TrialSponsor , 
		@AlternateProtocolID = AlternateProtocolID , 
		@ZIP = ZIP, 
		@ZIPProximity = ZIPProximity, 
		@State = State, 
		@City = City , 
		@Country = Country, 
		@specialCategory = specialCategory ,
		@ParameterTwo = ParameterTwo, 
		@ParameterThree = ParameterThree, 
		@ParameterOne = ParameterOne,
		@cancerType = cancerType,
		@cancerTypestage = cancerTypeStage,
		@DrugID = DrugID, 
		@InstitutionID = InstitutionID, 
		@InvestigatorID = InvestigatorID, 
		@LeadOrganizationID = LeadOrganizationID, 
		@idstring = idstring,
		@idstringHash = idstringHash,
		@AbstractVersion = AbstractVersion,
		@VAMilitaryOrganization=VAMilitaryOrganization	,  	
		@IsCachedsearchresultAvailable = IsCachedsearchresultAvailable,
		@keyword = keyword,
		@treatmenttypeName = treatmenttypeName
 	FROM 	dbo.ProtocolSearch 
		WITH (READUNCOMMITTED)
	WHERE 	ProtocolSearchID = @ProtocolSearchID 


	
	IF @IsCachedsearchresultAvailable<> 1 
	BEGIN
		

		EXECUTE dbo.usp_ProtocolSearchExtended_IDadv1FullText
		@phase =@phase,
		@TrialType = @TrialType, 
		@IsNIHClinicalCenterTrial = @IsNIHClinicalCenterTrial, 
		@DrugSearchFormula = @DrugSearchFormula,
		@TreatmentType = @TreatmentType, 
		@TrialStatus = @TrialStatus , 
		@IsNew = @IsNew, 
		@TrialSponsor = @TrialSponsor , 
		@AlternateProtocolID = @AlternateProtocolID , 
		@ZIP = @ZIP, 
		@ZIPProximity = @ZIPProximity, 
		@State = @State, 
		@City = @City , 
		@Country = @Country, 
		@specialCategory = @specialCategory ,
		@ParameterTwo = @ParameterTwo, 
		@ParameterThree = @ParameterThree, 
		@ParameterOne = @ParameterOne,
		@cancerTYpe = @cancerTYpe,
		@cancerTYpeStage = @cancerTYpeStage,
		@DrugID = @DrugID, 
		@InstitutionID = @InstitutionID, 
		@InvestigatorID = @InvestigatorID, 
		@LeadOrganizationID = @LeadOrganizationID, 
		@idstring = @idstring,
		@idstringHash = @idstringhash,
		@AbstractVersion = @AbstractVersion,
		--@GetCachedSearchResult=0,
		@VAMilitaryOrganization=@VAMilitaryOrganization	 ,
		@ProtocolSearchID = @ProtocolSearchID 	,
		@keyword = @keyword,
		@treatmentTypeName = @treatmentTypeName,
		@IsReRun = 1
	

	END





	-- Print 'Cool'
END





GO
