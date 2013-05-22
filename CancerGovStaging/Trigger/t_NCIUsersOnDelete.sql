IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[t_NCIUsersOnDelete]') AND OBJECTPROPERTY(id, N'IsTrigger') = 1)
EXEC dbo.sp_executesql @statement = N'BEGIN
	INSERT INTO AuditNCIUsers(
		AuditActionType,
		userID,
		loginName,
		email,
		[password],
		lastVisit,
		secontToLastVist,
		nSessions,
		registrationDate,
		PasswordLastUpdated,
		UpdateDate,
		UpdateUserID)
	SELECT 	''DELETE'' as AuditActionType,
		del.userID,
		del.loginName,
		del.email,
		del.[password],
		del.lastVisit,
		del.secontToLastVist,
		del.nSessions,
		del.registrationDate,
		del.PasswordLastUpdated,
		del.UpdateDate,
		del.UpdateUserID
	FROM 	deleted del
END

' 
GO
