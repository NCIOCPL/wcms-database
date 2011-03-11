IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_ClearExtractedOrganizationData]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_ClearExtractedOrganizationData]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****** Object:  Stored Procedure dbo.usp_ClearExtractedOrganizationData    Script Date: 9/10/2002 10:27:49 AM ******/
/*	NCI - National Cancer Institute
*	
*	Purpose:	
*	- Clear previously extracted organization data (if any).
*
*	Objects Used:
*
*	Change History:
*	Min
*	To Do List:
*
*/
CREATE PROCEDURE dbo.usp_ClearExtractedOrganizationData
	(
	@DocumentID int,
	@isDebug bit = 0
	)
 AS
BEGIN
	SET NOCOUNT ON 
	
	DELETE FROM dbo.OrganizationName WHERE OrganizationID = @DocumentID
	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 69998, 16, 1, @DocumentID, 'OrganizationName')
		RETURN 69998
	END 
	if @isdebug =  1  PRINT  '  ***       - OrganizationName deleted.'

	
	RETURN 0 

END

GO
GRANT EXECUTE ON [dbo].[usp_ClearExtractedOrganizationData] TO [Gatekeeper_role]
GO
