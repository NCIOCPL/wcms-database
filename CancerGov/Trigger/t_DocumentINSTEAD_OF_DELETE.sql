IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[t_DocumentINSTEAD_OF_DELETE]') AND OBJECTPROPERTY(id, N'IsTrigger') = 1)
EXEC dbo.sp_executesql @statement = N'BEGIN
	DELETE 	Original
	FROM	Document as Original, deleted as Old 	
	WHERE 	Original.DocumentID = Old.DocumentID

	INSERT INTO AuditDocument (
		AuditActionType,
		DocumentID,
		Title,
		ShortTitle,
		[Description],
		GroupID,
		DataType,
		DataSize,
		IsWirelessPage,
		TOC,
		Data,
		CreateDate,
		ReleaseDate,
		ExpirationDate,
		PostedDate,
		DisplayDateMode,
		UpdateDate,
		UpdateUserID)	
	SELECT 
		''DELETE'' as AuditActionType,
		del.DocumentID,
		del.Title,
		del.ShortTitle,
		del.[Description],
		del.GroupID,
		del.DataType,
		del.DataSize,
		del.IsWirelessPage,
		del.TOC,
		del.Data,
		del.CreateDate,
		del.ReleaseDate,
		del.ExpirationDate,
		del.PostedDate,
		del.DisplayDateMode,
		del.UpdateDate,
		del.UpdateUserID
	FROM 	deleted del
END

' 
GO
