IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_Membership_ChangePasswordQuestionAndAnswer]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[usp_Membership_ChangePasswordQuestionAndAnswer]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].[usp_Membership_ChangePasswordQuestionAndAnswer]
    @UserName              nvarchar(256),
    @NewPasswordQuestion   nvarchar(256),
    @NewPasswordAnswer     nvarchar(128)
AS
BEGIN
    DECLARE @UserId uniqueidentifier
    SELECT  @UserId = NULL
    SELECT  @UserId = UserId
    FROM    dbo.Users 
    WHERE   LOWER(UserName) = LOWER(@UserName) 

    IF (@UserId IS NULL)
    BEGIN
        RETURN(1)
    END

    UPDATE dbo.Users
    SET    PasswordQuestion = @NewPasswordQuestion, 
		   PasswordAnswer = @NewPasswordAnswer
    WHERE  UserId=@UserId
    RETURN(0)
END

GO
GRANT EXECUTE ON [dbo].[usp_Membership_ChangePasswordQuestionAndAnswer] TO [gatekeeper_role]
GO
