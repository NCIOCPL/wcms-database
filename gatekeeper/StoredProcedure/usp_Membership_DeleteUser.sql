IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_Membership_DeleteUser]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[usp_Membership_DeleteUser]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].[usp_Membership_DeleteUser]
    @UserName         nvarchar(256)
AS
BEGIN
    DECLARE @UserId               uniqueidentifier
    SELECT  @UserId               = NULL

    SELECT  @UserId = UserId
    FROM    dbo.Users u
    WHERE   LOWER(UserName)      = LOWER(@UserName)
  
    IF (@UserId IS NULL)
    BEGIN
        GOTO Cleanup
    END

	BEGIN Tran

		DELETE FROM dbo.UsersInRoles WHERE @UserId = UserId
		IF( @@ERROR <> 0 )
		BEGIN
			ROLLBACK TRANSACTION
			GOTO Cleanup
		END
	    
		DELETE FROM dbo.Users WHERE @UserId = UserId
		IF( @@ERROR <> 0 )
		BEGIN
			ROLLBACK TRANSACTION
			GOTO Cleanup
		END

	Commit Tran
   
    RETURN 0

Cleanup:
    RETURN -1

END

GO
GRANT EXECUTE ON [dbo].[usp_Membership_DeleteUser] TO [gatekeeper_role]
GO
