IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_CMSGroup_Get]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_CMSGroup_Get]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************
* Purpose:	This will get CMSGroup in the system
* Author:	Jhe
* Date:		8/21/2007
* Params:   None
*	
********************************************************/


CREATE PROCEDURE dbo.Core_CMSGroup_Get
    @GroupID	uniqueidentifier
AS
BEGIN

	SELECT GroupID, [GroupName], IsActive, DisableDate,
			CreateDate, CreateUserID, UpdateDate, UpdateUserID
	FROM [dbo].[Group] 
	Where GroupID = @GroupID

END


GO
GRANT EXECUTE ON [dbo].[Core_CMSGroup_Get] TO [websiteuser_role]
GO
