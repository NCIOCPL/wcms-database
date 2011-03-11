IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'usp_GetDocumentStatus') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetDocumentStatus]
GO
/****** Object:   dbo.usp_GetDocumentStatus    Script Date: 05/17/2007  ******/
/*	NCI - National Cancer Institute
*	
*	File Name:	
*	usp_GetDocumentStatus.sql
*
*	Objects Used:
*	 05/17/2007  Yiling Chen
*	
*	Change History:
*	 05/17/2007			Script Created
*	To Do:
*
*/
CREATE PROCEDURE dbo.usp_GetDocumentStatus
(
    @DocumentID	int = null
)
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	select DocumentGuid, IsActive, DocumentTypeID
	from Document 
	where DocumentID = @DocumentID
END

GO
Grant execute on dbo.usp_GetDocumentStatus to Gatekeeper_role
GO
