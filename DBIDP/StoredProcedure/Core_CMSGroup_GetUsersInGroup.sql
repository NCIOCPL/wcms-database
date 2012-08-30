IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_CMSGroup_GetUsersInGroup]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_CMSGroup_GetUsersInGroup]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************
* Purpose:	This will get all users in a CMSGroup in the system
* Author:	Jhe
* Date:		8/21/2007
* Params:   @GroupID Group ID to be checked
*	
********************************************************/



CREATE PROCEDURE [dbo].[Core_CMSGroup_GetUsersInGroup]
	@GroupID uniqueIdentifier
AS
BEGIN

	BEGIN TRY
		
	
		select [UserID]
		from   [dbo].[GroupUserMap]
		WHERE  [GroupID] =@GroupID
		
	END TRY

	BEGIN CATCH		
		RETURN 90104
	END CATCH 
END


GO
GRANT EXECUTE ON [dbo].[Core_CMSGroup_GetUsersInGroup] TO [websiteuser_role]
GO
