IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[t_GroupsOnUpdate]') AND OBJECTPROPERTY(id, N'IsTrigger') = 1)
EXEC dbo.sp_executesql @statement = N'BEGIN
	INSERT INTO AuditGroups (AuditActionType,
		groupID,
		typeID,
		parentGroupId,
		groupIDName,
		groupName,
		adminEmail,
		creationDate,
		creationUser,
		isActive,
		UpdateDate,
		UpdateUserID)
	SELECT ''UPDATE'' as AuditActionType,
		ins.groupID,
		ins.typeID,
		ins.parentGroupId,
		ins.groupIDName,
		ins.groupName,
		ins.adminEmail,
		ins.creationDate,
		ins.creationUser,
		ins.isActive,
		ins.UpdateDate,
		ins.UpdateUserID
	FROM 	inserted ins
END
' 
GO
