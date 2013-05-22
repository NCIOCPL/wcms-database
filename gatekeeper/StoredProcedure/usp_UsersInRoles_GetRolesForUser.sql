IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_UsersInRoles_GetRolesForUser]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[usp_UsersInRoles_GetRolesForUser]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].usp_UsersInRoles_GetRolesForUser
     @UserName         nvarchar(256)
AS
BEGIN

    DECLARE @UserId uniqueidentifier
    SELECT  @UserId = NULL

    SELECT  @UserId = UserId
    FROM    dbo.Users
    WHERE   LOWER(UserName) = LOWER(@UserName) 

    IF (@UserId IS NULL)
        RETURN(1)

    SELECT RoleName
    FROM   dbo.Roles r, dbo.UsersInRoles ur
    WHERE  r.RoleId = ur.RoleId AND ur.UserId = @UserId
    
    RETURN (0)
END


GO
GRANT EXECUTE ON [dbo].[usp_UsersInRoles_GetRolesForUser] TO [gatekeeper_role]
GO
