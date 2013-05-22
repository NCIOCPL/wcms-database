IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_Node_Delete]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_Node_Delete]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE [dbo].Core_Node_Delete
	@NodeID uniqueidentifier,
	@updateUserID varchar(50)
AS
BEGIN
	-- If exists child node, return at this point
	if (exists (select 1 from dbo.Node where ParentNodeID = @NodeID))
		return 12000 

	DECLARE @ZoneInstances TABLE (
		ZoneInstanceID uniqueIdentifier
	)

	--Get Zones for templates			
	Insert into 	@ZoneInstances
	SELECT  ZoneInstanceID
	From dbo.ZoneInstance
	Where NodeID = @NodeID

	DECLARE @Modules TABLE (
		ModuleInstanceID uniqueidentifier,
		ObjectID uniqueidentifier,
		objectTypeID int,
		ObjectOwnerID uniqueidentifier,
		IsShared bit,
		IsVirtual bit
	)

	--Get Modules for zone					
	INSERT INTO @Modules
	(	ModuleInstanceID,
		ObjectID,
		objectTypeID,
		ObjectOwnerID,
		IsShared,
		IsVirtual
		)
	SELECT 
		mi.ModuleInstanceID,
		mi.ObjectID,
		o.objectTypeID,
		o.OwnerID,
		o.IsShared,
		o.IsVirtual
	FROM @ZoneInstances zi
	JOIN ModuleInstance mi
	ON zi.ZoneInstanceID = mi.ZoneInstanceID
	JOIN dbo.Object o
	ON o.ObjectID = mi.ObjectID

	-- Check whether Has shared ojects used by other node
	if (exists ( select 1 from dbo.ModuleInstance where ModuleInstanceID not in 
						(	select ModuleInstanceID from @Modules)
					and objectID in 
						(select ObjectID from dbo.Object  where OwnerID = @NodeID and IsShared=1)
				)
		)
		return 12100 -- Has shared ojects used by other node

	DECLARE @List TABLE (
		ListID uniqueIdentifier
	)

	-- Get All List
	Insert into @List
	select ObjectID from dbo.Object where objectTypeID = 1 and OwnerID = @NodeID

	--1. Delete PrettyURL
	Delete From dbo.PrettyUrl where nodeid=@NodeID

	--2. Delete dbo.NodeProperty
	Delete from dbo.NodeProperty where nodeid=@NodeID

	--3. Delete dbo.NodeRoleBinary
	Delete from dbo.NodeRoleBinary where nodeid=@NodeID

	--4. Delete dbo.MemberNodeRoleMap
	Delete from dbo.MemberNodeRoleMap where NodeID=@NodeID

	--5. Delete dbo.LayoutDefinition
	Delete from dbo.LayoutDefinition where NodeID=@NodeID

	--6. Delete dbo.SiteNavItem
	Delete from dbo.SiteNavItem where NodeID=@NodeID

	--7. Delete moduleproperty
	Delete from dbo.ModuleInstanceProperty	 where 	ModuleInstanceID in (
		select 	ModuleInstanceID from 	@Modules)

	--Logic for Delete dbo.Object depending on type
	--if it is virtual, do nothing
	--if is not virtual
		--if is shared and isowner, delete (cause we checked in the beginning whether a shared being used by other pages). 
		--if is not shared, delete the object according to the Type
			--List, Delete link, listitem, list
				-- DocumentLink, don't delete
				-- ExternalLink: delete
				-- InternalLink: delete
				-- ListLink: delete -- not handled at this time
			--HTMLContent: delete 

	--8. Delete dbo.ExternalLink
	--Delete from dbo.ExternalLink where linkID in (select ListItemID from ListItem where 
	--	  ListItemTypeID =2 and ListID in (select listID from @List))
	
	--10. Delete listitem
	Delete from dbo.ListItem where listID in (select ListID from @List)
	
	--11. Delete list
	Delete from dbo.List where listID in (select ListID from @List)

	--12. Delete HTMLContent
	Delete From dbo.HtmlContent where HtmlContentID in (select objectID from dbo.Object  where objectTypeID = 4 and OwnerID = @NodeID)
	
	--14. Delete moduleinstance
	Delete from dbo.ModuleInstance where ModuleInstanceID in (select ModuleInstanceID from @Modules)

	--15. Delete zoneInstance
	Delete from dbo.ZoneInstance where ZoneInstanceID in (select ZoneInstanceID from @ZoneInstances)

	--13. Delete object
	Delete from dbo.Object where OwnerID = @NodeID 	

	--16. Delete Node
	Delete from dbo.Node where NodeID = @NodeID

END

GO
GRANT EXECUTE ON [dbo].[Core_Node_Delete] TO [websiteuser_role]
GO
