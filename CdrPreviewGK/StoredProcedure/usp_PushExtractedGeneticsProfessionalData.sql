IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_PushExtractedGeneticsProfessionalData]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_PushExtractedGeneticsProfessionalData]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/****** Object:  Stored Procedure dbo.usp_PushExtractedGeneticsProfessionalData    Script Date: 9/10/2002 10:49:30 AM ******/

/*	NCI - National Cancer Institute
*	
*	Purpose:	
*	- Push Extracted data To CDRPreviewGK	
*
*	Objects Used:
*
*	Change History:
*	2006 GK redesign
*
*	To Do List:
*	
*/

CREATE PROCEDURE dbo.usp_PushExtractedGeneticsProfessionalData
	(
	@DocumentID 	int,
	@UpdateUserID 	varchar(50),
	@CleanOldData	varchar(3) = 'YES' , 
	@isDebug bit = 0
	)
AS
BEGIN
	set nocount on
	--**************************************************************************************************************
	DECLARE @UpdateDate datetime, @r int

	--**************************************************************************************************************
	SELECT 	@UpdateDate = GETDATE()	

	--**************************************************************************************************************
	if @isDebug =1  PRINT  '           *****************************************************************************'
	if @isDebug =1  PRINT  '           STARTED - Push data to GenProf and related tables'

	IF @CleanOldData = 'Yes' 
	BEGIN
		EXEC  @r = CDRLiveGK.dbo.usp_ClearExtractedGeneticProfessionalData @DocumentID
		IF (@@ERROR <> 0) or (@r <> 0)
		BEGIN
			
			RAISERROR ( 70001, 16, 1, @DocumentID, 'GeneticProfessional')
			RETURN 70001
		END 
	END

	--**************************************************************************************************************
	if @isDebug =1  PRINT  '           Push dbo.GenProf table '
	
	INSERT INTO CDRLiveGK..GenProf
		(
		GenProfID,
		ShortName,
		FirstName,
		LastName,
		Suffix,
		Degree,
		UpdateDate,
		UpdateUserID
		)
	SELECT 	GenProfID,
		ShortName,
		FirstName,
		LastName,
		Suffix,
		Degree,
		@UpdateDate,
		@UpdateUserID
	FROM 	CDRPreviewGK..GenProf
	WHERE 	GenProfID = @DocumentID 	

	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 70000, 16, 1, @DocumentID, 'GenProf')
		RETURN 70000
	END 	

	--**************************************************************************************************************
	if @isDebug =1  PRINT  '           Push dbo.GenProfCancerTypeSite table '
	
	INSERT INTO CDRLiveGK.dbo.GenProfCancerTypeSite
		(
		CancerTypeSiteID,
		CancerTypeSite,
		UpdateDate,
		UpdateUserID
		)
	SELECT 	CancerTypeSiteID,
		CancerTypeSite,
		@UpdateDate,
		@UpdateUserID
	FROM 	CDRPreviewGK.dbo.GenProfCancerTypeSite
	WHERE 	CancerTypeSiteID IN (
				SELECT CancerTypeSiteID 
				FROM CDRPreviewGK.dbo.GenProfTypeOfCancer 
				WHERE GenProfID = @DocumentID
				) 
		AND CancerTypeSiteID NOT IN (
			SELECT CancerTypeSiteID 
			FROM 	CDRLiveGK.dbo.GenProfTypeOfCancer 
			) 


	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 70000, 16, 1, @DocumentID, 'dbo.GenProfCancerTypeSite')
		RETURN 70000
	END 	

	--**************************************************************************************************************
	if @isDebug =1  PRINT  '           Push dbo.GenProfFamilyCancerSyndrome table '
	INSERT INTO CDRLiveGK.dbo.GenProfFamilyCancerSyndrome
		(
		FamilyCancerSyndromeID,
		GenProfID,
		FamilyCancerSyndrome,
		UpdateDate,
		UpdateUserID
		)
	SELECT 	FamilyCancerSyndromeID,
		GenProfID,
		FamilyCancerSyndrome,
		@UpdateDate,
		@UpdateUserID
	FROM 	CDRPreviewGK.dbo.GenProfFamilyCancerSyndrome
	WHERE 	GenProfID = @DocumentID 	

	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 70000, 16, 1, @DocumentID, 'dbo.GenProfFamilyCancerSyndrome')
		RETURN 70000
	END 	

	--**************************************************************************************************************
	if @isDebug =1  PRINT  '           Push dbo.GenProfPracticeLocation table '
	
	INSERT INTO CDRLiveGK.dbo.GenProfPracticeLocation
		(
		GenProfID,
		City,
		State,
		PostalCode,
		Country,
		UpdateDate,
		UpdateUserID
		)
	SELECT 	GenProfID,
		City,
		State,
		PostalCode,
		Country,
		@UpdateDate,
		@UpdateUserID
	FROM 	CDRPreviewGK.dbo.GenProfPracticeLocation
	WHERE 	GenProfID = @DocumentID 	

	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 70000, 16, 1, @DocumentID, 'dbo.GenProfPracticeLocation')
		RETURN 70000
	END 	

	--**************************************************************************************************************
	if @isDebug =1  PRINT  '           Push dbo.GenProfTypeOfCancer table '
	
	INSERT INTO CDRLiveGK.dbo.GenProfTypeOfCancer
		(
		GenProfID,
		CancerTypeSiteID,
		FamilyCancerSyndromeID,
		UpdateDate,
		UpdateUserID
		)
	SELECT 	GenProfID,
		CancerTypeSiteID,
		FamilyCancerSyndromeID,
		@UpdateDate,
		@UpdateUserID
	FROM 	CDRPreviewGK.dbo.GenProfTypeOfCancer
	WHERE 	GenProfID = @DocumentID 	

	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 70000, 16, 1, @DocumentID, 'dbo.GenProfTypeOfCancer')
		RETURN 70000
	END 	


	--**************************************************************************************************************
	if @isDebug =1  PRINT  '           Push dbo.DOCumentXML table '
	
	INSERT INTO CDRLiveGK.dbo.DocumentXML
		(
		DocumentID,
		XML
		)
	SELECT 
		DocumentID,
		XML	
	FROM 	CDRPreviewGK.dbo.DocumentXML
	WHERE 	DocumentID = @DocumentID 	

	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 70000, 16, 1, @DocumentID, 'dbo.DOCumentXML')
		RETURN 70000
	END 	


	--**************************************************************************************************************
	if @isDebug =1  PRINT  '           DONE - Push data to GenProf and related tables '


	RETURN 0

END

GO
GRANT EXECUTE ON [dbo].[usp_PushExtractedGeneticsProfessionalData] TO [Gatekeeper_role]
GO
