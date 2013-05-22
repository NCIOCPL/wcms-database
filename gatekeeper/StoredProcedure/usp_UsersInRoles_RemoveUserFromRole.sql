IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_UsersInRoles_RemoveUserFromRole]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[usp_UsersInRoles_RemoveUserFromRole]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].usp_UsersInRoles_RemoveUserFromRole
	@UserName		   nvarchar(256),
	@RoleName		   nvarchar(256)
AS
BEGIN

    DECLARE @ErrorCode     int
    SET @ErrorCode = 0

	DECLARE @RoleId   uniqueidentifier,
		@UserId uniqueidentifier

    SELECT  @UserId = NULL, @RoleID =NULL
    
	SELECT  @UserId = UserId
    FROM    dbo.[Users]
    WHERE   Lower(UserName) = LOWER(@UserName)

    IF (@UserId IS NULL)
    BEGIN
        SELECT @ErrorCode = 1
        GOTO Cleanup
    END

	SELECT @RoleId = RoleID 
	FROM dbo.Roles
	WHERE  lower(RoleName) = lower(@RoleName)

    IF (@RoleId IS NULL)
    BEGIN
        SELECT @ErrorCode = 2
        GOTO Cleanup
    END

	SELECT @UserId = UserId, @RoleId = RoleID 
	FROM dbo.UsersInRoles
	WHERE  UserId = @UserId and RoleId= @RoleId

    IF (@RoleId IS NULL)
    BEGIN
        SELECT @ErrorCode = 3
        GOTO Cleanup
    END

	Delete From dbo.UsersInRoles where 
	UserId = @UserId and  RoleId = @RoleId
	IF( @@ERROR <> 0 )
    BEGIN
        return -1
    END

	RETURN(0)

Cleanup:
    RETURN @ErrorCode

END      

GO
GRANT EXECUTE ON [dbo].[usp_UsersInRoles_RemoveUserFromRole] TO [gatekeeper_role]
GO
