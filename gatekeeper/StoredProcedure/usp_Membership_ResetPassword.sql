IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_Membership_ResetPassword]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[usp_Membership_ResetPassword]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].[usp_Membership_ResetPassword]
    @UserName                    nvarchar(256),
    @NewPassword                 nvarchar(128),
    @PasswordAnswer              nvarchar(128) = NULL
AS
BEGIN
  
    DECLARE @UserId                                 uniqueidentifier
    SET     @UserId = NULL

    SELECT  @UserId = UserId
    FROM    Users
    WHERE   LOWER(UserName) = LOWER(@UserName)

    IF ( @UserId IS NULL )
        GOTO Cleanup


    UPDATE dbo.Users
    SET    Password = @NewPassword
    WHERE  @UserId = UserId AND
           ( ( @PasswordAnswer IS NULL ) OR ( LOWER( PasswordAnswer ) = LOWER( @PasswordAnswer ) ) )


    RETURN 0

Cleanup:
    RETURN 1

END

GO
GRANT EXECUTE ON [dbo].[usp_Membership_ResetPassword] TO [gatekeeper_role]
GO
