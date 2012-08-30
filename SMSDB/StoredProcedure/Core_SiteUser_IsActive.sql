IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_SiteUser_IsActive]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_SiteUser_IsActive]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************
* Purpose: Check to see if a user is marked as active
*
*
*
*/
CREATE  PROCEDURE [dbo].Core_SiteUser_IsActive
	@UserID uniqueidentifier,
	@IsActive bit OUTPUT
AS
BEGIN
	SELECT @IsActive = IsActive 
	FROM [user]
	WHERE UserID = @UserID
END

GO
GRANT EXECUTE ON [dbo].[Core_SiteUser_IsActive] TO [websiteuser_role]
GO
