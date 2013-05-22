IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[t_ViewObjectsOnInsert]') AND OBJECTPROPERTY(id, N'IsTrigger') = 1)
EXEC dbo.sp_executesql @statement = N'BEGIN
	INSERT INTO AuditViewObjects (AuditActionType,
		NCIViewObjectID,
		NCIViewID,
		ObjectID,
		Type,
		Priority,
		UpdateDate,
		UpdateUserID)
	SELECT ''INSERT'' as AuditActionType,
		tbl.NCIViewObjectID,
		tbl.NCIViewID,
		tbl.ObjectID,
		tbl.Type,
		tbl.Priority,		
		tbl.UpdateDate,
		tbl.UpdateUserID
	FROM 	inserted tbl
END

' 
GO
