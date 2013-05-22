IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_Membership_UpdateUserInfo]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[usp_Membership_UpdateUserInfo]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].[usp_Membership_UpdateUserInfo]
    @UserName                       nvarchar(256)
AS
BEGIN
    DECLARE @UserId                                 uniqueidentifier

    SELECT  @UserId = UserId
    FROM    Users 
    WHERE   LOWER(UserName) = LOWER(@UserName)

        UPDATE  dbo.Users
        SET     LastLoginDate = getdate()
        WHERE   @UserId = UserId

        IF( @@ERROR <> 0 )
            GOTO Cleanup

    RETURN 0

Cleanup:
    RETURN -1

END

GO
GRANT EXECUTE ON [dbo].[usp_Membership_UpdateUserInfo] TO [gatekeeper_role]
GO
