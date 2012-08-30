IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[HtmlContent_Get]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[HtmlContent_Get]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Jun Meng
-- Create date: 05/02/2006
-- Description:	Get HTML content for an instance
-- =============================================
CREATE PROCEDURE [dbo].[HtmlContent_Get] 
	@HtmlContentID	UniqueIdentifier,
	@isLive bit = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	if @isLive = 1
			SELECT *
			FROM PRODHtmlContent
			WHERE HtmlContentID = @HtmlContentID
	else
			SELECT *
			FROM HtmlContent
			WHERE HtmlContentID = @HtmlContentID

END

GO
GRANT EXECUTE ON [dbo].[HtmlContent_Get] TO [websiteuser_role]
GO
