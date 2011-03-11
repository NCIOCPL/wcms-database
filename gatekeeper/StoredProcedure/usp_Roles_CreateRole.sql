IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_Roles_CreateRole]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[usp_Roles_CreateRole]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].[usp_Roles_CreateRole]
    @RoleName         nvarchar(256)
AS
BEGIN
   DECLARE @ErrorCode     int
    SET @ErrorCode = 0

    IF (EXISTS(SELECT RoleId FROM dbo.Roles WHERE LOWER(RoleName) = LOWER(@RoleName) ))
    BEGIN
        SET @ErrorCode = 1
        GOTO Cleanup
    END

    INSERT INTO dbo.Roles
                ( RoleName)
         VALUES ( @RoleName)

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
GRANT EXECUTE ON [dbo].[usp_Roles_CreateRole] TO [gatekeeper_role]
GO
