IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_PushExtractedSummaryData]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_PushExtractedSummaryData]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE dbo.usp_PushExtractedSummaryData
	(
	@DocumentID 	int,
	@UpdateUserID 	varchar(50),
	@CleanOldData	varchar(3) = 'YES' , 
	@isDebug bit = 0
	)
AS
BEGIN
	set nocount on 
	DECLARE @UpdateDate datetime, @r int
	SELECT 	@UpdateDate = GETDATE()	
	if @isDebug =1  PRINT  '           STARTED - PushExtractedSummaryData '

	IF @CleanOldData = 'Yes' 
	BEGIN
		EXEC @r = CDRLiveGK.dbo.usp_ClearExtractedSummaryData @DocumentID
		IF (@@ERROR <> 0) or ( @r <> 0)
		BEGIN
			
			RAISERROR ( 70001, 16, 1, @DocumentID, 'Summary')
			RETURN 70001
		END 
	END

	--**************************************************************************************************************
	if @isDebug =1  PRINT  '           Push dbo.Summary table '
	
	INSERT INTO CDRLiveGK.dbo.Summary
		(
		SummaryID,
		Type,
		Audience,
		Language,
		Title,
		ShortTitle,
		UpdateDate,
		UpdateUserID,
		Description,
		PrettyUrl,
		replacementDocumentID
		)
	SELECT 	SummaryID,
		Type,
		Audience,
		Language,
		Title,
		ShortTitle,
		@UpdateDate,
		@UpdateUserID,
		Description,
		PrettyUrl,
		replacementDocumentID
	FROM 	CDRPreviewGK.dbo.Summary
	WHERE 	SummaryID = @DocumentID 	

	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 70000, 16, 1, @DocumentID, 'Summary')
		RETURN 70000
	END 	

		--**************************************************************************************************************
	if @isDebug =1  PRINT  '           Push dbo.SummaryRelations table '

	INSERT INTO CDRLiveGK.dbo.SummaryRelations
		(
		SummaryID,
		RelatedSummaryID,
		RelationType,
		UpdateDate,
		UpdateUserID
		)
	SELECT 	SummaryID,
		RelatedSummaryID,
		RelationType,
		@UpdateDate,
		@UpdateUserID
	FROM 	CDRPreviewGK.dbo.SummaryRelations
	WHERE 	SummaryID = @DocumentID 	

	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 70000, 16, 1, @DocumentID, 'SummaryRelations')
		RETURN 70000
	END 	

	--**************************************************************************************************************
	if @isDebug =1  PRINT  '           Push dbo.SummarySection table '

	INSERT INTO CDRLiveGK.dbo.SummarySection
		(
			SummarySectionID, 
			SummaryGUID, 
			SummaryID, 
			SectionID, 
			SectionType, 
			SectionTitle, 
			Priority, 
			SectionLevel, 
			ParentSummarySectionID, 
			TOC,
			[HTML]
		)
	SELECT 	SummarySectionID, 
			SummaryGUID, 
			SummaryID, 
			SectionID, 
			SectionType, 
			SectionTitle, 
			Priority, 
			SectionLevel, 
			ParentSummarySectionID, 
			TOC,
			[HTML]
	FROM 	CDRPreviewGK.dbo.SummarySection
	WHERE 	SummaryID = @DocumentID 	

	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 70000, 16, 1, @DocumentID, 'SummarySection')
		RETURN 70000
	END 	


	if @isDebug =1  PRINT  '           DONE - Push data to Summary and related tables from PREVIEW to LIVE'

	RETURN 0

END


GO
GRANT EXECUTE ON [dbo].[usp_PushExtractedSummaryData] TO [Gatekeeper_role]
GO
