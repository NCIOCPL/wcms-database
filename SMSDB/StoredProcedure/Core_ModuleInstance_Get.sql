IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_ModuleInstance_Get]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_ModuleInstance_Get]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE [dbo].Core_ModuleInstance_Get
	@ModuleInstanceID uniqueidentifier
AS
BEGIN

	--Module Instance
	select 
		mi.ModuleInstanceID,
		mi.ZoneInstanceID,
		mi.ModuleID,
		mi.Priority,
		mi.ObjectID,
		gm.Category as ObjectTypeID,
		o.title,
		o.IsShared,
		o.isDirty,
		o.OwnerID as ObjectOwnerID,
		gm.IsVirtual,
		m.ModuleName,
		m.GenericModuleID,
		m.CSSID as StyleSheetID,
		gm.AssemblyName,
		gm.EditAssemblyName,
		gm.Namespace,
		gm.Category,
		gm.moduleClass,
		gm.EditNameSpace,
		gm.EditModuleClass,
		zi.NodeID,
		zi.TemplateZoneID,
		tz.ZoneName,
		tz.TemplateZoneTypeID,
		null as RolePermissionBinary
	FROM ModuleInstance mi
	JOIN Module m
	ON mi.ModuleID = m.ModuleID
	JOIN GenericModule gm
	ON m.GenericModuleID = gm.GenericModuleID
	JOIN ZoneInstance zi
	ON mi.ZoneInstanceID = zi.ZoneInstanceID
	JOIN TemplateZone tz
	ON zi.TemplateZoneID = tz.TemplateZoneID
	JOIN dbo.Object o
	ON o.ObjectID = mi.ObjectID
	WHERE ModuleInstanceID = @ModuleInstanceID

	--StyleSheets
	SELECT 
		StyleSheetID,
		MainClassName,
		CSS	
	FROM ModuleInstance mi
	JOIN Module m
	ON mi.ModuleID = m.ModuleID
	JOIN ModuleStyleSheet mss
	ON m.CSSID = mss.StyleSheetID
	WHERE ModuleInstanceID = @ModuleInstanceID

	--Properties
	SELECT 
		InstancePropertyID as PropertyID,
		mip.ModuleInstanceID as ItemID,
		mip.PropertyTemplateID,
		PropertyName,
		PropertyValue,
		ValueType
	FROM ModuleInstanceProperty mip
	JOIN PropertyTemplate pt
	ON mip.PropertyTemplateID = pt.PropertyTemplateID
	JOIN ModuleInstance mi
	on mip.ModuleInstanceID = mi.ModuleInstanceID
	WHERE mip.ModuleInstanceID = @ModuleInstanceID

END

GO
GRANT EXECUTE ON [dbo].[Core_ModuleInstance_Get] TO [websiteuser_role]
GO
