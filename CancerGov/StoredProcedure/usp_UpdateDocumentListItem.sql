IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_UpdateDocumentListItem]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_UpdateDocumentListItem]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO

/****** Object:  Stored Procedure dbo.usp_UpdateDocumentListItem    Script Date: 10/1/2001 2:46:59 PM ******/

CREATE PROCEDURE usp_UpdateDocumentListItem

	@ListId		int,
	@DocumentId	uniqueidentifier,
	@Featured	bit,
	@Approved	bit

 AS

UPDATE DocumentListItem
SET Featured = @Featured, Approved = @Approved
WHERE ListId = @ListId AND DocumentId = @DocumentId


GO
