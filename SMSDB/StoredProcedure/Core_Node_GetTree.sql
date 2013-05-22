IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_Node_GetTree]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_Node_GetTree]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE [dbo].Core_Node_GetTree
AS
BEGIN
	SELECT NodeID, ParentNodeID,  ShortTitle,   '' as URL
	FROM Node
/*	WITH CTE (NodeID, ParentNodeID,  ShortTitle,  Priority, TreeLevel) 
	AS
	(
		SELECT NodeID, ParentNodeID,  ShortTitle,   Priority, 1 as TreeLevel
		FROM Node
		WHERE ParentNodeID is null
		UNION ALL
		SELECT n.NodeID, n.ParentNodeID, n.ShortTitle,   n.Priority, 1 + TreeLevel
		FROM Node n
		JOIN CTE
		ON n.ParentNodeID = CTE.NodeID
	)

	SELECT CTE.NodeID, ParentNodeID,  ShortTitle, PrettyUrl as URL, Priority, TreeLevel 
	FROM CTE
	JOIN PrettyUrl pu
	ON CTE.NodeID = pu.NodeID
	AND IsPrimary = 1
	ORDER By TreeLevel, Priority


	SELECT N.NodeID, N.ParentNodeID,  N.ShortTitle, PrettyUrl as URL, CTE.Priority, CTE.TreeLevel 
	FROM Node N
	Join CTE
	on CTE.NodeID = N.NodeID
	JOIN PrettyUrl pu
	ON CTE.NodeID = pu.NodeID
	AND IsPrimary = 1
	ORDER By TreeLevel, Priority
*/
END

GO
GRANT EXECUTE ON [dbo].[Core_Node_GetTree] TO [websiteuser_role]
GO
