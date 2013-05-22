IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetDocument]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetDocument]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--***********************************************************************
-- Create New Object 
--************************************************************************

CREATE PROCEDURE usp_GetDocument

	@DocumentId		uniqueidentifier

AS
BEGIN
	SELECT DocumentID,
		Title,
		ShortTitle,
		Description,
		GroupID,
		DataType,
		DataSize,
		IsWirelessPage,
		TOC,
		Data,
		CreateDate,
		PostedDate,
		ReleaseDate,
		ExpirationDate,
		DisplayDateMode,
		UpdateDate,
		UpdateUserID
	FROM 	Document
	WHERE DocumentId = @DocumentId
END

GO
GRANT EXECUTE ON [dbo].[usp_GetDocument] TO [websiteuser_role]
GO
