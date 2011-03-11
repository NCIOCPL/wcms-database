IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_DeleteUserPermissionMap]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_DeleteUserPermissionMap]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** 	Object:  Stored Procedure dbo.usp_InsertLink  
	Purpose: This script can be used for  inserting viewobjects.	Script Date: 4/30/2002 11:43:49 pM ******/

CREATE PROCEDURE dbo.usp_DeleteUserPermissionMap
(
	@UserID		uniqueidentifier,
	@GroupID		int,
	@PermissionID		int
)
AS
BEGIN
	SET NOCOUNT ON;
		
	/*
	** Add a viewobject 
	*/	
	delete from UserGroupPermissionMap 
	where UserID =@UserID and  GroupID = @GroupID and  PermissionID =@PermissionID					
	IF (@@ERROR <> 0)
	BEGIN
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END


	SET NOCOUNT OFF
	RETURN 0 

END
GO
GRANT EXECUTE ON [dbo].[usp_DeleteUserPermissionMap] TO [webadminuser_role]
GO
