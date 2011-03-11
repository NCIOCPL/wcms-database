IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[Bif_SelectDocInfo]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[Bif_SelectDocInfo]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE dbo.Bif_SelectDocInfo
	@DocumentID as uniqueidentifier
AS
	SET NOCOUNT ON;
SELECT DocumentID, DataSize, Data, Description FROM Document
where DocumentID = @DocumentID
GO
