IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[t_NCIUsersOnUpdate]') AND OBJECTPROPERTY(id, N'IsTrigger') = 1)
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
	SELECT 	''UPDATE'' as AuditActionType,
		ins.userID,
		ins.loginName,
		ins.email,
		ins.[password],
		ins.lastVisit,
		ins.secontToLastVist,
		ins.nSessions,
		ins.registrationDate,
		ins.PasswordLastUpdated,
		ins.UpdateDate,
		ins.UpdateUserID
	FROM 	inserted ins
END

' 
GO
