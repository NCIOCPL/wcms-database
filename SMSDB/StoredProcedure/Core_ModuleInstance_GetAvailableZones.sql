IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_ModuleInstance_GetAvailableZones]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_ModuleInstance_GetAvailableZones]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE [dbo].Core_ModuleInstance_GetAvailableZones
	@ModuleInstanceID uniqueidentifier
AS
BEGIN
	Declare @ZoneInstanceID uniqueidentifier,
			@NodeID uniqueidentifier

	select @ZoneInstanceID =M.ZoneInstanceID, @NodeID=Z.NodeID  
	from dbo.ModuleInstance M
	inner join dbo.ZoneInstance Z
	on M.ZoneInstanceID = Z.ZoneInstanceID
	where ModuleInstanceID = @ModuleInstanceID 

	BEGIN TRY

		SELECT ZoneName, ZoneInstanceID
		FROM dbo.TemplateZone T, dbo.ZoneInstance Z
		Where T.TemplateZoneID = Z.TemplateZoneID and 
			Z.NodeID = @NodeID and Z.ZoneInstanceID != @ZoneInstanceID

		
	END TRY

	BEGIN CATCH
		RETURN 11310
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[Core_ModuleInstance_GetAvailableZones] TO [websiteuser_role]
GO
