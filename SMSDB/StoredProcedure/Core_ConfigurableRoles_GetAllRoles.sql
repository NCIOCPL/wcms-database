IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_ConfigurableRoles_GetAllRoles]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_ConfigurableRoles_GetAllRoles]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************
* Purpose: Get all ConfigurableRoles for this site.
*
*
*
*/
CREATE  PROCEDURE [dbo].Core_ConfigurableRoles_GetAllRoles
AS
BEGIN
	SELECT [RoleID]
      ,[RoleName]
      ,[CreateDate]
      ,[CreateUserID]
      ,[UpdateDate]
      ,[UpdateUserID]
      ,[Permission]
	  ,(select count(*) from dbo.MemberNodeRoleMap where RoleID = R.RoleID) as Total
  FROM [dbo].[Role] R
END

GO
GRANT EXECUTE ON [dbo].[Core_ConfigurableRoles_GetAllRoles] TO [websiteuser_role]
GO
