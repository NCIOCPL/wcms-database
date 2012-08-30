IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_Node_GetSiteRoot]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_Node_GetSiteRoot]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************
* Purpose:	Gets the root node of a site.
* Author:	BryanP
* Date:		08/13/2007
* Params: 
*	
********************************************************/
CREATE PROCEDURE [dbo].[Core_Node_GetSiteRoot] 
AS
BEGIN
	SELECT
		n.NodeID,
		n.Title,
		n.ShortTitle,
		n.Description,
		PrettyUrl = (SELECT PrettyUrl FROM PrettyUrl WHERE NodeID = n.NodeID AND IsPrimary = 1),
		n.UpdateUserID,
		n.UpdateDate
	FROM Node n
	WHERE ParentNodeID is null 
END

GO
GRANT EXECUTE ON [dbo].[Core_Node_GetSiteRoot] TO [websiteuser_role]
GO
