IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetCDRDocumentXML]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetCDRDocumentXML]
GO


/****** Object:  Stored Procedure dbo.usp_GetCDRDocumentXML    Script Date: 11/26/2002 12:15:24 PM ******/
/*************************************************************************************************************
*	NCI - National Cancer Institute
*	
*	Purpose:	
*	Function will return XML for the specified Document
*
*	Objects Used:
*
*	Change History:
*
*	To Do List:
*
*************************************************************************************************************/

CREATE PROCEDURE dbo.usp_GetCDRDocumentXML
(
	@DocumentId	int
)
AS
BEGIN
	SELECT 	[XML]
	FROM 		dbo.DocumentXML
	WHERE 	DocumentId = @DocumentId
	
END

GO
GRANT EXECUTE ON [dbo].[usp_GetCDRDocumentXML] TO [websiteuser_role]
GO
