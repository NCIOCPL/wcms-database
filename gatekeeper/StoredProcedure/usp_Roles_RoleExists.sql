IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_Roles_RoleExists]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[usp_Roles_RoleExists]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].[usp_Roles_RoleExists]
    @RoleName         nvarchar(256)
AS
BEGIN
      IF (EXISTS (SELECT RoleName FROM dbo.Roles WHERE LOWER(RoleName) = LOWER(@RoleName) ))
        RETURN(1)
    ELSE
        RETURN(0)
END

GO
GRANT EXECUTE ON [dbo].[usp_Roles_RoleExists] TO [gatekeeper_role]
GO
