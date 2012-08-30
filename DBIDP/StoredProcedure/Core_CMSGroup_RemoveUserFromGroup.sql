IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_CMSGroup_RemoveUserFromGroup]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_CMSGroup_RemoveUserFromGroup]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************
* Purpose:	This will get CMSGroup in the system
* Author:	Jhe
* Date:		8/21/2007
* Params:   @UserIDs is a string containing a list of UserIDs which is separated by comma
*	
********************************************************/


CREATE  PROCEDURE [dbo].Core_CMSGroup_RemoveUserFromGroup
	@GroupID	uniqueIdentifier,
	@UserID	uniqueIdentifier,
	@UpdateUserID  varchar(50)
AS
BEGIN
	BEGIN TRY

		if (not exists (select 1 from [dbo].[Group] Where  GroupID = @GroupID))
				return 90120 --Group doesn't exists 

		if (not exists (select 1 from [dbo].[User] Where  UserID = @UserID))
				return 90121 --user  doesn't exists 
	
		Delete from  GroupUserMap
		Where GroupID = @GroupID
				and UserID = @UserID
	

		RETURN 0
	END TRY

	BEGIN CATCH

		RETURN 90101
	END CATCH 
END


GO
GRANT EXECUTE ON [dbo].[Core_CMSGroup_RemoveUserFromGroup] TO [websiteuser_role]
GO
