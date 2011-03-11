IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[t_UserGroupPermissionMapOnInsert]') AND OBJECTPROPERTY(id, N'IsTrigger') = 1)
EXEC dbo.sp_executesql @statement = N'BEGIN
	INSERT INTO AuditUserGroupPermissionMap(AuditActionType,
		userID,
		groupID,
		permissionID,
		creationDate,
		creationUser,
		UpdateDate,
		UpdateUserID)
	SELECT ''INSERT'' as AuditActionType,
		tbl.userID,
		tbl.groupID,
		tbl.permissionID,
		tbl.creationDate,
		tbl.creationUser,
		tbl.UpdateDate,
		tbl.UpdateUserID
	FROM 	inserted tbl
END
' 
GO
