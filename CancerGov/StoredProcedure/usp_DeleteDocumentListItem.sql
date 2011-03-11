IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_DeleteDocumentListItem]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_DeleteDocumentListItem]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO

/****** Object:  Stored Procedure dbo.usp_DeleteDocumentListItem    Script Date: 10/1/2001 2:46:59 PM ******/

CREATE PROCEDURE usp_DeleteDocumentListItem 
	
	@ListId		int,
	@DocumentId	uniqueidentifier
	
 AS

DECLARE @Priority	int

SELECT @Priority = Priority FROM DocumentListItem WHERE ListId = @ListId AND DocumentId = @DocumentId

DELETE
FROM DocumentListItem
WHERE ListId = @ListId AND DocumentId = @DocumentId

IF @@ROWCOUNT = 1
BEGIN
	UPDATE DocumentListItem
	SET Priority = Priority - 1
	WHERE ListId = @ListId AND Priority > @Priority
END


GO
