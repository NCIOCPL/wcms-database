IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[t_ImageOnInsert]') AND OBJECTPROPERTY(id, N'IsTrigger') = 1)
EXEC dbo.sp_executesql @statement = N'BEGIN
	INSERT INTO AuditImage(AuditActionType,
		[ImageID],
		[ImageName],
		[ImageSource],
		[ImageAltText],
		[TextSource],
		[Url],
		[Width],
		[Height],
		[Border],
		[UpdateDate],
		[UpdateUserID])
	SELECT ''INSERT'' as AuditActionType,
		tbl.[ImageID],
		tbl.[ImageName],
		tbl.[ImageSource],
		tbl.[ImageAltText],
		tbl.[TextSource],
		tbl.[Url],
		tbl.[Width],
		tbl.[Height],
		tbl.[Border],
		tbl.[UpdateDate],
		tbl.[UpdateUserID]
	FROM 	inserted tbl
END

' 
GO
