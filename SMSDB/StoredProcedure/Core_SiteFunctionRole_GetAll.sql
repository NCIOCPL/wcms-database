IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_SiteFunctionRole_GetAll]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_SiteFunctionRole_GetAll]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/*---------------------------------------------
Purpose: Gets all of the SiteFunctionRoles from the database
Author: Jhe
Date: ???
------------------------------------------------*/
CREATE PROCEDURE dbo.Core_SiteFunctionRole_GetAll
AS
BEGIN

	SELECT S.FunctionRoleID, S.FunctionName, (select count(M.UserID) from dbo.UserSiteFunctionRoleMap M
	where S.FunctionRoleID = M.FunctionRoleID) as Total
	FROM dbo.SiteFunctionRole S
	ORDER BY S.FunctionName

END


GO
GRANT EXECUTE ON [dbo].[Core_SiteFunctionRole_GetAll] TO [websiteuser_role]
GO
