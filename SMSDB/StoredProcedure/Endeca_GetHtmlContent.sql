IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Endeca_GetHtmlContent]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Endeca_GetHtmlContent]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date: 05/02/2006
-- Description:	Get all nodes and module instances for endeca indexing
-- =============================================
CREATE PROCEDURE [dbo].[Endeca_GetHtmlContent]
	@HtmlContentID uniqueidentifier,
	@isLIve bit = 0
AS
BEGIN
if @islive =1 
	SELECT 
		HtmlContentID,
		ImageHtml
	FROM ProdHtmlContent
	WHERE HtmlContentID = @HtmlContentID
else
	SELECT 
		HtmlContentID,
		ImageHtml
	FROM HtmlContent
	WHERE HtmlContentID = @HtmlContentID

END

GO
GRANT EXECUTE ON [dbo].[Endeca_GetHtmlContent] TO [Endeca]
GO
