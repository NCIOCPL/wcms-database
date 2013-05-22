IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_DeletePermissionMap]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_DeletePermissionMap]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** 	Object:  Stored Procedure dbo.usp_InsertLink  
	Purpose: This script can be used for  inserting viewobjects.	Script Date: 4/30/2002 11:43:49 pM ******/

CREATE PROCEDURE dbo.usp_DeletePermissionMap
(
	@LoginName		varchar(40),
	@GroupIDName		varchar(50),
	@PermissionName	varchar(50)
)
AS
BEGIN
	SET NOCOUNT ON;
		
	/*
	** Add a viewobject 
	*/	
	DELETE FROM UserGroupPermissionMap 
	WHERE	UserID = (SELECT UserID FROM NCIUsers WHERE LoginName =@LoginName ) AND
			GroupID = (SELECT GroupID FROM Groups WHERE GroupIDName = @GroupIDName) AND
			PermissionID = (SELECT PermissionID FROM Permissions WHERE PermissionName = @PermissionName )
			
	IF (@@ERROR <> 0)
	BEGIN
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END


	SET NOCOUNT OFF
	RETURN 0 

END
GO
GRANT EXECUTE ON [dbo].[usp_DeletePermissionMap] TO [webadminuser_role]
GO
