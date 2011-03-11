IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_PushExtractedProtocolData]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_PushExtractedProtocolData]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  Stored Procedure dbo.usp_PushExtractedProtocolData    Script Date: 7/27/2005 12:47:38 PM ******/


/*	NCI - National Cancer Institute
*	
*	Purpose:	
*	- Push Extracted data To CDRLive	
*
*	Objects Used:
*
*	Change History:
*	Min
*	To Do List:
*	- use transactions
*
*/

CREATE PROCEDURE dbo.usp_PushExtractedProtocolData
	(
	@DocumentID 	int,
	@UpdateUserID 	varchar(50),
	@CleanOldData	varchar(3) = 'YES' ,
	@isDebug bit = 0
	)
AS
BEGIN

	Set nocount on
	
	DECLARE @UpdateDate datetime

	
	declare @r INT 


	SELECT 	@UpdateDate = GETDATE()	
	SELECT 	@UpdateUserID = ISNULL( @UpdateUserID, sUSER_sNAME()) 

		if @isDebug = 1 		PRINT  '           START - Push Protocol data from PREVIEW to Live'

	IF @CleanOldData = 'Yes' 
	BEGIN
		EXEC @r = CDRLiveGK..usp_ClearExtractedProtocolData @DocumentID
		IF (@@ERROR <> 0) or (@r <> 0 )
		BEGIN
			
			RAISERROR ( 70001, 16, 1, @documentID, 'Protocol')
			RETURN 70001
		END 
	END





	--**************************************************************************************************************
	if @isDebug = 1 		PRINT  '           Push dbo.Protocol table '
	INSERT INTO CDRLiveGK..Protocol
		(
		protocolid, isnew, isnihclinicalCenterTrial, isactiveprotocol, 
		UpdateDate, 
		UpdateUserID 
		)
	SELECT 	protocolid, isnew, isnihclinicalCenterTrial, isactiveprotocol,
		@UpdateDate, 
		@UpdateUserID 
	FROM 	CDRPreviewGK..Protocol
	WHERE 	ProtocolID = @DocumentID 	

	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 70000, 16, 1, @documentID, 'Protocol')
		RETURN 70000
	END 

	--**************************************************************************************************************
	if @isDebug = 1 		PRINT '           Push dbo.ProtocolOldID table '
	INSERT INTO CDRLiveGK.dbo.ProtocolOldID
		(
		ProtocolID,
		OldPrimaryProtocolID
		)
	SELECT	ProtocolID,
		OldPrimaryProtocolID
	FROM CDRPreviewGK.dbo.ProtocolOldID
	WHERE ProtocolID = @DocumentID

	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 70000, 16, 1, @documentID, 'ProtocolOLDID')
		RETURN 70000
	END 

	--**************************************************************************************************************
	if @isDebug = 1 		PRINT '           Push dbo.ProtocolDetail table '
	INSERT INTO CDRLiveGK..ProtocolDetail
		(
		protocolid,
		HealthProfessionalTitle,
		PatientTitle,
		LowAge,
		HighAge,
		AgeRange,
		IsPatientVersionExists,
		PrimaryProtocolID,
		isCTprotocol,
		DateFirstPublished,
		DateLastModified,
		CurrentStatus,
		AlternateProtocolIDs,
		Phase,
		sponsorofTrial,	typeofTrial ,
		PrimaryPrettyUrlID,
		updatedate,
		updateUserid
		)
	SELECT 	protocolid,
			HealthProfessionalTitle,
			PatientTitle,
			LowAge,
			HighAge,
			AgeRange,
			IsPatientVersionExists,
			PrimaryProtocolID,
			isCTprotocol,
			DateFirstPublished,
			DateLastModified,
			CurrentStatus,
			AlternateProtocolIDs,
			Phase,
			sponsorofTrial,	typeofTrial, 
			PrimaryPrettyUrlID,
		@UpdateDate, 
		@UpdateUserID 
	FROM 	CDRPreviewGK..ProtocolDetail
	WHERE 	ProtocolID = @DocumentID 	

	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 70000, 16, 1, @documentID, 'ProtocolDetail')
		RETURN 70000
	END 


	--**************************************************************************************************************
	if @isDebug = 1 		PRINT '           Push dbo.ProtocolSecondaryUrl table '
	INSERT INTO CDRLiveGK.dbo.ProtocolSecondaryUrl
		(
		ProtocolID,
		IDString,
		updatedate,
		updateUserid
		)
	SELECT	ProtocolID,
		IDString,
		@UpdateDate, 
		@UpdateUserID 
	FROM CDRPreviewGK.dbo.ProtocolSecondaryUrl
	WHERE ProtocolID = @DocumentID

	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 70000, 16, 1, @documentID, 'ProtocolSecondaryUrl')
		RETURN 70000
	END 


	--**************************************************************************************************************
	if @isDebug = 1 		PRINT  '           Push dbo.ProtocolAlternateID table '

	INSERT INTO CDRLiveGK.dbo.ProtocolAlternateID
		(
		protocolid, idstring, idtypeid, 
		UpdateDate, 
		UpdateUserID
		)
	SELECT 	protocolid, idstring, idtypeid,
		@UpdateDate, 
		@UpdateUserID 
	FROM 	CDRPreviewGK.dbo.ProtocolAlternateID
	WHERE 	ProtocolID = @DocumentID 	

	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 70000, 16, 1, @documentID, 'ProtocolAlternateID')
		RETURN 70000
	END 

	--**************************************************************************************************************
	if @isDebug = 1 		PRINT  '           Push dbo.ProtocolContactInfo table '


	INSERT INTO CDRLiveGK.dbo.ProtocolTrialSite

		(
		protocolid, protocolcontactinfoid, personid, organizationid, 
		organizationname, personGivenname, personSurname , state, zip, city, country, [PersonProfessionalSuffix]
		,organizationrole,statefullname,
		UpdateDate, 
		UpdateUserID
		)
	SELECT 
		protocolid, protocolcontactinfoid, personid, organizationid, 
		organizationname, personGivenname, personSurname , state, zip, city, country, [PersonProfessionalSuffix]
		,organizationrole,statefullname,
		@UpdateDate, 
		@UpdateUserID 
	FROM 	CDRPreviewGK.dbo.ProtocolTrialsite
	WHERE 	ProtocolID = @DocumentID 	

	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 70000, 16, 1, @documentID, 'ProtocolTrialSite')
		RETURN 70000
	END 


		INSERT INTO CDRLiveGK.dbo.ProtocolLeadOrg
		(
		protocolid, protocolcontactinfoid, personid, organizationid, 
		organizationname, personGivenname, personSurname, [PersonProfessionalSuffix],
		state,  city, country, organizationrole, personrole,
		UpdateDate, 
		UpdateUserID
		)
	SELECT 
		protocolid, protocolcontactinfoid, personid, organizationid, 
		organizationname, personGivenname, personSurname, [PersonProfessionalSuffix],
		state,  city, country, organizationrole, personrole,
		@UpdateDate, 
		@UpdateUserID 
	FROM 	CDRPreviewGK.dbo.ProtocolLeadorg
	WHERE 	ProtocolID = @DocumentID 	

	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 70000, 16, 1, @documentID, 'ProtocolLeadOrg')
		RETURN 70000
	END 

	--**************************************************************************************************************
	if @isDebug = 1 		PRINT  '           Push dbo.ProtocolDrug table '

	INSERT INTO CDRLiveGK.dbo.ProtocolDrug
		(
		protocolid, drugid,
		UpdateDate, 
		UpdateUserID
		)
	SELECT 	
		protocolid, drugid,
		@UpdateDate, 
		@UpdateUserID 
	FROM 	CDRPreviewGK.dbo.ProtocolDrug
	WHERE 	ProtocolID = @DocumentID 	

	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 70000, 16, 1, @documentID, 'ProtocolDrug')
		RETURN 70000
	END 

	--**************************************************************************************************************
	if @isDebug = 1 		PRINT  '           Push dbo.ProtocolModality table '

	INSERT INTO CDRLiveGK.dbo.ProtocolModality
		(
		protocolid, modalityid,
		UpdateDate, 
		UpdateUserID
		)
	SELECT 	
		protocolid, modalityid,
		@UpdateDate, 
		@UpdateUserID 
	FROM 	CDRPreviewGK.dbo.ProtocolModality
	WHERE 	ProtocolID = @DocumentID 	

	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 70000, 16, 1, @documentID, 'ProtocolModality')
		RETURN 70000
	END 

	--**************************************************************************************************************
	if @isDebug = 1 		PRINT  '           Push dbo.ProtocolPhase table '

	INSERT INTO CDRLiveGK.dbo.ProtocolPhase
		(
		Phase, 
		ProtocolID, 
		UpdateDate, 
		UpdateUserID
		)
	SELECT 	Phase, 
		ProtocolID, 
		@UpdateDate, 
		@UpdateUserID 
	FROM 	CDRPreviewGK.dbo.ProtocolPhase
	WHERE 	ProtocolID = @DocumentID 	

	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 70000, 16, 1, @documentID, 'ProtocolPhase')
		RETURN 70000
	END 

	--**************************************************************************************************************
	if @isDebug = 1 		PRINT  '           Push dbo.ProtocolSpecialCategory table '

	INSERT INTO CDRLiveGK.dbo.ProtocolSpecialCategory
		(
		ProtocolID,
		ProtocolSpecialCategory,
		UpdateDate, 
		UpdateUserID
		)
	SELECT 	ProtocolID, 
		ProtocolSpecialCategory,
		@UpdateDate, 
		@UpdateUserID 
	FROM 	CDRPreviewGK.dbo.ProtocolSpecialCategory
	WHERE 	ProtocolID = @DocumentID 	

	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 70000, 16, 1, @documentID, 'ProtocolSpecialCategory')
		RETURN 70000
	END 


	--**************************************************************************************************************
	if @isDebug = 1 		PRINT  '           Push dbo.ProtocolSponsors table '

	INSERT INTO CDRLiveGK.dbo.ProtocolSponsors
		(
		ProtocolID, 
		SponsorID, 
		UpdateDate, 
		UpdateUserID
		)
	SELECT 	ProtocolID, 
		SponsorID, 
		@UpdateDate, 
		@UpdateUserID 
	FROM 	CDRPreviewGK.dbo.ProtocolSponsors
	WHERE 	ProtocolID = @DocumentID 	

	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 70000, 16, 1, @documentID, 'ProtocolSponsors')
		RETURN 70000
	END 

	
	--**************************************************************************************************************
	if @isDebug = 1 		PRINT  '           Push dbo.ProtocolStudyCategory table '

	INSERT INTO CDRLiveGK.dbo.ProtocolStudyCategory
		(
		ProtocolID, 
		StudyCategoryID, 
		UpdateDate, 
		UpdateUserID
		)
	SELECT 	ProtocolID, 
		StudyCategoryID, 
		@UpdateDate, 
		@UpdateUserID 
	FROM 	CDRPreviewGK.dbo.ProtocolStudyCategory
	WHERE 	ProtocolID = @DocumentID 	

	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 70000, 16, 1, @documentID, 'ProtocolStudyCategory')
		RETURN 70000
	END 


	--**************************************************************************************************************
	if @isDebug = 1 		PRINT  '           Push dbo.ProtocolTypeOfCancer table '

	INSERT INTO CDRLiveGK.dbo.ProtocolTypeOfCancer
		(
		protocolid, diagnosisid,
		UpdateDate, 
		UpdateUserID
		)
	SELECT 	
		protocolid, diagnosisid,
		@UpdateDate, 
		@UpdateUserID 
	FROM 	CDRPreviewGK.dbo.ProtocolTypeOfCancer
	WHERE 	ProtocolID = @DocumentID 	

	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 70000, 16, 1, @documentID, 'ProtocolTypeOfCancer')
		RETURN 70000
	END 


	--**************************************************************************************************************
	if @isDebug = 1 		PRINT  '           Push [dbo].[ProtocolSection] table '

	IF NOT EXISTS (
			SELECT 	1
			FROM 	[CDRPreviewGK].[dbo].[ProtocolSection]
			WHERE 	ProtocolID = @DocumentID 	
			)
	BEGIN
		-- if no data was found in ProtocolSection then procedure return a error
		-- because then we do not have anything to show up 
		
		RAISERROR ( 70000, 16, 1, @documentID, 'ProtocolSection')
		RETURN 70000
	END

	INSERT INTO CDRLiveGK.[dbo].[ProtocolSection](
		ProtocolSectionID, 
		ProtocolID, 
		SectionID, 
		SectionTypeID, 
		Audience, 
		[HTML], 
		UpdateDate, 
		UpdateUserID
		)
	SELECT 	ProtocolSectionID, 
		ProtocolID, 
		SectionID, 
		SectionTypeID, 
		Audience, 
		[HTML], 
		@UpdateDate, 
		@UpdateUserID
	FROM 	[CDRPreviewGK].[dbo].[ProtocolSection]
	WHERE 	ProtocolID = @DocumentID 	

	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 70000, 16, 1, @documentID, 'ProtocolSection')
		RETURN 70000
	END 

	--**************************************************************************************************************
	if @isDebug = 1 		PRINT  '           Push [dbo].[ProtocolContactInfoHTML] table '

	INSERT INTO CDRLiveGK.[dbo].[ProtocolContactInfoHTML] 
		(
		ProtocolContactInfoHTMLID, 
		ProtocolID, 
		City, 
		State, 
		Country, 
		OrganizationName, 
		[HTML], 
		UpdateDate, 
		UpdateUserID
		)
	SELECT 	ProtocolContactInfoHTMLID, 
		ProtocolID, 
		City, 
		State, 
		Country, 
		OrganizationName, 
		[HTML], 
		@UpdateDate, 
		@UpdateUserID
	FROM 	[CDRPreviewGK].[dbo].[ProtocolContactInfoHTML] 
	WHERE 	ProtocolID = @DocumentID

	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 70000, 16, 1, @documentID, 'ProtocolContactInfoHTML')
		RETURN 70000
	END 

	--**************************************************************************************************************
	if @isDebug = 1 		PRINT  '           Push [dbo].[ProtocolContactInfoHtmlMap] table '

	INSERT INTO CDRLiveGK.[dbo].[ProtocolContactInfoHtmlMap] 
		(
		ProtocolContactInfoHtmlID, 
		ProtocolContactInfoID
		)
	SELECT 	pcihm.ProtocolContactInfoHtmlID, 
		ProtocolContactInfoID
	FROM 	[CDRStagingGK].[dbo].[ProtocolContactInfoHtmlMap]  pcihm inner join [CDRStagingGK].[dbo].[ProtocolContactInfoHTML]  pcih
	on pcihm.ProtocolContactInfoHtmlID = pcih.ProtocolContactInfoHtmlID
	WHERE 	ProtocolID = @DocumentID

	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 70000, 16, 1, @documentID, 'ProtocolContactInfoHTMLMap')
		RETURN 70000
	END 

	 
	if @isDebug = 1 		PRINT  '           DONE - Push Protocol data from PREVIEW to Live '
	

	RETURN 0
END


GO
GRANT EXECUTE ON [dbo].[usp_PushExtractedProtocolData] TO [Gatekeeper_role]
GO
