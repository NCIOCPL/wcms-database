IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetCachedSearchResultView]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetCachedSearchResultView]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE dbo.usp_GetCachedSearchResultView
(
	@ResultViewCacheID	int
)
AS

BEGIN
	SELECT ResultViewHTML, cachedDate
	FROM ProtocolSearchResultViewCache
	WHERE ResultViewCacheID = @ResultViewCacheID
END

GO
GRANT EXECUTE ON [dbo].[usp_GetCachedSearchResultView] TO [websiteuser_role]
GO
