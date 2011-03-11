IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_Membership_SetPassword]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[usp_Membership_SetPassword]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].[usp_Membership_SetPassword]
    @UserName         nvarchar(256),
    @NewPassword      nvarchar(128)
AS
BEGIN
    DECLARE @UserId uniqueidentifier
    SELECT  @UserId = NULL
    SELECT  @UserId = UserId
    FROM    Users 
    WHERE   LOWER(UserName)  = LOWER(@UserName) 

    IF (@UserId IS NULL)
        RETURN(1)

    UPDATE dbo.Users
    SET Password = @NewPassword
    WHERE @UserId = UserId
    RETURN(0)
END

GO
GRANT EXECUTE ON [dbo].[usp_Membership_SetPassword] TO [gatekeeper_role]
GO
