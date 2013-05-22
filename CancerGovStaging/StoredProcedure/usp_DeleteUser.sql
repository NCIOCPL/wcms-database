IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_DeleteUser]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_DeleteUser]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/* usp_deleteMacro for deleting macro. Only called by SubmitMacroForDeletionApproval
* Jay He 4/4/2003
*/

CREATE PROCEDURE [dbo].[usp_DeleteUser]
(
	@Name 	varchar(50)
)
AS
BEGIN	
	SET NOCOUNT ON;

	Declare @userID uniqueidentifier

	select @userID =userID  from nciusers where LoginName =@Name

	BEGIN TRAN Tran_DeleteList

		DELETE FROM  UserGroupPermissionMap
		WHERE userID = @userID				
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN  Tran_DeleteList
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 	
	
		DELETE FROM NCIMessage
		WHERE SenderID  =  @userID	or
			RecipientID = @userID				
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN  Tran_DeleteList
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 	

	Commit  TRAN  Tran_DeleteList

	SET NOCOUNT OFF
	RETURN 0 

END
GO
GRANT EXECUTE ON [dbo].[usp_DeleteUser] TO [webadminuser_role]
GO
