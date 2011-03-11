IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_Roles_GetAllRoles]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[usp_Roles_GetAllRoles]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].[usp_Roles_GetAllRoles] 
AS
BEGIN

    SELECT RoleName
    FROM   dbo.Roles 
    ORDER BY RoleName
END

GO
GRANT EXECUTE ON [dbo].[usp_Roles_GetAllRoles] TO [gatekeeper_role]
GO
