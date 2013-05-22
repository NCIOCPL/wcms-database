IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[t_NLSection_INSTEAD_OF_INSERT]') AND OBJECTPROPERTY(id, N'IsTrigger') = 1)
EXEC dbo.sp_executesql @statement = N'BEGIN
	INSERT INTO  NLSection
		(
		NLSectionID, 
		Title,
		ShortTitle, 
		Description,
		HTMLBody,
		PlainBody,
		UpdateDate,
		UpdateUserID      
		)
	Select 
		tbl.NLSectionID, 
		tbl.Title,
		tbl.ShortTitle, 
		tbl.Description,
		tbl.HTMLBody,
		tbl.PlainBody,
		tbl.UpdateDate,
		tbl.UpdateUserID   
	FROM 	inserted tbl

	INSERT INTO AuditNLSection
		(AuditActionType,
		NLSectionID, 
		Title,
		ShortTitle, 
		Description,
		HTMLBody,
		PlainBody,
		UpdateDate,
		UpdateUserID      
		)
	SELECT ''INSERT'' as AuditActionType,
		tbl.NLSectionID, 
		tbl.Title,
		tbl.ShortTitle, 
		tbl.Description,
		tbl.HTMLBody,
		tbl.PlainBody,
		tbl.UpdateDate,
		tbl.UpdateUserID   
	FROM 	inserted tbl
END
' 
GO
