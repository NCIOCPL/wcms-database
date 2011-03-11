IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_RetrieveGroupMap]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_RetrieveGroupMap]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.usp_RetrieveViewObject
   Owner:Jhe Purpose: For admin side Script Date: 1/15/2002 16:00:49 pm 
*/

CREATE PROCEDURE dbo.usp_RetrieveGroupMap
	(
	@GroupIndex 		int,
	@UserIndex		int,
 	@GroupIDName 	varchar(50),
	@LoginName 		varchar(40)
	)
AS
BEGIN
	
	if (@UserIndex =0 AND @GroupIndex =0)
	BEGIN
		SELECT NCIUsers.LoginName AS [User], Groups.GroupIDName AS [Group], Permissions.PermissionName AS [Permission] 
		FROM NCIUsers, Groups, Permissions, UserGroupPermissionMap 
		WHERE NCIUsers.UserID = UserGroupPermissionMap.UserID AND Groups.GroupID = UserGroupPermissionMap.GroupID AND Permissions.PermissionID = UserGroupPermissionMap.PermissionID
		 ORDER BY [User] ASC 
	END
	ELSE if (	@UserIndex > 0 AND @GroupIndex =0)
	BEGIN
		SELECT NCIUsers.LoginName AS [User], Groups.GroupIDName AS [Group], Permissions.PermissionName AS [Permission] 
		FROM NCIUsers, Groups, Permissions, UserGroupPermissionMap 
		WHERE NCIUsers.UserID = UserGroupPermissionMap.UserID AND Groups.GroupID = UserGroupPermissionMap.GroupID AND Permissions.PermissionID = UserGroupPermissionMap.PermissionID
		 AND NCIUsers.LoginName = @LoginName
		 ORDER BY [User] ASC 
	END
	ELSE if (	@UserIndex = 0 AND @GroupIndex > 0)
	BEGIN
		SELECT NCIUsers.LoginName AS [User], Groups.GroupIDName AS [Group], Permissions.PermissionName AS [Permission] 
		FROM NCIUsers, Groups, Permissions, UserGroupPermissionMap 
		WHERE NCIUsers.UserID = UserGroupPermissionMap.UserID AND Groups.GroupID = UserGroupPermissionMap.GroupID AND Permissions.PermissionID = UserGroupPermissionMap.PermissionID
		 AND Groups.GroupIDName =@GroupIDName
		 ORDER BY [User] ASC 
	END
	ELSE
	BEGIN
		SELECT NCIUsers.LoginName AS [User], Groups.GroupIDName AS [Group], Permissions.PermissionName AS [Permission] 
		FROM NCIUsers, Groups, Permissions, UserGroupPermissionMap 
		WHERE NCIUsers.UserID = UserGroupPermissionMap.UserID AND Groups.GroupID = UserGroupPermissionMap.GroupID AND Permissions.PermissionID = UserGroupPermissionMap.PermissionID
		 AND Groups.GroupIDName =@GroupIDName  AND NCIUsers.LoginName = @LoginName
		 ORDER BY [User] ASC 
	END


END
GO
GRANT EXECUTE ON [dbo].[usp_RetrieveGroupMap] TO [webadminuser_role]
GO
