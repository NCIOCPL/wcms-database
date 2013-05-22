IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_ClearExtractedPoliticalSubUnitData]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_ClearExtractedPoliticalSubUnitData]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*	NCI - National Cancer Institute
*	
*	Purpose:	
*	- Clear previously extracted PoliticalSubUnit data (if any).
*
*	Objects Used:
*
*	Change History:
*	To Do List:
*
*/
CREATE PROCEDURE dbo.usp_ClearExtractedPoliticalSubUnitData
	(
	@DocumentID int,
	@isDebug bit = 0
	)
 AS
BEGIN
	SET NOCOUNT ON 
	
	DELETE FROM dbo.PoliticalSubUnit  with (TABLOCKX)
	WHERE PoliticalSubUnitID = @DocumentID
	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 69998, 16, 1, @DocumentID, 'PoliticalSubUnit')
		RETURN 69998
	END 
	if @isDebug =1  PRINT  '  ***       - PoliticalSubUnit:  deleted.'
	
	

END

GO
GRANT EXECUTE ON [dbo].[usp_ClearExtractedPoliticalSubUnitData] TO [Gatekeeper_role]
GO
