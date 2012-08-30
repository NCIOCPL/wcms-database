IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_CMSGroup_Toggle]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_CMSGroup_Toggle]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************
* Purpose: Updates the IsActive status of a group
* Params: 
*	@UserID -- The ID of the user
********************************************************/
CREATE  PROCEDURE [dbo].Core_CMSGroup_Toggle
	@GroupID uniqueidentifier,
	@UpdateUserID varchar(50)
AS
BEGIN
	UPDATE dbo.[Group]
	SET IsActive = CASE IsActive 
					WHEN 1 THEN 0
					WHEN 0 THEN 1
					END,
		UpdateUserID = @UpdateUserID,
		UpdateDate = GetDate()
	WHERE GroupID = @GroupID
END


GO
GRANT EXECUTE ON [dbo].[Core_CMSGroup_Toggle] TO [websiteuser_role]
GO
