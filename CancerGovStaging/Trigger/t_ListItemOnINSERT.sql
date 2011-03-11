IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[t_ListItemOnINSERT]') AND OBJECTPROPERTY(id, N'IsTrigger') = 1)
EXEC dbo.sp_executesql @statement = N'BEGIN
	INSERT INTO AuditListItem (AuditActionType,
		ListID,
		NCIViewID,
		Priority,
		IsFeatured,
		UpdateDate,
		UpdateUserID)
	SELECT ''INSERT'' as AuditActionType,
		tbl.ListID,
		tbl.NCIViewID,
		tbl.Priority,
		tbl.IsFeatured,
		tbl.UpdateDate,
		tbl.UpdateUserID
	FROM 	inserted tbl
END
' 
GO
