IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[BreadCrumbs_BCPages_Get]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[BreadCrumbs_BCPages_Get]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create  PROCEDURE [dbo].[BreadCrumbs_BCPages_Get]
(
		@NodeID uniqueidentifier		
)
AS
BEGIN

	WITH CTE (NodeID, ParentNodeID, ShortTitle,  Priority, TreeLevel) 
	AS
	(
		SELECT NodeID, ParentNodeID, ShortTitle,  Priority, 1 as TreeLevel
		FROM Node
		WHERE NodeID=@NodeID 
		UNION ALL
		SELECT n.NodeID, n.ParentNodeID, n.ShortTitle,  n.Priority, 1 + TreeLevel
		FROM Node n
		JOIN CTE
		ON n.NodeID =CTE.ParentNodeID 
	)

	SELECT NodeID, ShortTitle, Priority, TreeLevel FROM CTE
--	where NodeID=@NodeID
	ORDER By TreeLevel desc
	
END


GO
GRANT EXECUTE ON [dbo].[BreadCrumbs_BCPages_Get] TO [websiteuser_role]
GO
