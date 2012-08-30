IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_CMSGroup_GetAll]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_CMSGroup_GetAll]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************
* Purpose:	This will add a new CMSGroup to the system
* Author:	Jhe
* Date:		8/21/2007
* Params:   None
*	
********************************************************/


CREATE PROCEDURE dbo.Core_CMSGroup_GetAll
	@IsActive bit  = null
AS
BEGIN

	SELECT G.GroupID, [GroupName], IsActive, DisableDate,
		(select count(M.UserID) from dbo.GroupUserMap M where G.GroupID= M.GroupID)
		 as Total
	FROM [dbo].[Group] G
	where (@IsActive is null or IsActive =@IsActive)
	order by [GroupName]
END


GO
GRANT EXECUTE ON [dbo].[Core_CMSGroup_GetAll] TO [websiteuser_role]
GO
