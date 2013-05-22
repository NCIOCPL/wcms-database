IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[t_PermissionsOnDelete]') AND OBJECTPROPERTY(id, N'IsTrigger') = 1)
EXEC dbo.sp_executesql @statement = N'BEGIN	
	INSERT INTO AuditPermissions(AuditActionType,
		permissionID,
		permissionName,
		permssionDescription,
		creationDate,
		creationUser,
		UpdateDate,
		UpdateUserID)
	SELECT ''DELETE'' as AuditActionType,
		del.permissionID,
		del.permissionName,
		del.permssionDescription,
		del.creationDate,
		del.creationUser,
		del.UpdateDate,
		del.UpdateUserID
	FROM 	deleted del
END
' 
GO
