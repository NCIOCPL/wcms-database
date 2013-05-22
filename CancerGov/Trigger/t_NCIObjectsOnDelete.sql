IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[t_NCIObjectsOnDelete]') AND OBJECTPROPERTY(id, N'IsTrigger') = 1)
EXEC dbo.sp_executesql @statement = N'BEGIN
	INSERT INTO AuditNCIObjects
		(AuditActionType,
		ObjectInstanceID,
		NCIObjectID,
		ParentNCIObjectID,
		ObjectType,
		Priority,
		UpdateDate,
		UpdateUserID
		)
	SELECT ''DELETE'' as AuditActionType,
		tbl.ObjectInstanceID,
		tbl.NCIObjectID,
		tbl.ParentNCIObjectID,
		tbl.ObjectType,
		tbl.Priority,
		tbl.UpdateDate,
		tbl.UpdateUserID   
	FROM 	deleted tbl
END

' 
GO
