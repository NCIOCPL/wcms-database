IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_UpdateUserPassword]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_UpdateUserPassword]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE dbo.usp_UpdateUserPassword
(
	@LoginName	VarChar(40),											
	@Password	VarChar(100),
	@UpdateUserID		varchar(40)	
)
AS
	SET NOCOUNT OFF;
	
	Update nciusers 
	set 	[password] =@Password, 
		lastvisit=getdate(), 
		updatedate=getdate(), 
		updateuserid=@UpdateUserID,
		passwordlastupdated=getdate()  
	where loginname=@LoginName
			
	IF (@@ERROR <> 0)
	BEGIN
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 


	SET NOCOUNT OFF

	RETURN 0
GO
GRANT EXECUTE ON [dbo].[usp_UpdateUserPassword] TO [webadminuser_role]
GO
