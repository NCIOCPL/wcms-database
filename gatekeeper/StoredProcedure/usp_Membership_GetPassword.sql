IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_Membership_GetPassword]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[usp_Membership_GetPassword]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].[usp_Membership_GetPassword]
    @UserName                       nvarchar(256),
    @PasswordAnswer                 nvarchar(128) = NULL
AS
BEGIN
    DECLARE @UserId                                 uniqueidentifier
    DECLARE @Password                               nvarchar(128)
    DECLARE @passAns                                nvarchar(128)
   
    DECLARE @ErrorCode     int
    SET @ErrorCode = 0

    SELECT  @UserId = UserId,
            @Password = Password,
            @passAns = PasswordAnswer
    FROM    Users 
    WHERE   LOWER(@UserName) =   LOWER(UserName)
	
    IF ( @@rowcount = 0 )
    BEGIN
        SET @ErrorCode = 1
        GOTO Cleanup
    END


    IF ( NOT( @PasswordAnswer IS NULL ) )
    BEGIN
        IF( ( @passAns IS NULL ) OR ( LOWER( @passAns ) <> LOWER( @PasswordAnswer ) ) )
        BEGIN
            SET @ErrorCode = 3
            GOTO Cleanup
        END
    END

    SELECT @Password

    RETURN 0

Cleanup:
    RETURN @ErrorCode

END

GO
GRANT EXECUTE ON [dbo].[usp_Membership_GetPassword] TO [gatekeeper_role]
GO
