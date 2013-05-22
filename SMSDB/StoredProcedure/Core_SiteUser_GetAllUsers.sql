IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_SiteUser_GetAllUsers]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_SiteUser_GetAllUsers]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************
* Purpose: Get all IDs of the active and disabled users for this site.
*
*
*
*/
CREATE  PROCEDURE [dbo].Core_SiteUser_GetAllUsers
	@IsActive bit = NULL
AS
BEGIN
	SELECT UserID 
	FROM [user]
	WHERE (@IsActive is null OR IsActive = @IsActive)
END

GO
GRANT EXECUTE ON [dbo].[Core_SiteUser_GetAllUsers] TO [websiteuser_role]
GO
