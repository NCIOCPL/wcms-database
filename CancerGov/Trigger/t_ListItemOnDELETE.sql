IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[t_ListItemOnDELETE]') AND OBJECTPROPERTY(id, N'IsTrigger') = 1)
EXEC dbo.sp_executesql @statement = N'BEGIN
	INSERT INTO AuditListItem (AuditActionType,
		ListID,
		NCIViewID,
		Priority,
		IsFeatured,
		UpdateDate,
		UpdateUserID)
	SELECT ''DELETE'' as AuditActionType,
		tbl.ListID,
		tbl.NCIViewID,
		tbl.Priority,
		tbl.IsFeatured,
		tbl.UpdateDate,
		tbl.UpdateUserID
	FROM 	deleted tbl
END
' 
GO
