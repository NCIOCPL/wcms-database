IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[t_HeaderINSTEAD_OF_DELETE]') AND OBJECTPROPERTY(id, N'IsTrigger') = 1)
EXEC dbo.sp_executesql @statement = N'BEGIN
	DELETE 	Original
	FROM	Header as Original, deleted as Old 	
	WHERE 	Original.HeaderID = Old.HeaderID

	INSERT INTO AuditHeader (AuditActionType,
		[HeaderId],
		[Name],
		[Data],
		[ContentType],
		[Type],
		[UpdateUserID],
		[UpdateDate]) 
	SELECT ''DELETE'' as AuditActionType,
		tbl.[HeaderId],
		tbl.[Name],
		tbl.[Data],
		tbl.[ContentType],
		tbl.[Type],
		tbl.[UpdateUserID],
		tbl.[UpdateDate]
	FROM 	deleted tbl
END



' 
GO
