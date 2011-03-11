IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[udf_GetViewPrettyUrl]') AND xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION [dbo].[udf_GetViewPrettyUrl]
GO
CREATE FUNCTION dbo.udf_GetViewPrettyUrl
	(
		@NCIViewId	uniqueidentifier
	)

RETURNS varchar(200)

AS


BEGIN 

	RETURN (SELECT Top 1 CurrentUrl FROM PrettyUrl WHERE NCIViewId = @NCIViewId AND IsPrimary = 1 AND IsRoot = 1)

END


GO
GRANT EXECUTE ON [dbo].[udf_GetViewPrettyUrl] TO [websiteuser_role]
GO
