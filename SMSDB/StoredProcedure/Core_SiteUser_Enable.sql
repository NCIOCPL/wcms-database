IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_SiteUser_Enable]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_SiteUser_Enable]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************
* Purpose: Enables a site user
*
*
*
*/
CREATE  PROCEDURE [dbo].Core_SiteUser_Enable
	@UserID uniqueidentifier,
	@UpdateUserID varchar(50)
AS
BEGIN
	UPDATE [User]
	SET IsActive = 1,
		UpdateUserID = @UpdateUserID,
		UpdateDate = GetDate()
	WHERE UserID = @UserID
END

GO
GRANT EXECUTE ON [dbo].[Core_SiteUser_Enable] TO [websiteuser_role]
GO
