IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetDocumentInfo]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetDocumentInfo]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/**********************************************************************************

	Object's name:	usp_GetDocumentInfo
	Object's type:	Stored procedure
	Purpose:	
	
	Change History:
	

**********************************************************************************/


CREATE PROCEDURE dbo.usp_GetDocumentInfo
	@DocumentID	int,
	@DocumentGUID uniqueidentifier
	
AS
	if @documentID is not null
		SELECT  DocumentGUID
		FROM 	dbo.Document 
		WHERE 	DocumentID=@DocumentID
	else
		SELECT  DocumentID
		FROM 	dbo.Document 
		WHERE 	DocumentGUID=@DocumentGUID


GO
GRANT EXECUTE ON [dbo].[usp_GetDocumentInfo] TO [gatekeeper_role]
GO
