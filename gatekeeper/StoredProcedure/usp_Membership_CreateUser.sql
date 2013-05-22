IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_Membership_CreateUser]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[usp_Membership_CreateUser]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].[usp_Membership_CreateUser]
    @UserName                               nvarchar(256),
    @Password                               nvarchar(128),
    @Email                                  nvarchar(256),
    @PasswordQuestion                       nvarchar(256),
    @PasswordAnswer                         nvarchar(128),
    @CreateDate                             datetime = NULL,
    @UniqueEmail                            int      = 0,
    @UserID                                 uniqueidentifier OUTPUT
AS
BEGIN
    DECLARE @NewUserId uniqueidentifier

    DECLARE @ErrorCode     int
    SET @ErrorCode = 0

    SET @CreateDate = Getdate()

	--Check whether user exists
    IF ( EXISTS ( SELECT UserId
                  FROM   dbo.Users WHERE LOWER(UserName) = LOWER(@UserName)  ) )
    BEGIN
        SET @ErrorCode = 6
        GOTO Cleanup
    END

	-- check whether email exists
    IF (@UniqueEmail = 1)
    BEGIN
        IF (EXISTS (SELECT *
                    FROM  dbo.Users 
                    WHERE LOWER(Email) = LOWER(@Email)))
        BEGIN
            SET @ErrorCode = 7
            GOTO Cleanup
        END
    END

    SELECT @UserID = newid()

    INSERT INTO dbo.Users
                ( UserId,
                  Password,
                  Email,
                  PasswordQuestion,
                  PasswordAnswer,
                  CreateDate,
                  LastLoginDate,
                  UserName)
         VALUES ( @UserID,
                  @Password,
                  @Email,
	              @PasswordQuestion,
                  @PasswordAnswer,
                  @CreateDate,
                  @CreateDate,
                  @UserName )

    IF( @@ERROR <> 0 )
    BEGIN
        SET @ErrorCode = -1
        GOTO Cleanup
    END

    RETURN 0

Cleanup:
    RETURN @ErrorCode

END

GO
GRANT EXECUTE ON [dbo].[usp_Membership_CreateUser] TO [gatekeeper_role]
GO
