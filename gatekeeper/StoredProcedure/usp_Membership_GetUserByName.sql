IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_Membership_GetUserByName]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[usp_Membership_GetUserByName]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].[usp_Membership_GetUserByName]
    @UserName             nvarchar(256)
AS
BEGIN
    DECLARE @UserId uniqueidentifier

    
    SELECT Email, PasswordQuestion, CreateDate, LastLoginDate, UserId
    FROM    Users 
    WHERE    LOWER(UserName) =LOWER(@UserName)

    IF ( @@ROWCOUNT = 0 ) -- User ID not found
       RETURN -1

    RETURN 0
END

GO
GRANT EXECUTE ON [dbo].[usp_Membership_GetUserByName] TO [gatekeeper_role]
GO
