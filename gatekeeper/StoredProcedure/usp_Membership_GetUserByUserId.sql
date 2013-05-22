IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_Membership_GetUserByUserId]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[usp_Membership_GetUserByUserId]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].[usp_Membership_GetUserByUserId]
    @UserId               uniqueidentifier
AS
BEGIN
   

   SELECT Email, PasswordQuestion, CreateDate, LastLoginDate, UserName
    FROM    Users 
    WHERE   @UserId = UserId 
    IF ( @@ROWCOUNT = 0 ) -- User ID not found
       RETURN -1

    RETURN 0
END

GO
GRANT EXECUTE ON [dbo].[usp_Membership_GetUserByUserId] TO [gatekeeper_role]
GO
