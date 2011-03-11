IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[udf_GetViewObjectPrettyUrl]') AND xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION [dbo].[udf_GetViewObjectPrettyUrl]
GO
CREATE FUNCTION dbo.udf_GetViewObjectPrettyUrl
	(
		@NCIViewId	uniqueidentifier,
		@ObjectId	uniqueidentifier
	)

RETURNS varchar(200)

AS


BEGIN 

	-- RETURN (SELECT Top 1 CurrentUrl FROM PrettyUrl WHERE NCIViewId = @NCIViewId AND ObjectId = @ObjectId AND IsPrimary = 1)
	RETURN (SELECT Top 1 ISNULL(ProposedURL, CurrentUrl) 
		FROM PrettyUrl 
		WHERE NCIViewId = @NCIViewId AND ObjectId = @ObjectId AND IsPrimary = 1)

END





GO
