IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_ConfigurableRoles_Get]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_ConfigurableRoles_Get]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE dbo.Core_ConfigurableRoles_Get
	@RoleID		bigint
AS
BEGIN
	
	BEGIN TRY	
	
			Select RoleID, RoleName, Permission, UpdateUserID, updateDate
			From [dbo].[Role]
			Where RoleID= @RoleID

		RETURN 0
	END TRY

	BEGIN CATCH
		RETURN 60400 -- Can't delete Role
	
	END CATCH 
	
END

GO
GRANT EXECUTE ON [dbo].[Core_ConfigurableRoles_Get] TO [websiteuser_role]
GO
