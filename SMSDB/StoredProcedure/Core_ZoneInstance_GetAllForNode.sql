IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_ZoneInstance_GetAllForNode]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_ZoneInstance_GetAllForNode]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE [dbo].Core_ZoneInstance_GetAllForNode
    @NodeID uniqueidentifier
AS
BEGIN
	BEGIN TRY

		Declare @PageTree Table (
			NodeID uniqueidentifier,
			TreeLevel int
		);

		with CTE (NodeID, ParentNodeID, TreeLevel)
		AS (
			SELECT n.NodeID, ParentNodeID, 1 as TreeLevel
			FROM Node n
			WHERE n.NodeID = @NodeID
			UNION ALL
			SELECT n.NodeID, n.ParentNodeID, 1 + CTE.TreeLevel
			FROM Node n
			JOIN CTE
			ON CTE.ParentNodeID = n.nodeid
			AND CTE.ParentNodeID is not null
		)

		INSERT INTO @PageTree
		(NodeID, TreeLevel)
		select NodeID, TreeLevel from CTE

		SELECT 
			zi.ZoneInstanceID,
			zi.TemplateZoneID,
			zi.NodeID as OwnerNodeID,
			tz.TemplateZoneTypeID,
			n.Title as OwnerTitle,
			tz.ZoneName
			,zi.CanInherit
		  FROM [dbo].ZoneInstance zi
		JOIN TemplateZone tz
		ON zi.TemplateZoneID = tz.TemplateZoneID
		JOIN Node n
		ON zi.NodeID = n.NodeID
		Where   zi.NodeID = @NodeID		

		SELECT ZoneInstanceID, a.NodeID, n.ShortTitle, a.TemplateZoneID, tz.ZoneName, tz.TemplateZoneTypeID, a.CanInherit 
		FROM (
			SELECT 
				ZoneInstanceID, 
				pt.NodeID, 
				CanInherit, 
				TemplateZoneID, 
				TreeLevel,
				row_number() OVER (PARTITION BY TemplateZoneID ORDER BY TreeLevel) as RowNumber
			FROM @PageTree pt
			JOIN ZoneInstance zi
			ON pt.NodeID = zi.NodeID
			WHERE 
				zi.NodeID = @NodeID
				OR CanInherit = 1
		)a
		JOIN Node n
		ON a.NodeID = n.NodeID
		JOIN TemplateZone tz
		ON a.TemplateZoneID = tz.TemplateZoneID
		WHERE RowNumber = 1
		ORDER BY TreeLevel Asc

	END TRY

	BEGIN CATCH
		RETURN 10601
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[Core_ZoneInstance_GetAllForNode] TO [websiteuser_role]
GO
