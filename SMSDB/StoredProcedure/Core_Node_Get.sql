IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_Node_Get]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_Node_Get]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE [dbo].Core_Node_Get
	@NodeID uniqueidentifier,
	@isLive bit = 0
AS
BEGIN

	Declare @PageTree Table (
		NodeID uniqueidentifier,
		TreeLevel int
	);
	DECLARE @LayoutTemplateID uniqueIdentifier,
			@CATemplateID uniqueIdentifier

	DECLARE @ZoneInstances TABLE (
		ZoneInstanceID uniqueIdentifier, 
		OwnerNodeID uniqueIdentifier, 
		OwnerTitle varchar(255), 
		TemplateZoneID uniqueidentifier,
		ZoneName varchar(255),
		TemplateZoneTypeID int,
		CanInherit bit
	)

	DECLARE @Modules TABLE (
		ModuleInstanceID uniqueidentifier,
		ZoneInstanceID uniqueidentifier,
		ModuleID uniqueidentifier,
		Priority int,
		ObjectID uniqueidentifier,
		ObjectTypeID int,
		ObjectOwnerID uniqueidentifier,
		title varchar(255),
		IsShared bit,
		isDirty bit,
		IsVirtual bit,
		ModuleName varchar(50),
		GenericModuleID uniqueidentifier,
		StyleSheetID uniqueidentifier,
		AssemblyName varchar(100),
		EditAssemblyName varchar(100),
		Namespace varchar(256),
		Category int,
		moduleClass varchar(100),
		EditNameSpace varchar(256),
		EditModuleClass varchar(100),
		NodeID uniqueidentifier,
		TemplateZoneID uniqueidentifier,
		ZoneName varchar(50),
		TemplateZoneTypeID int,
		RolePermissionBinary image
	)


if @isLive = 1
BEGIN


					--Get the main node data.
						select 
							n.NodeID, 
							Title, 
							ShortTitle,
							Description,
							pu.PrettyUrl,
							ParentNodeID,
							ShowInNavigation,
							ShowInBreadCrumbs,
							Priority,
							status,
							isPublished,
							n.DisplayPostedDate,
							n.DisplayUpdateDate,
							n.DisplayReviewDate,
							n.DisplayExpirationDate,
							n.DisplayDateMode,
							n.CreateUserID, 
							n.CreateDate, 
							n.UpdateUserID, 
							n.UpdateDate,
							(Select RolePermissionBinary From dbo.NodeRoleBinary where nodeid=@NodeID) as Permission
						From dbo.PRODNode n
						JOIN dbo.PRODPrettyUrl pu
						ON n.NodeID = pu.NodeID
						AND pu.IsPrimary = 1
						where n.nodeid=@NodeID

						--Node Properties
						SELECT 
							NodePropertyID as PropertyID,
							NodeID as ItemID,
							np.PropertyTemplateID,		
							PropertyName,
							PropertyValue,
							ValueType
						From dbo.PRODNodeProperty np
						JOIN PropertyTemplate pt
						ON np.PropertyTemplateID = pt.PropertyTemplateID
						WHERE NodeID = @NodeID;


						with CTE (NodeID, ParentNodeID, TreeLevel)
						AS (
							SELECT n.NodeID, ParentNodeID, 1 as TreeLevel
							From dbo.PRODNode n
							WHERE n.NodeID = @NodeID
							UNION ALL
							SELECT n.NodeID, n.ParentNodeID, 1 + CTE.TreeLevel
							From dbo.PRODNode n
							JOIN CTE
							ON CTE.ParentNodeID = n.nodeid
							AND CTE.ParentNodeID is not null
						)

						INSERT INTO @PageTree
						(NodeID, TreeLevel)
						select NodeID, TreeLevel from CTE

						--Breadcrumb Trail
						SELECT pt.NodeID, Title, ShortTitle, PrettyUrl, ShowInBreadCrumbs, TreeLevel 
						FROM @PageTree pt
						JOIN dbo.PRODPrettyUrl pu
						ON pt.nodeid=pu.nodeid
						JOIN dbo.PRODNode n
						ON pt.NodeID = n.NodeID
						where isPrimary =1     ---min
						ORDER BY TreeLevel Desc

						--Definition Layout



						SELECT @LayoutTemplateID = LayoutTemplateID, @CATemplateID = ContentAreaTemplateID
						FROM PRODLayoutDefinition ld
						WHERE NodeID = @NodeID

						SELECT 
							@LayoutTemplateID as LayoutTemplateID, 
							@CATemplateID as ContentAreaTemplateID
						WHERE
							@LayoutTemplateID is not null

						SELECT LayoutTemplateID, TemplateName, [FileName], CreateUserID, CreateDate, UpdateUserID, UpdateDate,PrintFileName
						FROM LayoutTemplate
						WHERE LayoutTemplateID = @LayoutTemplateID

						SELECT ContentAreaTemplateID, TemplateName, [FileName], CreateUserID, CreateDate, UpdateUserID, UpdateDate ,PrintFileName
						FROM ContentAreaTemplate
						WHERE ContentAreaTemplateID = @CATemplateID

						--Get Zones for templates
					SELECT 
							ContentAreaTemplateID as TemplateID,
							catzm.TemplateZoneID,
							ZoneName,
							TemplateZoneTypeID
						FROM ContentAreaTemplateZoneMap catzm
						JOIN TemplateZone tz
						ON catzm.TemplateZoneID = tz.TemplateZoneID
						WHERE ContentAreaTemplateID = @CATemplateID
						UNION ALL
						SELECT 
							LayoutTemplateID as TemplateID,
							ltzm.TemplateZoneID,
							ZoneName,
							TemplateZoneTypeID
						FROM LayoutTemplateZoneMap ltzm
						JOIN TemplateZone tz
						ON ltzm.TemplateZoneID = tz.TemplateZoneID
						WHERE LayoutTemplateID = @LayoutTemplateID


						--Get Modules
						INSERT INTO @ZoneInstances
						(ZoneInstanceID, OwnerNodeID, OwnerTitle, TemplateZoneID, ZoneName, TemplateZoneTypeID, CanInherit)
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
							JOIN dbo.PRODZoneInstance zi
							ON pt.NodeID = zi.NodeID
							WHERE 
								zi.NodeID = @NodeID
								OR CanInherit = 1
						)a
						JOIN dbo.PRODNode n
						ON a.NodeID = n.NodeID
						JOIN TemplateZone tz
						ON a.TemplateZoneID = tz.TemplateZoneID
						WHERE RowNumber = 1
						ORDER BY TreeLevel Asc

						Select * from @ZoneInstances


						INSERT INTO @Modules
						(	ModuleInstanceID,
							ZoneInstanceID,
							ModuleID,
							Priority,
							ObjectID,
							ObjectTypeID,
							ObjectOwnerID,
							title,
							IsShared,
							isDirty,
							IsVirtual,
							ModuleName,
							GenericModuleID,
							StyleSheetID,
							AssemblyName,
							EditAssemblyName,
							Namespace,
							Category,
							moduleClass,
							EditNameSpace,
							EditModuleClass,
							NodeID,
							TemplateZoneID,
							ZoneName,
							TemplateZoneTypeID,
							RolePermissionBinary
						)
						SELECT 
							mi.ModuleInstanceID,
							mi.ZoneInstanceID,
							mi.ModuleID,
							mi.Priority,
							mi.ObjectID,
							gm.Category as ObjectTypeID,
							o.OwnerID as ObjectOwnerID,
							o.title,
							o.IsShared,
							o.isDirty,		
							gm.IsVirtual,
							m.ModuleName,
							m.GenericModuleID,
							m.CSSID,
							gm.AssemblyName,
							gm.EditAssemblyName,
							gm.Namespace,
							gm.Category,
							gm.moduleClass,
							gm.EditNameSpace,
							gm.EditModuleClass,
							zi.OwnerNodeID as NodeID,
							zi.TemplateZoneID,
							zi.ZoneName,
							zi.TemplateZoneTypeID,
							null as RolePermissionBinary
						FROM @ZoneInstances zi
						JOIN dbo.PRODModuleInstance mi
						ON zi.ZoneInstanceID = mi.ZoneInstanceID
						--JOIN dbo.PRODModule m /* Not doing workflow on modules, only on content */
						JOIN dbo.Module m
						ON mi.ModuleID = m.ModuleID
						JOIN GenericModule gm
						ON m.GenericModuleID = gm.GenericModuleID
						JOIN dbo.PRODObject o
						ON o.ObjectID = mi.ObjectID

						SELECT 
							ModuleInstanceID,
							ZoneInstanceID,
							ModuleID,
							Priority,
							ObjectID,
							ObjectTypeID,
							ObjectOwnerID,
							title,
							IsShared,
							isDirty,
							IsVirtual,
							ModuleName,
							GenericModuleID,
							StyleSheetID,
							AssemblyName,
							EditAssemblyName,
							Namespace,
							Category,
							moduleClass,
							EditNameSpace,
							EditModuleClass,
							NodeID,
							TemplateZoneID,
							ZoneName,
							TemplateZoneTypeID,
							RolePermissionBinary
						FROM @Modules 
						order by Priority

						--StyleSheets
						SELECT 
							m.StyleSheetID,
							MainClassName,
							CSS	
						FROM @Modules m
						--JOIN dbo.PRODModuleStyleSheet mss
						JOIN dbo.ModuleStyleSheet mss
						ON m.StyleSheetID = mss.StyleSheetID

						--Module Properties
						SELECT 
							InstancePropertyID as PropertyID,
							m.ModuleInstanceID as ItemID,
							mip.PropertyTemplateID,		
							PropertyName,
							PropertyValue,
							ValueType
						FROM dbo.PRODModuleInstanceProperty mip
						JOIN PropertyTemplate pt
						ON mip.PropertyTemplateID = pt.PropertyTemplateID
						JOIN @Modules m
						on mip.ModuleInstanceID = m.ModuleInstanceID


END




else
BEGIN
							--Get the main node data.
							select 
								n.NodeID, 
								Title, 
								ShortTitle,
								Description,
								pu.PrettyUrl,
								ParentNodeID,
								ShowInNavigation,
								ShowInBreadCrumbs,
								Priority,
								status,
								isPublished,
								n.DisplayPostedDate,
								n.DisplayUpdateDate,
								n.DisplayReviewDate,
								n.DisplayExpirationDate,
								n.DisplayDateMode,
								n.CreateUserID, 
								n.CreateDate, 
								n.UpdateUserID, 
								n.UpdateDate,
								(Select RolePermissionBinary FROM NodeRoleBinary where nodeid=@NodeID) as Permission
							from node n
							JOIN PrettyUrl pu
							ON n.NodeID = pu.NodeID
							AND pu.IsPrimary = 1
							where n.nodeid=@NodeID

							--Node Properties
							SELECT 
								NodePropertyID as PropertyID,
								NodeID as ItemID,
								np.PropertyTemplateID,		
								PropertyName,
								PropertyValue,
								ValueType
							FROM NodeProperty np
							JOIN PropertyTemplate pt
							ON np.PropertyTemplateID = pt.PropertyTemplateID
							WHERE NodeID = @NodeID;


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

							--Breadcrumb Trail
							SELECT pt.NodeID, Title, ShortTitle, PrettyUrl, ShowInBreadCrumbs, TreeLevel 
							FROM @PageTree pt
							JOIN PrettyUrl pu
							ON pt.nodeid=pu.nodeid
							JOIN Node n
							ON pt.NodeID = n.NodeID
							where isPrimary =1     --Min
							ORDER BY TreeLevel Desc

							--Definition Layout


							SELECT @LayoutTemplateID = LayoutTemplateID, @CATemplateID = ContentAreaTemplateID
							FROM LayoutDefinition ld
							WHERE NodeID = @NodeID

							SELECT 
								@LayoutTemplateID as LayoutTemplateID, 
								@CATemplateID as ContentAreaTemplateID
							WHERE
								@LayoutTemplateID is not null

							SELECT LayoutTemplateID, TemplateName, [FileName], CreateUserID, CreateDate, UpdateUserID, UpdateDate ,PrintFileName
							FROM LayoutTemplate
							WHERE LayoutTemplateID = @LayoutTemplateID

							SELECT ContentAreaTemplateID, TemplateName, [FileName], CreateUserID, CreateDate, UpdateUserID, UpdateDate ,PrintFileName
							FROM ContentAreaTemplate
							WHERE ContentAreaTemplateID = @CATemplateID

							--Get Zones for templates
						SELECT 
								ContentAreaTemplateID as TemplateID,
								catzm.TemplateZoneID,
								ZoneName,
								TemplateZoneTypeID
							FROM ContentAreaTemplateZoneMap catzm
							JOIN TemplateZone tz
							ON catzm.TemplateZoneID = tz.TemplateZoneID
							WHERE ContentAreaTemplateID = @CATemplateID
							UNION ALL
							SELECT 
								LayoutTemplateID as TemplateID,
								ltzm.TemplateZoneID,
								ZoneName,
								TemplateZoneTypeID
							FROM LayoutTemplateZoneMap ltzm
							JOIN TemplateZone tz
							ON ltzm.TemplateZoneID = tz.TemplateZoneID
							WHERE LayoutTemplateID = @LayoutTemplateID


							--Get Modules
							INSERT INTO @ZoneInstances
							(ZoneInstanceID, OwnerNodeID, OwnerTitle, TemplateZoneID, ZoneName, TemplateZoneTypeID, CanInherit)
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

							Select * from @ZoneInstances

					
							INSERT INTO @Modules
							(	ModuleInstanceID,
								ZoneInstanceID,
								ModuleID,
								Priority,
								ObjectID,
								ObjectTypeID,
								ObjectOwnerID,
								title,
								IsShared,
								isDirty,
								IsVirtual,
								ModuleName,
								GenericModuleID,
								StyleSheetID,
								AssemblyName,
								EditAssemblyName,
								Namespace,
								Category,
								moduleClass,
								EditNameSpace,
								EditModuleClass,
								NodeID,
								TemplateZoneID,
								ZoneName,
								TemplateZoneTypeID,
								RolePermissionBinary
							)
							SELECT 
								mi.ModuleInstanceID,
								mi.ZoneInstanceID,
								mi.ModuleID,
								mi.Priority,
								mi.ObjectID,
								gm.Category as ObjectTypeID,
								o.OwnerID as ObjectOwnerID,
								o.title,
								o.IsShared,
								o.isDirty,		
								gm.IsVirtual,
								m.ModuleName,
								m.GenericModuleID,
								m.CSSID,
								gm.AssemblyName,
								gm.EditAssemblyName,
								gm.Namespace,
								gm.Category,
								gm.moduleClass,
								gm.EditNameSpace,
								gm.EditModuleClass,
								zi.OwnerNodeID as NodeID,
								zi.TemplateZoneID,
								zi.ZoneName,
								zi.TemplateZoneTypeID,
								null as RolePermissionBinary
							FROM @ZoneInstances zi
							JOIN ModuleInstance mi
							ON zi.ZoneInstanceID = mi.ZoneInstanceID
							JOIN Module m
							ON mi.ModuleID = m.ModuleID
							JOIN GenericModule gm
							ON m.GenericModuleID = gm.GenericModuleID
							JOIN dbo.Object o
							ON o.ObjectID = mi.ObjectID

							SELECT 
								ModuleInstanceID,
								ZoneInstanceID,
								ModuleID,
								Priority,
								ObjectID,
								ObjectTypeID,
								ObjectOwnerID,
								title,
								IsShared,
								isDirty,
								IsVirtual,
								ModuleName,
								GenericModuleID,
								StyleSheetID,
								AssemblyName,
								EditAssemblyName,
								Namespace,
								Category,
								moduleClass,
								EditNameSpace,
								EditModuleClass,
								NodeID,
								TemplateZoneID,
								ZoneName,
								TemplateZoneTypeID,
								RolePermissionBinary
							FROM @Modules 
							order by Priority

							--StyleSheets
							SELECT 
								m.StyleSheetID,
								MainClassName,
								CSS	
							FROM @Modules m
							JOIN ModuleStyleSheet mss
							ON m.StyleSheetID = mss.StyleSheetID

							--Module Properties
							SELECT 
								InstancePropertyID as PropertyID,
								m.ModuleInstanceID as ItemID,
								mip.PropertyTemplateID,		
								PropertyName,
								PropertyValue,
								ValueType
							FROM ModuleInstanceProperty mip
							JOIN PropertyTemplate pt
							ON mip.PropertyTemplateID = pt.PropertyTemplateID
							JOIN @Modules m
							on mip.ModuleInstanceID = m.ModuleInstanceID
END

END

GO
GRANT EXECUTE ON [dbo].[Core_Node_Get] TO [websiteuser_role]
GO
