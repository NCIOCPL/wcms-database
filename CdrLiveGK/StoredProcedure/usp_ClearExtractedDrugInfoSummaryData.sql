IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_ClearExtractedDrugInfoSummaryData]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_ClearExtractedDrugInfoSummaryData]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*	NCI - National Cancer Institute
*	
*	Purpose:	
*	- Clear previously extracted DrugInfoSummary data (if any).
*
*	Objects Used:
*
*	Change History:
*
*	To Do List:
*
*/
CREATE PROCEDURE dbo.usp_ClearExtractedDrugInfoSummaryData
	(
	@DocumentID int,
	@ClearProperties varchar(3) = 'Yes'
	)
 AS
BEGIN
	SET NOCOUNT ON 
	
	DECLARE @ReturnCode int 
	SELECT @ReturnCode  = 0

	DELETE FROM dbo.DrugInfoSummary WHERE DrugInfoSummaryID = @DocumentID
	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 69998, 16, 1, @DocumentID,'DrugInfoSummary')
		RETURN 69998
	END 
	PRINT  '  *** FINISH - Cleaning process for DrugInfoSummary ' + convert(varchar, @DocumentID )

	RETURN 0 

	SET NOCOUNT OFF 
END

GO
GRANT EXECUTE ON [dbo].[usp_ClearExtractedDrugInfoSummaryData] TO [Gatekeeper_role]
GO
