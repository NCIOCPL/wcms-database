IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[t_TaskOnUPDATE]') AND OBJECTPROPERTY(id, N'IsTrigger') = 1)
EXEC dbo.sp_executesql @statement = N'BEGIN
	INSERT INTO AuditTask(AuditActionType,
		[TaskID],
		[ResponsibleGroupID],
		[Name],
		[Status],
		[Notes],
		[Importance],
		[ObjectID],
		[UpdateDate],
		[UpdateUserID]	)
	SELECT ''UPDATE'' as AuditActionType,
		tbl.[TaskID],
		tbl.[ResponsibleGroupID],
		tbl.[Name],
		tbl.[Status],
		tbl.[Notes],
		tbl.[Importance],
		tbl.[ObjectID],
		tbl.[UpdateDate],
		tbl.[UpdateUserID]
	FROM 	inserted tbl
END
' 
GO
