IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_Profile_Get]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_Profile_Get]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************
* Purpose:	Gets a profile for a user
* Author:	BryanP
* Date:		8/7/2007
* Params: 
*	
********************************************************/
CREATE PROCEDURE [dbo].[Core_Profile_Get] 
	@UserID uniqueidentifier
AS
BEGIN
    SELECT  PropertyValues
    FROM         dbo.[Profile]
    WHERE        UserId = @UserId
END

GO
GRANT EXECUTE ON [dbo].[Core_Profile_Get] TO [websiteuser_role]
GO
