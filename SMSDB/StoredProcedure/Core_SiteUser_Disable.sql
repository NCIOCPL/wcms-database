IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_SiteUser_Disable]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_SiteUser_Disable]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************
* Purpose: Disable a site user
*
*
*
*/
CREATE  PROCEDURE [dbo].Core_SiteUser_Disable
	@UserID uniqueidentifier,
	@UpdateUserID varchar(50)
AS
BEGIN
	UPDATE [User]
	SET IsActive = 0,
		UpdateUserID = @UpdateUserID,
		UpdateDate = GetDate()
	WHERE UserID = @UserID
END

GO
GRANT EXECUTE ON [dbo].[Core_SiteUser_Disable] TO [websiteuser_role]
GO
