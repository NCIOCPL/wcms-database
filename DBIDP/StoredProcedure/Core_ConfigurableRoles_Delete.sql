IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_ConfigurableRoles_Delete]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_ConfigurableRoles_Delete]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE dbo.Core_ConfigurableRoles_Delete
	@RoleID		bigint,
	@updateUserID varchar(50)
AS
BEGIN
	

	IF (EXISTS (SELECT 1 FROM  dbo.MemberNodeRoleMap WHERE  RoleID = @RoleID))
		RETURN 60431

	Declare @OldPermission	int

	Select @OldPermission = [Permission] from  [dbo].[Role] Where RoleID= @RoleID

	BEGIN TRY	
	
			Delete From [dbo].[Role]
			Where RoleID= @RoleID

		RETURN 0
	END TRY

	BEGIN CATCH
		RETURN 60404 -- Can't delete Role
	
	END CATCH 
	
END

GO
GRANT EXECUTE ON [dbo].[Core_ConfigurableRoles_Delete] TO [websiteuser_role]
GO
