IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_SiteFunctionRole_GetRolesForUser]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_SiteFunctionRole_GetRolesForUser]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE dbo.Core_SiteFunctionRole_GetRolesForUser
	@UserID uniqueidentifier
AS
BEGIN

	SELECT R.FunctionRoleID,
		R.FunctionName
	FROM dbo.SiteFunctionRole R
	INNER JOIN dbo.UserSiteFunctionRoleMap S
	ON R.FunctionRoleID = S.FunctionRoleID
	AND S.UserID = @UserID


END

GO
GRANT EXECUTE ON [dbo].[Core_SiteFunctionRole_GetRolesForUser] TO [websiteuser_role]
GO
