IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_SiteFunctionRole_RemoveUserFromRole]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_SiteFunctionRole_RemoveUserFromRole]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE dbo.Core_SiteFunctionRole_RemoveUserFromRole
	@UserID		UniqueIdentifier,
    @FunctionRoleID       int,
	@UpdateUserID varchar(50)
AS

BEGIN
	
	BEGIN TRY

		Delete From dbo.UserSiteFunctionRoleMap
		Where [UserID] = @UserId and FunctionRoleID = @FunctionRoleID 			

		RETURN 0
	END TRY

	BEGIN CATCH

		RETURN 60420 -- Can't insert Role
		--ERROR_NUMBER()
		--ERROR_MESSAGE()
	END CATCH 
	
END

GO
GRANT EXECUTE ON [dbo].[Core_SiteFunctionRole_RemoveUserFromRole] TO [websiteuser_role]
GO
