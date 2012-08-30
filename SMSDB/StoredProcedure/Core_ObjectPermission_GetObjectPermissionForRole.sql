IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_ObjectPermission_GetObjectPermissionForRole]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_ObjectPermission_GetObjectPermissionForRole]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************
* Purpose:	This will get all roles mapping for a CMSGroup in the system
* Author:	Jhe
* Date:		8/21/2007
* Params:   @memberID member ID to be checked
*	
********************************************************/


CREATE PROCEDURE dbo.Core_ObjectPermission_GetObjectPermissionForRole
	@roleID bigint
AS
BEGIN

	Select M.RoleID, M.NodeID, N.Title as 'Title', 'Page' as ObjectType, P.PrettyURL as 'URL', MemberType, M.MemberID, G.GroupName as [MemberName]
	From dbo.MemberNodeRoleMap M
	inner join dbo.[Group] G
	on M.MemberID = G.GroupID
	inner join dbo.Node N
	on M.NodeID = N.NodeID
	inner join dbo.PrettyURL P
	on N.NodeID = P.NodeID
	inner join dbo.Member ME
	on M.MemberID = ME.MemberID
	Where M.RoleID=  @roleID and P.IsPrimary=1
	union
	Select M.RoleID, M.NodeID, N.Title as 'Title', 'Page' as ObjectType, P.PrettyURL as 'URL', MemberType, M.MemberID, '' as [MemberName]
	From dbo.MemberNodeRoleMap M
	inner join dbo.[User] U
	on M.MemberID = U.UserID
	inner join dbo.Node N
	on M.NodeID = N.NodeID
	inner join dbo.PrettyURL P
	on N.NodeID = P.NodeID
	inner join dbo.Member ME
	on M.MemberID = ME.MemberID
	Where M.RoleID=  @roleID and P.IsPrimary=1
	Order by N.Title 

END


GO
GRANT EXECUTE ON [dbo].[Core_ObjectPermission_GetObjectPermissionForRole] TO [websiteuser_role]
GO
