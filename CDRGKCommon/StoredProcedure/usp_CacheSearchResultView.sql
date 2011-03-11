IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_CacheSearchResultView]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_CacheSearchResultView]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
--===========================================================================================================
-- Create Stored Procedures
--===========================================================================================================

CREATE PROCEDURE dbo.usp_CacheSearchResultView
(
	@ResultViewHtml		ntext
)

AS

BEGIN

	INSERT ProtocolSearchResultViewCache(ResultViewHtml)
	VALUES(@ResultViewHtml)
	
	SELECT @@IDENTITY AS ResultViewCacheID

END
GO
GRANT EXECUTE ON [dbo].[usp_CacheSearchResultView] TO [websiteuser_role]
GO
