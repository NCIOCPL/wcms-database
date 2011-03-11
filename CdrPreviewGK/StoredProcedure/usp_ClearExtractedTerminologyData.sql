IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_ClearExtractedTerminologyData]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_ClearExtractedTerminologyData]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/****** Object:  Stored Procedure dbo.usp_ClearExtractedTerminologyData    Script Date: 9/10/2002 10:27:49 AM ******/
/*	NCI - National Cancer Institute
*	
*	Purpose:	
*	- Clear previously extracted person data (if any).
*
*	Objects Used:
*
*/

CREATE PROCEDURE dbo.usp_ClearExtractedTerminologyData
	(
	@DocumentID 	int,
	@isDebug bit = 0
	)
 AS
BEGIN

	SET NOCOUNT ON 

	DECLARE	@rownum	int,
	@err int

	
	if @isDebug =1  PRINT  '  *** START - Cleaning process for Terminology ' + convert(varchar, @DocumentID )
	-- ********************************************************************************************************************************
	DECLARE @ReturnCode  int 
	SELECT @ReturnCode  = 0

	-- ********************************************************************************************************************************
	DELETE FROM DBO.TermDefinition WHERE TermID = @DocumentID
	SELECT @err=@@ERROR, @rownum=@@RowCount	
	IF (@err<> 0)
	BEGIN
		
		RAISERROR ( 69998, 16, 1, @DocumentID, 'TermDefinition')
		RETURN 69998
	END 
	if @isDebug =1  PRINT  '  ***       - TermDefinition: ' + convert(varchar, @rownum ) + ' records deleted.'

	-- ********************************************************************************************************************************
	DELETE FROM DBO.TermOtherName WHERE TermID = @DocumentID
	SELECT @err=@@ERROR, @rownum=@@RowCount	
	IF (@err<> 0)
	BEGIN
		
		RAISERROR ( 69998, 16, 1, @DocumentID, 'TermOtherName')
		RETURN 69998
	END 
	if @isDebug =1  PRINT  '  ***       - TermOtherName: ' + convert(varchar, @rownum ) + ' records deleted.'


	-- ********************************************************************************************************************************
	DELETE FROM DBO.TermSemanticType WHERE TermID = @DocumentID
	SELECT @err=@@ERROR, @rownum=@@RowCount	
	IF (@err<> 0)
	BEGIN
		
		RAISERROR ( 69998, 16, 1, @DocumentID, 'TermSemanticType')
		RETURN 69998
	END 
	if @isDebug =1  PRINT  '  ***       - TermSemanticType: ' + convert(varchar, @rownum ) + ' records deleted.'

	-- ********************************************************************************************************************************
	DELETE FROM DBO.Terminology WHERE TermID = @DocumentID
	SELECT @err=@@ERROR, @rownum=@@RowCount	
	IF (@err<> 0)
	BEGIN
		
		RAISERROR ( 69998, 16, 1, @DocumentID, 'Terminology')
		RETURN 69998
	END 
	if @isDebug =1  PRINT  '  ***       - Terminology: ' + convert(varchar, @rownum ) + ' records deleted.'


	-- ********************************************************************************************************************************
	DELETE FROM CDRMenus WHERE CDRID = @DocumentID
	SELECT @err=@@ERROR, @rownum=@@RowCount	
	IF (@err<> 0)
	BEGIN
		
		RAISERROR ( 69998, 16, 1, @DocumentID, 'CDRMenus')
		RETURN 69998
	END 
	if @isDebug =1  PRINT  '  ***       - CDRMenus: ' + convert(varchar, @rownum ) + ' records deleted.'


	RETURN 0 

	
END

GO
GRANT EXECUTE ON [dbo].[usp_ClearExtractedTerminologyData] TO [Gatekeeper_role]
GO
