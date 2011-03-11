IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[t_ListOnDELETE]') AND OBJECTPROPERTY(id, N'IsTrigger') = 1)
EXEC dbo.sp_executesql @statement = N'BEGIN
	INSERT INTO AuditList(AuditActionType,
		ListID,
		GroupID,
		ListName,
		ListDesc,
		URL,
		ParentListID,
		NCIViewID,
		Priority,
		UpdateDate,
		UpdateUserID,
		DescDisplay,
		ReleaseDateDisplay,
		ReleaseDateDisplayLoc)
	SELECT ''DELETE'' as AuditActionType,
		tbl.ListID,
		tbl.GroupID,
		tbl.ListName,
		tbl.ListDesc,
		tbl.URL,
		tbl.ParentListID,
		tbl.NCIViewID,
		tbl.Priority,
		tbl.UpdateDate,
		tbl.UpdateUserID,
		tbl.DescDisplay,
		tbl.ReleaseDateDisplay,
		tbl.ReleaseDateDisplayLoc
	FROM 	deleted tbl
END

' 
GO
