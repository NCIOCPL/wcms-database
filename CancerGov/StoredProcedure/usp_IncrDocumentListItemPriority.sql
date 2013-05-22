IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_IncrDocumentListItemPriority]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_IncrDocumentListItemPriority]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO

/****** Object:  Stored Procedure dbo.usp_IncrDocumentListItemPriority    Script Date: 10/1/2001 2:46:59 PM ******/

CREATE PROCEDURE usp_IncrDocumentListItemPriority

	@ListId		int,
	@DocumentId	uniqueidentifier

 AS

DECLARE @Priority	int

SELECT @Priority = Priority FROM DocumentListItem WHERE ListId = @ListId AND DocumentId = @DocumentId

UPDATE DocumentListItem
SET Priority = Priority + 1
WHERE ListId = @ListId AND Priority = @Priority - 1

IF @@ROWCOUNT > 0
BEGIN
	UPDATE DocumentListItem
	SET Priority = Priority - 1
	WHERE ListId = @ListId AND DocumentId = @DocumentId
END


GO
