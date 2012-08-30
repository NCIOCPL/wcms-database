IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_CMSGroup_GetAVailableGroups]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_CMSGroup_GetAVailableGroups]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************
* Purpose:	This will get AVailable Groups in the system
* Author:	Jhe
* Date:		8/21/2007
* Params:   @userID  ID to be checked
*	
********************************************************/



CREATE PROCEDURE [dbo].Core_CMSGroup_GetAVailableGroups
	@userID uniqueIdentifier
AS
BEGIN

	BEGIN TRY
		SELECT GroupID, [GroupName], IsActive, DisableDate
		FROM [dbo].[Group]
		where IsActive = 1 and GroupID not in 
			(
			select GroupID 
			from   [dbo].[GroupUserMap] 
			WHERE  UserID = @userID 
			)
		Order by [GroupName]
		
	END TRY

	BEGIN CATCH		
		RETURN 90504
	END CATCH 
END


GO
GRANT EXECUTE ON [dbo].[Core_CMSGroup_GetAVailableGroups] TO [websiteuser_role]
GO
