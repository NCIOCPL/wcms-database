IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[t_DocumentINSTEAD_OF_INSERT]') AND OBJECTPROPERTY(id, N'IsTrigger') = 1)
EXEC dbo.sp_executesql @statement = N'BEGIN
	--First Inser the Document
	INSERT INTO Document (
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
		ReleaseDate,
		ExpirationDate,
		PostedDate,
		DisplayDateMode,
		UpdateDate,
		UpdateUserID)	
	SELECT 
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
		ins.ReleaseDate,
		ins.ExpirationDate,
		ins.PostedDate,
		ins.DisplayDateMode,
		ins.UpdateDate,
		ins.UpdateUserID
	FROM 	inserted ins


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
		ReleaseDate,
		ExpirationDate,
		PostedDate,
		DisplayDateMode,
		UpdateDate,
		UpdateUserID)	
	SELECT 
		''INSERT'' as AuditActionType,
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
		ins.ReleaseDate,
		ins.ExpirationDate,
		ins.PostedDate,
		ins.DisplayDateMode,
		ins.UpdateDate,
		ins.UpdateUserID
	FROM 	inserted ins
END

' 
GO
