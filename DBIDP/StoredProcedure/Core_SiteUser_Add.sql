IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_SiteUser_Add]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_SiteUser_Add]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************
* Purpose: Enables a site user
*
*
* NOTE: Remove UserName at some point
*/
CREATE  PROCEDURE [dbo].Core_SiteUser_Add
	@UserID uniqueidentifier,
	@CreateUserID varchar(50)
AS
BEGIN

	BEGIN TRY

		INSERT INTO [Member]
		(MemberID, MemberType)
		VALUES
		(@UserID, 1)

		INSERT INTO [User]
		(UserID, IsActive, CreateUserID, CreateDate, UpdateUserID, UpdateDate)
		VALUES
		(@UserID, 1, @CreateUserID, GetDate(), @CreateUserID, GetDate())
		RETURN 0

	END TRY

	BEGIN CATCH
		Print 		ERROR_MESSAGE()
		RETURN 1
	END CATCH 

END

GO
GRANT EXECUTE ON [dbo].[Core_SiteUser_Add] TO [websiteuser_role]
GO
