IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[t_HeaderINSTEAD_OF_INSERT]') AND OBJECTPROPERTY(id, N'IsTrigger') = 1)
EXEC dbo.sp_executesql @statement = N'BEGIN
	INSERT into HEADER (
		[HeaderId],
		[Name],
		[ContentType],
		[Data],
		[Type],
		[UpdateUserID],
		[UpdateDate]) 
	SELECT 	ins.[HeaderId],
		ins.[Name],
		ins.[ContentType],
		ins.[Data],
		ins.[Type],
		ins.[UpdateUserID],
		ins.[UpdateDate]
	FROM 	inserted ins

	INSERT INTO AuditHeader (AuditActionType,
		[HeaderId],
		[Name],
		[ContentType],
		[Data],
		[Type],
		[UpdateUserID],
		[UpdateDate]) 
	SELECT ''INSERT'' as AuditActionType,
		tbl.[HeaderId],
		tbl.[Name],
		tbl.[ContentType],
		tbl.[Data],
		tbl.[Type],
		tbl.[UpdateUserID],
		tbl.[UpdateDate]
	FROM 	inserted tbl
END


' 
GO
