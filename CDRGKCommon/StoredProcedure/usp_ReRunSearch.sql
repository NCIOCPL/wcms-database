IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_ReRunSearch]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_ReRunSearch]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/****** Object:  Stored Procedure dbo.usp_ReRunSearch    Script Date: 8/8/2005 1:32:56 PM ******/

/****** Object:  Stored Procedure dbo.usp_ReRunSearch    Script Date: 7/18/2005 12:12:40 PM ******/


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
*	??/??/2002 	John Do		Script Created
*	7/16/2003 	Alex Pidlisnyy	Add new parameters, review function
* 	03/14/2005	Lijia Chu	For SCR1067,  subtype was missing.
*	7/19/2005 	Min		Add ProtocolSpecialCategory parameter
*
*************************************************************************************************************/

-- select  * FROM ProtocolSearch WITH (READUNCOMMITTED) WHERE ProtocolSearchID = 45394
-- exec usp_ReRunSearch @ProtocolSearchID = 186566

CREATE PROCEDURE dbo.usp_ReRunSearch
(
	@ProtocolSearchID int
)
AS
BEGIN	
	set nocount on
	create table #Table1
	(	
		a int,
		b int
	)

	declare	@CancerType 		varchar(8000),
	 	@CancerTypeStage 	varchar(8000),
		@TrialType		varchar(100) ,
		@TrialStatus		char(1) ,
		@AlternateProtocolID	varchar(8000),
		@ZIP			varchar(10),
		@ZIPProximity		int	,
		@City			varchar(50),
		@State			varchar(50),
		@Country		varchar(50),
		@Institution		varchar(8000),
		@Investigator		varchar(8000),
		@LeadOrganization	varchar(8000),
		@VAMilitaryOrganization	varchar(8000),
		@IsNIHClinicalCenterTrial char(1),
		@IsNew			char(1)	,
		@TreatmentType		varchar(8000),
		@DrugSearchFormula	varchar(100), 
	 	@Drug 			varchar(8000),
		@Phase			varchar(100),
		@TrialSponsor		varchar(100),
		@AbstractVersion	varchar(50),
		@ParameterOne		varchar(8000),
		@ParameterTwo		varchar(8000),
		@ParameterThree		varchar(8000),
		@SpecialCategory	varchar(1000), ---- Gao 7/18 SC
		@IsCachedContactsAvailable bit




	SELECT 	TOP 1
		@CancerType = CancerType,  		
	 	@CancerTypeStage = CancerTypeStage,  	
		@TrialType = TrialType,  		
		@TrialStatus = TrialStatus, 		
		@AlternateProtocolID = AlternateProtocolID,
		@ZIP = ZIP,				
		@ZIPProximity = ZIPProximity,		
		@City = City,				
		@State = State,				
		@Country = Country,			
		@Institution = Institution,  		
		@Investigator = Investigator,  		
		@LeadOrganization = LeadOrganization,  	
		@VAMilitaryOrganization = VAMilitaryOrganization,
		@IsNIHClinicalCenterTrial = IsNIHClinicalCenterTrial,
		@IsNew = IsNew,
		@TreatmentType = TreatmentType,
		@DrugSearchFormula = DrugSearchFormula,
	 	@Drug = Drug,
		@Phase = Phase,
		@TrialSponsor = TrialSponsor,
		@AbstractVersion = AbstractVersion,
		@ParameterOne = ParameterOne,
		@ParameterTwo = ParameterTwo,
		@ParameterThree = ParameterThree,
		@IsCachedContactsAvailable = IsCachedContactsAvailable,
		@specialCategory = SpecialCategory  ---- Gao 7/18 SC
	-- select top 10 distinct convert ( varchar, ParameterOne )
	-- select top 10 ProtocolSearchID 
 	FROM 	ProtocolSearch 
		WITH (READUNCOMMITTED)
	WHERE 	ProtocolSearchID = @ProtocolSearchID 

	IF @IsCachedContactsAvailable <> 1 
	BEGIN
		IF @ParameterOne = 'simplesearch'
		BEGIN

			EXECUTE usp_ProtocolSearchSimpleExtended 
				@CancerType = @CancerType, 
				@CancerTypeStage = @CancerTypeStage, 
				@TrialType = @TrialType, 
				@ZIP = @ZIP, 
				@ZIPProximity = @ZIPProximity, 
				@ParameterOne = @ParameterOne, 
				@ParameterTwo = @ParameterTwo, 
				@ParameterThree = @ParameterThree, 
				@GetCachedSearchResult=0,
				@ProtocolSearchID = @ProtocolSearchID,
				@IsReRun = 1

		END
		ELSE BEGIN

			EXECUTE usp_ProtocolSearchExtended 
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
				@ProtocolSearchID = @ProtocolSearchID,
				@GetCachedSearchResult=0,
				@specialCategory = @specialCategory ,---- Gao 7/18 SC
				@IsReRun = 1
		END
	END
	-- Print 'Cool'
END



GO
