IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_PushExtractedTerminologyData]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_PushExtractedTerminologyData]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*	NCI - National Cancer Institute
*	Min
*	Purpose:	
*	- Push Extracted data To CDRLiveGK 	
*
*/

CREATE PROCEDURE dbo.usp_PushExtractedTerminologyData
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

	
	if @isDebug =1  PRINT  '           STARTED - Push data to Terminology and related tables from PREVIEW to LIVE '

	IF @CleanOldData = 'Yes' 
	BEGIN
		EXEC @r = CDRLiveGK.dbo.usp_ClearExtractedTerminologyData @DocumentID
		IF (@@ERROR <> 0) or @r <> 0
		BEGIN
			RAISERROR ( 70001, 16, 1, @DocumentID, 'Terminology')
			RETURN 70001
		END 
	END

	--**************************************************************************************************************
	if @isDebug =1  PRINT  '           Push dbo.Terminology table '
	INSERT INTO CDRLiveGK..Terminology(
		TermID,
		PreferredName,
		TermStatus,
		Comment,
		UpdateDate,
		UpdateUserID
		)
	SELECT 	TermID,
		PreferredName,
		TermStatus,
		Comment,
		@UpdateDate,
		@UpdateUserID
	FROM 	CDRPreviewGK..Terminology
	WHERE 	TermID = @DocumentID 	

	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 70000, 16, 1, @DocumentID, 'Terminology')
		RETURN 70000
	END 	
	--**************************************************************************************************************
	if @isDebug =1  PRINT  '           Push dbo.TermDefinition table '
	INSERT INTO CDRLiveGK..TermDefinition
		(
		TermDefinitionID,
		TermID,
		Definition,
		DefinitionType,
		DefinitionHTML,
		Comment,
		UpdateDate,
		UpdateUserID
		)
	SELECT 	TermDefinitionID,
		TermID,
		Definition,
		DefinitionType,
		DefinitionHTML,
		Comment,
		@UpdateDate,
		@UpdateUserID
	FROM 	CDRPreviewGK..TermDefinition 
	WHERE 	TermID = @DocumentID 	

	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 70000, 16, 1, @DocumentID, 'TermDefinition')
		RETURN 70000
	END 	
	--**************************************************************************************************************
	if @isDebug =1  PRINT  '           Push dbo.TermOtherName table '
	INSERT INTO CDRLiveGK..TermOtherName
		(
		OtherNameID,
		TermID,
		OtherName,
		OtherNameType,
		ReviewStatus,
		Comment,
		UpdateDate,
		UpdateUserID
		)
	SELECT 	OtherNameID,
		TermID,
		OtherName,
		OtherNameType,
		ReviewStatus,
		Comment,
		@UpdateDate,
		@UpdateUserID
	FROM 	CDRPreviewGK..TermOtherName 
	WHERE 	TermID = @DocumentID 	

	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 70000, 16, 1, @DocumentID, 'TermOtherName')
		RETURN 70000
	END 	
	
	--**************************************************************************************************************
	if @isDebug =1  PRINT  '           Push dbo.TermSemanticType table '
	INSERT INTO CDRLiveGK..TermSemanticType
		(
		TermSemanticTypeID,
		TermID,
		SemanticTypeID,
		SemanticTypeName,
		UpdateDate,
		UpdateUserID
		)
	SELECT 	TermSemanticTypeID,
		TermID,
		SemanticTypeID,
		SemanticTypeName,
		@UpdateDate,
		@UpdateUserID
	FROM 	CDRPreviewGK..TermSemanticType
	WHERE 	TermID = @DocumentID 	

	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 70000, 16, 1, @DocumentID, 'TermSemanticType')
		RETURN 70000
	END 	


	--**************************************************************************************************************
	if @isDebug =1  PRINT  '           Push dbo.CDRMenus table '
	INSERT INTO CDRLiveGK..CDRMenus
		(
		MenuID,
	 	CDRID,
	 	MenuTypeID,	
	 	ParentID,
	 	DisplayName,
	 	SortName,
		UpdateDate,
		UpdateUserID
		)
	SELECT 	MenuID,
	 	CDRID,
	 	MenuTypeID,	
	 	ParentID,
	 	DisplayName,
	 	SortName,
		@UpdateDate,
		@UpdateUserID
	FROM 	CDRPreviewGK..CDRMenus
	WHERE 	CDRID= @DocumentID 	

	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 70000, 16, 1, @DocumentID, 'CDRMenus')
		RETURN 70000
	END 	

	if @isDebug =1  PRINT  'DONE - Push data to Terminology and related tables from PREVIEW to LIVE '

	RETURN 0
END


GO
GRANT EXECUTE ON [dbo].[usp_PushExtractedTerminologyData] TO [Gatekeeper_role]
GO
