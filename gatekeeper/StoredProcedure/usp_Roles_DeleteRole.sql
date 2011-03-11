IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_Roles_DeleteRole]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[usp_Roles_DeleteRole]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].[usp_Roles_DeleteRole]
    @RoleName                   nvarchar(256),
    @DeleteOnlyIfRoleIsEmpty    bit
AS
BEGIN  
    DECLARE @ErrorCode     int
    SET @ErrorCode = 0

    DECLARE @RoleId   uniqueidentifier
    SELECT  @RoleId = NULL
    SELECT  @RoleId = RoleId FROM dbo.Roles WHERE LOWER(RoleName) = LOWER(@RoleName)

    IF (@RoleId IS NULL)
    BEGIN
        SELECT @ErrorCode = 1
        GOTO Cleanup
    END

    IF (@DeleteOnlyIfRoleIsEmpty <> 0)
    BEGIN
        IF (EXISTS (SELECT RoleId FROM dbo.UsersInRoles  WHERE @RoleId = RoleId))
        BEGIN
            SELECT @ErrorCode = 2
            GOTO Cleanup
        END
    END


    DELETE FROM dbo.UsersInRoles  WHERE @RoleId = RoleId
    IF( @@ERROR <> 0 )
    BEGIN
        SET @ErrorCode = -1
        GOTO Cleanup
    END

    DELETE FROM dbo.Roles WHERE @RoleId = RoleId  
    IF( @@ERROR <> 0 )
    BEGIN
        SET @ErrorCode = -1
        GOTO Cleanup
    END

    RETURN(0)

Cleanup:
    RETURN @ErrorCode
END

GO
GRANT EXECUTE ON [dbo].[usp_Roles_DeleteRole] TO [gatekeeper_role]
GO
