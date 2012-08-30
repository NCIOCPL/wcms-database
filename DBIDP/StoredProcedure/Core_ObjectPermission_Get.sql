IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_ObjectPermission_Get]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_ObjectPermission_Get]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

--Right now we only support getting mappings for nodes,
--in the future though this could change, so lets make the
--interface in such a way as us passing in an object id.
CREATE PROCEDURE dbo.Core_ObjectPermission_Get
	@ObjectID   UniqueIdentifier
AS
BEGIN
	set nocount on
	SELECT [RolePermissionBinary]
	FROM [dbo].[NodeRoleBinary]
	Where nodeID= @ObjectID	
END

GO
GRANT EXECUTE ON [dbo].[Core_ObjectPermission_Get] TO [websiteuser_role]
GO
