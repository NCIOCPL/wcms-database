IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[t_DocumentINSTEAD_OF_UPDATE]') AND OBJECTPROPERTY(id, N'IsTrigger') = 1)
EXEC dbo.sp_executesql @statement = N'BEGIN
	--First we update Original Document
	UPDATE Original
	SET 	
		Original.DocumentID = 	New.DocumentID,
		Original.Title = 	New.Title,
		Original.ShortTitle = 	New.ShortTitle,
		Original.[Description] = New.[Description],
		Original.GroupID = 	New.GroupID,
		Original.DataType = 	New.DataType,
		Original.DataSize = 	New.DataSize,
		Original.IsWirelessPage = New.IsWirelessPage,
		Original.TOC = 		New.TOC,
		Original.Data = 	New.Data,
		Original.CreateDate = 	New.CreateDate,
		Original.PostedDate = New.PostedDate,
		Original.ReleaseDate = 	New.ReleaseDate,
		Original.ExpirationDate = New.ExpirationDate,
		Original.DisplayDateMode = New.DisplayDateMode,
		Original.UpdateDate 	= GETDATE(),	
		Original.UpdateUserID = New.UpdateUserID
	FROM	Document as Original, inserted as New 	
	WHERE 	Original.DocumentID = New.DocumentID

	--Then we log information in to the DocumentAudit table
	INSERT INTO AuditDocument (
		AuditActionType,
		DocumentID,
		Title,
		ShortTitle,
		Description,
		GroupID,
		DataType,
		DataSize,
		IsWirelessPage,
		TOC,
		Data,
		CreateDate,
		PostedDate,
		ReleaseDate,
		ExpirationDate,
		DisplayDateMode,
		UpdateDate,
		UpdateUserID)	
	SELECT 
		''UPDATE'' as AuditActionType,
		ins.DocumentID,
		ins.Title,
		ins.ShortTitle,
		ins.Description,
		ins.GroupID,
		ins.DataType,
		ins.DataSize,
		ins.IsWirelessPage,
		ins.TOC,
		ins.Data,
		ins.CreateDate,
		ins.PostedDate,
		ins.ReleaseDate,
		ins.ExpirationDate,
		ins.DisplayDateMode,
		ins.UpdateDate,
		ins.UpdateUserID
	FROM 	inserted ins
END


' 
GO
