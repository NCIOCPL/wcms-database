IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Navigation_NavPages_Get]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Navigation_NavPages_Get]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE [dbo].Navigation_NavPages_Get
@RootNodeID uniqueidentifier
AS
BEGIN

	WITH CTE (NodeID, ParentNodeID, ShortTitle, ShowInNavigation, Priority, TreeLevel) 
	AS
	(
		SELECT NodeID, ParentNodeID, convert(varchar(max),ShortTitle), ShowInNavigation, Priority, 1 as TreeLevel
		FROM Node
		WHERE ParentNodeID is null
		UNION ALL
		SELECT n.NodeID, n.ParentNodeID, (CTE.ShortTitle + '/' + n.ShortTitle) as ShortTitle, n.ShowInNavigation, n.Priority, 1 + TreeLevel
		FROM Node n
		JOIN CTE
		ON n.ParentNodeID = CTE.NodeID	
	)

	SELECT NodeID, ShortTitle, Priority, TreeLevel FROM CTE
	WHERE NodeID=@RootNodeID
	ORDER By TreeLevel, Priority
END

GO
GRANT EXECUTE ON [dbo].[Navigation_NavPages_Get] TO [websiteuser_role]
GO
