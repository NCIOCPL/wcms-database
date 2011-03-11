IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_Membership_GetAllUsers]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[usp_Membership_GetAllUsers]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].[usp_Membership_GetAllUsers]
    @PageIndex             int,
    @PageSize              int
AS
BEGIN
    -- Set the page bounds
    DECLARE @PageLowerBound int
    DECLARE @PageUpperBound int
    DECLARE @TotalRecords   int
    SET @PageLowerBound = @PageSize * @PageIndex
    SET @PageUpperBound = @PageSize - 1 + @PageLowerBound

    -- Create a temp table TO store the select results
    CREATE TABLE #PageIndexForUsers
    (
        IndexId int IDENTITY (0, 1) NOT NULL,
        UserId uniqueidentifier
    )

    -- Insert into our temp table
    INSERT INTO #PageIndexForUsers (UserId)
    SELECT UserId
    FROM   dbo.Users
    ORDER BY UserName

    SELECT @TotalRecords = @@ROWCOUNT

    SELECT	UserName,
			Email,
			PasswordQuestion, 
            CreateDate,
            LastLoginDate,
            u.UserId
    FROM   dbo.Users u, #PageIndexForUsers p
    WHERE  u.UserId = p.UserId AND
           p.IndexId >= @PageLowerBound AND p.IndexId <= @PageUpperBound
    ORDER BY u.UserName
    RETURN @TotalRecords
END

GO
GRANT EXECUTE ON [dbo].[usp_Membership_GetAllUsers] TO [gatekeeper_role]
GO
