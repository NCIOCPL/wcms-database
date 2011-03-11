IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_AddDocumentListItem]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_AddDocumentListItem]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO

/****** Object:  Stored Procedure dbo.usp_AddDocumentListItem    Script Date: 10/1/2001 2:46:59 PM ******/

CREATE PROCEDURE usp_AddDocumentListItem 

	@ListId		uniqueidentifier,
	@DocumentId	uniqueidentifier

AS

DECLARE @Priority	int
DECLARE @Dups	int
DECLARE @Result	varchar(150)
DECLARE @ListName	varchar(50)
DECLARE @ShortTitle	varchar(50)

SELECT @Priority = MAX(Priority) + 1 FROM DocumentListItem WHERE ListId = @ListId

SELECT @ListName = ListName FROM List WHERE ListId = @ListId
SELECT @ShortTitle = ShortTitle FROM Document WHERE DocumentId = @DocumentId

SELECT @Dups = COUNT(*) FROM DocumentListItem WHERE ListId = @ListId AND DocumentId = @DocumentId

IF @Dups = 0
BEGIN
	INSERT INTO DocumentListItem(ListId, DocumentId, Featured, Approved, Priority)
	VALUES (@ListId, @DocumentId, 0, 0, @Priority)
	
	IF @@ROWCOUNT = 1
	BEGIN
		SELECT @Result = '"' + @ShortTitle + '" was successfully added to list "' + @ListName + '."'
	END
	ELSE
	BEGIN
		SELECT @Result = '"' + @ShortTitle + '" could not be added to the list "' + @ListName + '."'
	END
END
ELSE
BEGIN
	SELECT @Result = '"' + @ShortTitle + '" already exists in list "' + @ListName + '."'
END

SELECT @Result As Result


GO
