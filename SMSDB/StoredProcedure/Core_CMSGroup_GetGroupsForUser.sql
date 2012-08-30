IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_CMSGroup_GetGroupsForUser]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_CMSGroup_GetGroupsForUser]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************
* Purpose:	This will get all users in a CMSGroup in the system
* Author:	Jhe
* Date:		8/21/2007
* Params:   @userID  ID to be checked
*	
********************************************************/



CREATE PROCEDURE [dbo].Core_CMSGroup_GetGroupsForUser
	@userID uniqueIdentifier
AS
BEGIN

	BEGIN TRY
		
	
		select G.GroupID, GroupName, IsActive
		from   [dbo].[GroupUserMap] M, dbo.[Group] G
		WHERE  M.[GroupID] = G.GroupID and M.UserID = @userID
		
	END TRY

	BEGIN CATCH		
		RETURN 90104
	END CATCH 
END


GO
GRANT EXECUTE ON [dbo].[Core_CMSGroup_GetGroupsForUser] TO [websiteuser_role]
GO
