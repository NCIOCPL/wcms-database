IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].Core_Function_FilterCMSUsers') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT')) 
DROP FUNCTION [dbo].Core_Function_FilterCMSUsers
GO

/*******************************************************
* Purpose: Gets a list of userids that match the criteria
* Params: 
*	@UserIDList -- a comma separated list of uniqueidentifiers that represents the set of userIDs to 
*		search in, or remove from the users to search
*	@ActiveStatus -- If 1 we only return active users, if 0 we return disabled users, if null both
*	@FilterOnAuth -- Only Get users of a certain auth type.  0 will get all
*	@ExcludeTheIDs -- If 1 then the UserIDList will be an exclusion list, if 0 then the we search through
*		only the users that are in that list
********************************************************/
CREATE FUNCTION dbo.Core_Function_FilterCMSUsers 
(
	@UserIDList varchar(max) = '',
	@ActiveStatus bit = null,
	@FilterOnAuth int = 0,
	@ExcludeTheIDs bit = 0
)
RETURNS @IDList TABLE 
	(UserID uniqueidentifier)
AS
BEGIN

	IF (@UserIDList IS NULL OR @UserIDList = '')
		INSERT INTO @IDList
		(UserID)
		SELECT UserID
		FROM [User]		
		WHERE (@ActiveStatus is null OR IsActive = @ActiveStatus)		
		AND (@FilterOnAuth = 0 OR UserID in (
				SELECT DISTINCT UserID
				FROM UserAuthMap
				WHERE AuthenticationTypeID = @FilterOnAuth)
		)
	ELSE
		IF (@ExcludeTheIDs is not null AND @ExcludeTheIDs = 1)
			INSERT INTO @IDList
			(UserID)
			SELECT UserID
			FROM [User]
			WHERE UserID not in ( 
				SELECT Item
				FROM udf_ListToGuidTest(@UserIDList, ',')
			)
			AND (@ActiveStatus is null OR IsActive = @ActiveStatus)
			AND (@FilterOnAuth = 0 OR UserID in (
					SELECT DISTINCT UserID
					FROM UserAuthMap
					WHERE AuthenticationTypeID = @FilterOnAuth)
			)

		ELSE
			INSERT INTO @IDList
			(UserID)
			SELECT UserID
			FROM [User]
			WHERE UserID in ( 
				SELECT Item
				FROM udf_ListToGuidTest(@UserIDList, ',')
			)			
			AND (@ActiveStatus is null OR IsActive = @ActiveStatus)
			AND (@FilterOnAuth = 0 OR UserID in (
					SELECT DISTINCT UserID
					FROM UserAuthMap
					WHERE AuthenticationTypeID = @FilterOnAuth)
			)

	RETURN
		
END


