IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_ConfigurableRoles_GetRolesForUser]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_ConfigurableRoles_GetRolesForUser]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*-------------------------------------------
Notes: 
In order to figure out who has permissions to do what actions on a node we map:
member 1--1> node <1--1 role

A role is really a collection of permissions so it probably looks more like:
member 1--1> node <1--* permission

A member is either an user or a group, and a group is a collection of users,
so it looks more like:
user *--1> node <1--* permission

A node can have many of these.  For performance we cache this info into the NodeRoleBinaryMap
table.

What that leaves us is a collection that has a number of:
MemberID: permission[]

So when getting the configurable roles for a user is really just
get a collection of MemberIDs for the user, The groups the user is in
and the userID itself. These are returned as strings since the RoleProvider
mechanism only works with strings.  

I know this is confusing, but well, it is not that big of a deal once you work it out.
---------------------------------------------*/
Create PROCEDURE [dbo].Core_ConfigurableRoles_GetRolesForUser
	@UserID uniqueidentifier
AS
BEGIN
	
	select 
		Convert(varchar(36), GroupID) as [Name]
	From dbo.GroupUserMap 
	WHERE UserID= @UserID 
	AND groupID not in
		(select groupID from dbo.[group] where isactive=0)
	union
	-- Since the user can technically be mapped to an object,
	-- it is a "role" name
	select Convert(varchar(36), @UserID) as [Name]
	
END



GO
GRANT EXECUTE ON [dbo].[Core_ConfigurableRoles_GetRolesForUser] TO [websiteuser_role]
GO
