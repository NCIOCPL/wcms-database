IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_Membership_UpdateUser]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[usp_Membership_UpdateUser]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].[usp_Membership_UpdateUser]
    @UserName             nvarchar(256),
    @Email                nvarchar(256),
    @LastLoginDate        datetime,
    @UniqueEmail          int
AS
BEGIN
    DECLARE @UserId uniqueidentifier

    SELECT  @UserId = NULL
    SELECT  @UserId = UserId
    FROM    dbo.Users
    WHERE   LOWER(UserName) = LOWER(@UserName) 

    IF (@UserId IS NULL)
        RETURN(1)

    IF (@UniqueEmail = 1)
    BEGIN
        IF (EXISTS (SELECT *
                    FROM  dbo.Users WITH (UPDLOCK, HOLDLOCK)
                    WHERE @UserId <> UserId AND LOWER(Email) = LOWER(@Email)))
        BEGIN
            RETURN(7)
        END
    END

    UPDATE dbo.Users WITH (ROWLOCK)
    SET
         Email            = @Email,
         LastLoginDate    = @LastLoginDate
    WHERE
       @UserId = UserId

    IF( @@ERROR <> 0 )
        GOTO Cleanup

 

    RETURN 0

Cleanup:
    RETURN -1
END

GO
GRANT EXECUTE ON [dbo].[usp_Membership_UpdateUser] TO [gatekeeper_role]
GO
