IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_Node_GetChildTree]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_Node_GetChildTree]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE [dbo].Core_Node_GetChildTree
	@NodeID uniqueidentifier
AS
BEGIN

	WITH CTE (NodeID, Priority, TreeLevel) 
	AS
	(
		SELECT NodeID, Priority, 1 as TreeLevel
		FROM Node
		WHERE NodeID = @NodeID
		UNION ALL
		SELECT n.NodeID, n.Priority, 1 + TreeLevel
		FROM Node n
		JOIN CTE
		ON n.ParentNodeID = CTE.NodeID
	)

	SELECT NodeID, Priority, TreeLevel 
	FROM CTE
	ORDER By TreeLevel, Priority


END

GO
GRANT EXECUTE ON [dbo].[Core_Node_GetChildTree] TO [websiteuser_role]
GO
