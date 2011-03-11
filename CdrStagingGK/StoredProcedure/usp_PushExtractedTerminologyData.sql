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
*	- Push Extracted data To CDRPreviewGK 	
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

	
	if @isDebug =1  PRINT  '           STARTED - Push data to Terminology and related tables from staging to Preview '

	IF @CleanOldData = 'Yes' 
	BEGIN
		EXEC @r = CDRPreviewGK.dbo.usp_ClearExtractedTerminologyData @DocumentID
		IF (@@ERROR <> 0) or @r <> 0
		BEGIN
			RAISERROR ( 70001, 16, 1, @DocumentID, 'Terminology')
			RETURN 70001
		END 
	END

	--**************************************************************************************************************
	if @isDebug =1  PRINT  '           Push dbo.Terminology table '
	INSERT INTO CDRPreviewGK..Terminology(
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
	FROM 	CDRStagingGK..Terminology
	WHERE 	TermID = @DocumentID 	

	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 70000, 16, 1, @DocumentID, 'Terminology')
		RETURN 70000
	END 	
	--**************************************************************************************************************
	if @isDebug =1  PRINT  '           Push dbo.TermDefinition table '
	INSERT INTO CDRPreviewGK..TermDefinition
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
	FROM 	CDRStagingGK..TermDefinition 
	WHERE 	TermID = @DocumentID 	

	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 70000, 16, 1, @DocumentID, 'TermDefinition')
		RETURN 70000
	END 	
	--**************************************************************************************************************
	if @isDebug =1  PRINT  '           Push dbo.TermOtherName table '
	INSERT INTO CDRPreviewGK..TermOtherName
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
	FROM 	CDRStagingGK..TermOtherName 
	WHERE 	TermID = @DocumentID 	

	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 70000, 16, 1, @DocumentID, 'TermOtherName')
		RETURN 70000
	END 	
	
	--**************************************************************************************************************
	if @isDebug =1  PRINT  '           Push dbo.TermSemanticType table '
	INSERT INTO CDRPreviewGK..TermSemanticType
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
	FROM 	CDRStagingGK..TermSemanticType
	WHERE 	TermID = @DocumentID 	

	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 70000, 16, 1, @DocumentID, 'TermSemanticType')
		RETURN 70000
	END 	


	--**************************************************************************************************************
	if @isDebug =1  PRINT  '           Push dbo.CDRMenus table '
	INSERT INTO CDRPreviewGK..CDRMenus
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
	FROM 	CDRStagingGK..CDRMenus
	WHERE 	CDRID= @DocumentID 	

	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 70000, 16, 1, @DocumentID, 'CDRMenus')
		RETURN 70000
	END 	

	if @isDebug =1  PRINT  'DONE - Push data to Terminology and related tables from staging to Preview '

	RETURN 0
END


GO
GRANT EXECUTE ON [dbo].[usp_PushExtractedTerminologyData] TO [Gatekeeper_role]
GO
