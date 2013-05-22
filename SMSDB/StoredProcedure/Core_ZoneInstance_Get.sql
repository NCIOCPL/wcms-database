IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_ZoneInstance_Get]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_ZoneInstance_Get]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE [dbo].Core_ZoneInstance_Get
    @ZoneInstanceID uniqueidentifier
AS
BEGIN
	BEGIN TRY

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
		Where   ZoneInstanceID = @ZoneInstanceID
		

	END TRY

	BEGIN CATCH
		RETURN 10601
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[Core_ZoneInstance_Get] TO [websiteuser_role]
GO
