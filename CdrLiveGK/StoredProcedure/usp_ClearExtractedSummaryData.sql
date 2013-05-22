IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_ClearExtractedSummaryData]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_ClearExtractedSummaryData]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****** Object:  Stored Procedure dbo.usp_ClearExtractedSummaryData    Script Date: 5/11/2004 5:53:51 PM ******/
 
/****** Object:  Stored Procedure dbo.usp_ClearExtractedSummaryData    Script Date: 9/10/2002 10:27:49 AM ******/
/*	NCI - National Cancer Institute
*	
*	Purpose:	
*	- Clear previously extracted Summary data (if any).
*
*	Objects Used:
*
*	Change History:
*
*/
CREATE PROCEDURE dbo.usp_ClearExtractedSummaryData
	(
	@DocumentID int,
	@isDebug bit = 0
	)
 AS
BEGIN
	SET NOCOUNT ON 
	
	DECLARE @ReturnCode int 
	SELECT @ReturnCode  = 0

	
	DELETE FROM dbo.SummaryRelations WHERE SummaryID = @DocumentID
	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 69998, 16, 1, @DocumentID,'SummaryRelations')
		RETURN 69998
	END 
	if @isDebug =1  PRINT '  ***       - SummaryRelations deleted.'

	DELETE FROM dbo.SummarySection WHERE SummaryID = @DocumentID
	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 69998, 16, 1, @DocumentID,'SummarySEction')
		RETURN 69998
	END 
	if @isDebug =1  PRINT '  ***       - SummarySection deleted.'

	-- **********************************************************************************************************************************
	DELETE FROM dbo.Summary WHERE SummaryID = @DocumentID
	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 69998, 16, 1, @DocumentID,'Summary')
		RETURN 69998
	END 
	if @isDebug =1  PRINT  '  ***       - Summary deleted.'


	RETURN 0 
	
END

GO
GRANT EXECUTE ON [dbo].[usp_ClearExtractedSummaryData] TO [Gatekeeper_role]
GO
