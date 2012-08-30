IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_SiteFunctionRole_AddUserToRole]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_SiteFunctionRole_AddUserToRole]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE dbo.Core_SiteFunctionRole_AddUserToRole
	@UserID		uniqueidentifier,
    @FunctionRoleID int,
	@CreateUserID varchar(50)
AS

BEGIN

	BEGIN TRY

		INSERT INTO dbo.UserSiteFunctionRoleMap
		([UserID], FunctionRoleID, CreateDate, CreateUserID)
		VALUES
		(@UserId, @FunctionRoleID, getdate(), @CreateUserID)		

		RETURN 0
	END TRY

	BEGIN CATCH

		RETURN 60420 -- Can't insert Role
		--ERROR_NUMBER()
		--ERROR_MESSAGE()
	END CATCH 
	
END

GO
GRANT EXECUTE ON [dbo].[Core_SiteFunctionRole_AddUserToRole] TO [websiteuser_role]
GO
