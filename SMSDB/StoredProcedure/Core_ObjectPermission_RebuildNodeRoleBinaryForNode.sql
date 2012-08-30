IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_ObjectPermission_RebuildNodeRoleBinaryForNode]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_ObjectPermission_RebuildNodeRoleBinaryForNode]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/*************************************************************************
Purpose:  To rebuild the a row in the NodeRoleBinary table for a node.
(So what the heck does that mean, well, see notes)
Params: @NodeID uniqueIdentifier -- The nodeId of the node to rebuild
Author: Heji
Date: ???
Updated:
	7/27/07 Updated for new users stuff --Bryanp 

Notes:
Ok here is what we do...
All content objects that live on a page(from here on out, a Node)) are permissioned 
by that node.  Which means if I want to know if a user can edit a list, I
must check if that user has the permission to edit the node that contains the list.

In order to make our lives sane, we assign permissions to a Role.  For example we 
create a role called "Content Editor" and give it the permissions of View, Add, 
Modify, and Delete.  From that point on I can assign users the permissions to a
node by saying that user has the role of "Content Editor" for a node.

Just so I do not have to assign that mapping to every node in the system, some sites
have over 700 pages, we allow this assignment to be inherited.  This means that all
child nodes of a node will inherit this mapping.  Those nodes can be assigned other
mappings, but the effective mappings will be mappings for that node + the mappings
for the parent node.

One more thing to make our lives easy is that we actually give MemberIDs a role to a
Node.  A Member is a User or Group.  This way if there are 5 people that need a 
"Content Editor" role on a node then we only have to create 1 group and we can add
and remove people without too much trouble.  As will become apparant later in this,
it also does not cause us to have to rebuild the NodeRoleBinary table for the node
and sub nodes in question.

So what does this actually do?
------------------------------
This proc finds all of the rows from the MemberNodeRoleMap for a node it then builds
up the RolePermissionBinary column so that we can easily get all permissions for all
members for a given node.  It also builds up all of the mappings for sub nodes since
permissions inherit from a parent to its children.

What is contained in the RolePermissionBinary column?
-----------------------------------------------------
It is a comma separated list of strings that look like:
MemberID_PermissionType

The MemberID is from the MemberNodeRoleMap
The PermissionType is managed in C# code and is a BitField of permissions.  This
comes from the Permission column of the Role Table, where the RoleID = the RoleID column
of the MemberNodeRoleMap. The permission of the roles
have already been bitwise-or'ed when the role was configured.

How do we use the information in the RolePermissionBinary column?
-----------------------------------------------------------------
When a user wants to edit an object on a page we get the "permissions" for that
object.  This means we find the OwnerObjectID(NodeID) of that object.  Then we call
Core_ObjectPermission_GetNodeRoleBinary to get the RolePermissionBinary column for
that node.  The C# code then parses out the list of MemberID_PermissionType items in
the RolePermissionBinary.  Then we loop through all of the Roles (Groups that user 
belongs to along with the ID of the user) of that user to see if the "Role name" matches
any of the defined MemberIDs.  We then bitwise-or the permissions of the matching
MemberIDs.  This gives us the permissions that user has to an object.  We can then check
and see if a user has the permission we need to an object.  

**************************************************************************/
Create  PROCEDURE [dbo].Core_ObjectPermission_RebuildNodeRoleBinaryForNode
	@NodeID	uniqueIdentifier
AS
BEGIN
	Declare @RolePermissionBinary varchar(max)

	--Get correct binary hashtable by looping through parent's permission
/*	set @RolePermissionBinary =''
	Select @RolePermissionBinary = @RolePermissionBinary + ',' + RoleBinary From dbo.Role_Function_GetNodeRoleBinary(@NodeID)
*/
	
	select @RolePermissionBinary = 
	(select  RoleBinary  +','
	from	dbo.Core_Function_GetNodeRoleBinary(@NodeID)
	FOR XML PATH('')) 

	BEGIN TRY
		if (@RolePermissionBinary is not null)
		BEGIN
			select @RolePermissionBinary = LEFT(@RolePermissionBinary, len(@RolePermissionBinary) -1)  

			-- check whether exists
			if (not exists (select 1 from dbo.Node where  [NodeID]= @NodeID))
				return 80012

			if (exists (select 1 from dbo.NodeRoleBinary where [NodeID]= @NodeID ))
			BEGIN
					update dbo.NodeRoleBinary 
					set RolePermissionBinary = @RolePermissionBinary
					where [NodeID]= @NodeID
				
			END
			ELSE
			BEGIN
				insert into dbo.NodeRoleBinary 
				([NodeID], RolePermissionBinary)
				values 
				(@NodeID, @RolePermissionBinary)
			END
		END
		ELSE
		BEGIN
				Delete from dbo.NodeRoleBinary where [NodeID]= @NodeID
		END
		

		DECLARE	@CTE TABLE (
			RowNumber int,
			ID uniqueIdentifier
		);

		--Immediate Children. only first level.
		INSERT INTO @CTE
			(
				RowNumber, 
				ID
			)
		SELECT	
			Row_Number() over (order by  nodeID ) as RowNumber,
			nodeID
		FROM dbo.Node
		Where ParentNodeID = @NodeID


		-- loop through child to update each one child's binary
		DECLARE @LoopNodeID uniqueIdentifier,
			@LoopCounter int,
			@rtnVal int

		set @LoopCounter = 1

		Select 	@LoopNodeID = ID
		From @CTE --FROM dbo.Core_Function_GetChildNodes(@NodeID)
		WHERE RowNumber = @LoopCounter

		--Copy the data over
		While @@rowcount <> 0
		BEGIN
			EXEC @rtnVal = Core_ObjectPermission_RebuildNodeRoleBinaryForNode @LoopNodeID

			IF @rtnVal <> 0
					RETURN @rtnVal
			
			SET @LoopCounter = @LoopCounter + 1

			Select 	@LoopNodeID = ID
			FROM @CTE
			WHERE RowNumber = @LoopCounter
		END
		-- End Loop
		
		return 0 
		
	END TRY

	BEGIN CATCH
		Print Error_Message()
		RETURN 80011
	END CATCH 
END



GO
GRANT EXECUTE ON [dbo].[Core_ObjectPermission_RebuildNodeRoleBinaryForNode] TO [websiteuser_role]
GO
