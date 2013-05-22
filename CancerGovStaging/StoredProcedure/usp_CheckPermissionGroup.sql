IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_CheckPermissionGroup]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_CheckPermissionGroup]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.usp_RetrieveViewObject
   Owner:Jhe Purpose: For admin side Script Date: 1/15/2002 16:00:49 pm 
*/

CREATE PROCEDURE dbo.usp_CheckPermissionGroup
	(
	@GroupID		int,
 	@PermissionName 	varchar(50),
	@LoginName 		varchar(40)
	)
AS
BEGIN
	
	SELECT COUNT(*) FROM UserGroupPermissionMap WHERE
	UserID = (SELECT UserID FROM NCIUsers WHERE loginName = @LoginName ) AND 
	GroupID = @GroupID AND 
	PermissionID = (SELECT PermissionID FROM [Permissions] WHERE PermissionName = @PermissionName )



END
GO
GRANT EXECUTE ON [dbo].[usp_CheckPermissionGroup] TO [webadminuser_role]
GO
