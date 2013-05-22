IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_UsersInRoles_IsUserInRole]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[usp_UsersInRoles_IsUserInRole]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].usp_UsersInRoles_IsUserInRole
    @UserName         nvarchar(256),
    @RoleName         nvarchar(256)
AS
BEGIN
    DECLARE @UserId uniqueidentifier
    SELECT  @UserId = NULL
    DECLARE @RoleId uniqueidentifier
    SELECT  @RoleId = NULL

    SELECT  @UserId = UserId
    FROM    dbo.Users
    WHERE   LOWER(UserName)  = LOWER(@UserName) 

    IF (@UserId IS NULL)
        RETURN(2)

    SELECT  @RoleId = RoleId
    FROM    dbo.Roles
    WHERE   LOWER(RoleName)  = LOWER(@RoleName) 

    IF (@RoleId IS NULL)
        RETURN(3)

    IF (EXISTS( SELECT * FROM dbo.UsersInRoles WHERE  UserId = @UserId AND RoleId = @RoleId))
        RETURN(1)
    ELSE
        RETURN(0)
END


GO
GRANT EXECUTE ON [dbo].[usp_UsersInRoles_IsUserInRole] TO [gatekeeper_role]
GO
