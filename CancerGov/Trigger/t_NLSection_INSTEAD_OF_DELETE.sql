IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[t_NLSection_INSTEAD_OF_DELETE]') AND OBJECTPROPERTY(id, N'IsTrigger') = 1)
EXEC dbo.sp_executesql @statement = N'BEGIN
	DELETE 	Original
	FROM	NLSection as Original, deleted as Old 	
	WHERE 	Original.NLSectionID = Old.NLSectionID

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
	SELECT ''DELETE'' as AuditActionType,
		tbl.NLSectionID, 
		tbl.Title,
		tbl.ShortTitle, 
		tbl.Description,
		tbl.HTMLBody,
		tbl.PlainBody,
		tbl.UpdateDate,
		tbl.UpdateUserID   
	FROM 	deleted tbl
END

' 
GO
