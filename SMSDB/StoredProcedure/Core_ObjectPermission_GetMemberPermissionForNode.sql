IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_ObjectPermission_GetMemberPermissionForNode]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_ObjectPermission_GetMemberPermissionForNode]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE [dbo].Core_ObjectPermission_GetMemberPermissionForNode
	@NodeID uniqueidentifier
AS
BEGIN
	Select M.RoleID, M.MemberID, G.GroupName as [MemberName], D.MemberType, R.RoleName
	From dbo.MemberNodeRoleMap M
	inner join dbo.[Group] G
	on M.MemberID = G.GroupID
	inner join dbo.Member D
	on D.MemberID = M.MemberID 
	inner join dbo.[Role] R
	on R.RoleID = M.RoleID
	where M.NodeID = @NodeID
	union
	Select M.RoleID, M.MemberID, ''  as [MemberName], D.MemberType, R.RoleName
	From dbo.MemberNodeRoleMap M
	inner join dbo.[User] S
	on S.UserID = M.MemberID
	inner join dbo.Member D
	on D.MemberID = M.MemberID 
	inner join dbo.[Role] R
	on R.RoleID = M.RoleID
	where M.NodeID = @NodeID
	order by D.MemberType

	Declare @ParentNodeID uniqueidentifier
	--Check parent
	select @ParentNodeID = ParentNodeID from dbo.Node where NodeID= @NodeID
		
	Declare @Binary TABLE(
			MemberID uniqueidentifier,
			RoleID	int
	)

	if (@ParentNodeID is not null)
	BEGIN	

		WITH CTE(ParentNodeID)
		AS
		(
			SELECT ParentNodeID
			FROM dbo.Node
			WHERE NodeID= @NodeID
			UNION ALL 
			SELECT N.ParentNodeID 
			FROM  dbo.Node N
				JOIN CTE ON 
				NodeID = CTE.ParentNodeID 
		)
		
		insert into @Binary
		select M.MemberID, M.RoleID
		from  dbo.MemberNodeRoleMap M
		inner join CTE
		on CTE.ParentNodeID = M.NodeID
	END


	Select M.RoleID, M.MemberID, G.GroupName as [MemberName], D.MemberType, R.RoleName
	From @Binary M
	inner join dbo.[Group] G
	on M.MemberID = G.GroupID
	inner join dbo.Member D
	on D.MemberID = M.MemberID 
	inner join dbo.[Role] R
	on R.RoleID = M.RoleID
	union
	Select M.RoleID, M.MemberID, ''  as [MemberName], D.MemberType, R.RoleName
	From @Binary M
	inner join dbo.[User] S
	on S.UserID = M.MemberID
	inner join dbo.Member D
	on D.MemberID = M.MemberID 
	inner join dbo.[Role] R
	on R.RoleID = M.RoleID


END

GO
GRANT EXECUTE ON [dbo].[Core_ObjectPermission_GetMemberPermissionForNode] TO [websiteuser_role]
GO
