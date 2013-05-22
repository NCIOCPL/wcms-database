IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[t_PermissionsOnInsert]') AND OBJECTPROPERTY(id, N'IsTrigger') = 1)
EXEC dbo.sp_executesql @statement = N'BEGIN	
	INSERT INTO AuditPermissions(AuditActionType,
		permissionID,
		permissionName,
		permssionDescription,
		creationDate,
		creationUser,
		UpdateDate,
		UpdateUserID)
	SELECT ''INSERT'' as AuditActionType,
		ins.permissionID,
		ins.permissionName,
		ins.permssionDescription,
		ins.creationDate,
		ins.creationUser,
		ins.UpdateDate,
		ins.UpdateUserID
	FROM 	inserted ins
END
' 
GO
