IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_SiteFunctionRole_GetUsersInRole]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_SiteFunctionRole_GetUsersInRole]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE dbo.Core_SiteFunctionRole_GetUsersInRole
	@FunctionRoleID int
AS
BEGIN
	SELECT 
		UserID
	FROM dbo.SiteFunctionRole R
	INNER JOIN dbo.UserSiteFunctionRoleMap S
	ON R.FunctionRoleID = S.FunctionRoleID
	where R.FunctionRoleID = @FunctionRoleID

END


GO
GRANT EXECUTE ON [dbo].[Core_SiteFunctionRole_GetUsersInRole] TO [websiteuser_role]
GO
