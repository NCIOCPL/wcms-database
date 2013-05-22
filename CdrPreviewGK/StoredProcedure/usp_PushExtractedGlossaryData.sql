IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_PushExtractedGlossaryData]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_PushExtractedGlossaryData]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/*	NCI - National Cancer Institute
*	
*	Purpose:	
*	- Push Extracted data To CDRLiveGK	
*
*	Objects Used:
*
*	Change History:
*	Min
*	To Do List:
*	- use transactions
*	- check for correct error messages	
*
*/

CREATE PROCEDURE dbo.usp_PushExtractedGlossaryData
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

	if @isDebug =1  PRINT  '           STARTED - Push data to Terminology and related tables from STAGING to PREVIEW '

	IF @CleanOldData = 'Yes' 
	BEGIN
		EXEC @r =  CDRLiveGK.dbo.usp_ClearExtractedGlossaryData @DocumentID
		IF (@@ERROR <> 0) or (@r <>0)
		BEGIN
			
			RAISERROR ( 70001, 16, 1, @DocumentID, 'Glossary')
			RETURN 70001
		END 
	END

	--**************************************************************************************************************
	if @isDebug =1  PRINT  '           Push GlossaryTerm table '
	-- select * from CDRLiveGK.dbo.GlossaryTerm 
	INSERT INTO CDRLiveGK.dbo.GlossaryTerm
		(
		GlossaryTermID, 
		TermName, 
		TermPronunciation, 
		SpanishTermName, 
		UpdateDate, 
		UpdateUserID
		)
	SELECT 	GlossaryTermID, 
		TermName, 
		TermPronunciation, 
		SpanishTermName, 
		@UpdateDate,
		@UpdateUserID
	FROM 	CDRPreviewGK.dbo.GlossaryTerm 
	WHERE 	GlossaryTermID = @DocumentID 	

	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 70000, 16, 1, @DocumentID, 'GlossaryTerm')
		RETURN 70000
	END 	

	--**************************************************************************************************************
	if @isDebug =1  PRINT  '           Push GlossaryTermDefinition table '
	
	INSERT INTO CDRLiveGK.dbo.GlossaryTermDefinition
		(
		GlossaryTermDefinitionID, 
		GlossaryTermID, 
		DefinitionText, 
		DefinitionHTML, 
		Language, 
		UpdateDate, 
		UpdateUserID,
		MediaHTML,
		MediaCaption,
		MediaID,
		AudioMediaHTML,
		RelatedInformationHtml
		)
	SELECT 	GlossaryTermDefinitionID, 
		GlossaryTermID, 
		DefinitionText, 
		DefinitionHTML,
		Language, 
		@UpdateDate,
		@UpdateUserID,
		MediaHTML,
		MediaCaption,
		MediaID,
		AudioMediaHTML,
		RelatedInformationHtml
	FROM 	CDRPreviewGK..GlossaryTermDefinition
	WHERE 	GlossaryTermID = @DocumentID 	

	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 70000, 16, 1, @DocumentID, 'GlossaryTermDefinition' )
		RETURN 70000
	END 	

	--**************************************************************************************************************
	if @isDebug =1  PRINT  '           Push dbo.GlossaryTermDefinitionAudience table '
	
	INSERT INTO CDRLiveGK.dbo.GlossaryTermDefinitionAudience
		(
		GlossaryTermDefinitionAudienceID, 
		GlossaryTermDefinitionID, 
		Audience, 
		UpdateDate, 
		UpdateUserID
		)
	SELECT 	GlossaryTermDefinitionAudienceID, 
		GlossaryTermDefinitionID, 
		Audience, 
		@UpdateDate,
		@UpdateUserID
	FROM 	CDRPreviewGK.dbo.GlossaryTermDefinitionAudience
	WHERE 	GlossaryTermDefinitionID IN (
			SELECT 	GlossaryTermDefinitionID
			FROM 	CDRPreviewGK..GlossaryTermDefinition
			WHERE 	GlossaryTermID = @DocumentID 	
			)

	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 70000, 16, 1, @DocumentID, 'GlossaryTermDefinitionAudience')
		RETURN 70000
	END 	

	--**************************************************************************************************************
	if @isDebug =1  PRINT  '           Push dbo.GlossaryTermDefinitionDictionary table '
	
	INSERT INTO CDRLiveGK.dbo.GlossaryTermDefinitionDictionary
		(
		GlossaryTermDefinitionDictionaryID, 
		GlossaryTermDefinitionID, 
		Dictionary, 
		UpdateDate, 
		UpdateUserID
		)
	SELECT 	GlossaryTermDefinitionDictionaryID, 
		GlossaryTermDefinitionID, 
		Dictionary, 
		@UpdateDate,
		@UpdateUserID
	FROM 	CDRPreviewGK.dbo.GlossaryTermDefinitionDictionary
	WHERE 	GlossaryTermDefinitionID IN (
			SELECT 	GlossaryTermDefinitionID
			FROM 	CDRPreviewGK..GlossaryTermDefinition
			WHERE 	GlossaryTermID = @DocumentID 	
			)

	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 70000, 16, 1, @DocumentID, 'GlossaryTermDefinitionAudience')
		RETURN 70000
	END 	


	--**************************************************************************************************************
	if @isDebug =1  PRINT  '           DONE - Push data to Terminology and related tables from  PREVIEW to LIVE'

	RETURN 0

END



GO
GRANT EXECUTE ON [dbo].[usp_PushExtractedGlossaryData] TO [Gatekeeper_role]
GO
