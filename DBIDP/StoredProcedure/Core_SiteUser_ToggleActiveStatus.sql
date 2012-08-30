IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_SiteUser_ToggleActiveStatus]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_SiteUser_ToggleActiveStatus]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************
* Purpose: Updates the IsActive status of a user
* Params: 
*	@UserID -- The ID of the user
********************************************************/
CREATE  PROCEDURE [dbo].Core_SiteUser_ToggleActiveStatus
	@UserID uniqueidentifier,
	@UpdateUserID varchar(50)
AS
BEGIN
	UPDATE [User]
	SET IsActive = CASE IsActive 
					WHEN 1 THEN 0
					WHEN 0 THEN 1
					END,
		UpdateUserID = @UpdateUserID,
		UpdateDate = GetDate()
	WHERE UserID = @UserID
END


GO
GRANT EXECUTE ON [dbo].[Core_SiteUser_ToggleActiveStatus] TO [websiteuser_role]
GO
