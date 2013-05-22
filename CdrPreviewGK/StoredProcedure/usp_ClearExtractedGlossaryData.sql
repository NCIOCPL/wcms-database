IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_ClearExtractedGlossaryData]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_ClearExtractedGlossaryData]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*	NCI - National Cancer Institute
*	
*	Purpose:	
*	- Clear previously extracted Glossary data (if any).
*
*	Objects Used:
*
*	Change History:

*	To Do List:
*	- use transactions
*
*/
CREATE PROCEDURE dbo.usp_ClearExtractedGlossaryData
	(
	@DocumentID int,
	@isDebug bit = 0
	)
 AS
BEGIN
	SET NOCOUNT ON 
	
	if @isDebug =1  PRINT  '  *** START - Cleaning process for Glossary ' + convert(varchar, @DocumentID )

	-- ***************************************************************************************
	DELETE 
	FROM dbo.GlossaryTermDefinitionDictionary 
	WHERE GlossaryTermDefinitionID IN ( 
			SELECT GlossaryTermDefinitionID FROM dbo.GlossaryTermDefinition WHERE GlossaryTermID = @DocumentID
			)
	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 69998, 16, 1, @DocumentID, 'GlossaryTermDefinitionDictionary')
		RETURN 69998
	END 
	if @isDebug =1  PRINT  '  ***       - GlossaryTermDefinitionDictionary table cleared.'

	-- ***************************************************************************************
	DELETE 
	FROM dbo.GlossaryTermDefinitionAudience
	WHERE GlossaryTermDefinitionID IN ( 
			SELECT GlossaryTermDefinitionID FROM dbo.GlossaryTermDefinition WHERE GlossaryTermID = @DocumentID
			)
	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 69998, 16, 1, @DocumentID, 'GlossaryTermDefinitionAudience')
		RETURN 69998
	END 
	if @isDebug =1  PRINT  '  ***       - dbo.GlossaryTermDefinitionAudience table cleared.'

	-- ***************************************************************************************
	DELETE FROM dbo.GlossaryTermDefinition WHERE GlossaryTermID = @DocumentID
	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 69998, 16, 1, @DocumentID, 'GlossaryTermDefinition')
		RETURN 69998
	END 
	if @isDebug =1  PRINT  '  ***       - dbo.GlossaryTermDefinition table cleared.'
	
	DELETE FROM dbo.GlossaryTerm WHERE GlossaryTermID = @DocumentID
	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 69998, 16, 1, @DocumentID,'GlossaryTerm')
		RETURN 69998
	END 
	if @isDebug =1  PRINT  '  ***       - dbo.GlossaryTerm table cleared.'
		
END



GO
GRANT EXECUTE ON [dbo].[usp_ClearExtractedGlossaryData] TO [Gatekeeper_role]
GO
