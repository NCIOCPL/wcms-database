IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[t_ViewObjectsOnDELETE]') AND OBJECTPROPERTY(id, N'IsTrigger') = 1)
EXEC dbo.sp_executesql @statement = N'BEGIN
	INSERT INTO AuditViewObjects (AuditActionType,
		NCIViewObjectID,
		NCIViewID,
		ObjectID,
		Type,
		Priority,
		UpdateDate,
		UpdateUserID)
	SELECT ''DELETE'' as AuditActionType,
		tbl.NCIViewObjectID,
		tbl.NCIViewID,
		tbl.ObjectID,
		tbl.Type,
		tbl.Priority,
		tbl.UpdateDate,
		tbl.UpdateUserID
	FROM 	deleted tbl
END

' 
GO
