IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_ObjectPermission_GetObjectPermissionForMember]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_ObjectPermission_GetObjectPermissionForMember]
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


CREATE PROCEDURE dbo.Core_ObjectPermission_GetObjectPermissionForMember
	@memberID uniqueidentifier
AS
BEGIN

	Select M.RoleID, M.NodeID, N.Title as 'Title', G.RoleName as 'Role', 'Page' as ObjectType, P.PrettyURL as 'URL'
	From dbo.MemberNodeRoleMap M
	Inner join dbo.[Role] G
	on G.RoleID = M.RoleID
	inner join dbo.Node N
	on M.NodeID = N.NodeID
	inner join dbo.PrettyURL P
	on N.NodeID = P.NodeID
	Where M.MemberID = @memberID
	Order by N.Title

END


GO
GRANT EXECUTE ON [dbo].[Core_ObjectPermission_GetObjectPermissionForMember] TO [websiteuser_role]
GO
