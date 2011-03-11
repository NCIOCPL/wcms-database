IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_CheckUserPermissionMap]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_CheckUserPermissionMap]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** 	Object:  Stored Procedure dbo.usp_InsertLink  
	Purpose: This script can be used for  inserting viewobjects.	Script Date: 4/30/2002 11:43:49 pM ******/

CREATE PROCEDURE dbo.usp_CheckUserPermissionMap
(
	@UserID		uniqueidentifier,
	@GroupID		int,
	@PermissionID		int
)
AS
BEGIN
	declare  @count int 

	select @count = count(*) from  UserGroupPermissionMap where UserID= @UserID and  GroupID=@GroupID  and PermissionID= @PermissionID  

	return @count
END
GO
GRANT EXECUTE ON [dbo].[usp_CheckUserPermissionMap] TO [webadminuser_role]
GO
