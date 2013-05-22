IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[t_NLSection_INSTEAD_OF_UPDATE]') AND OBJECTPROPERTY(id, N'IsTrigger') = 1)
EXEC dbo.sp_executesql @statement = N'BEGIN
	UPDATE Original
	SET	
		Original.Title		= New.Title,
		Original.ShortTitle	= New.ShortTitle, 
		Original.Description	= New.Description,
		Original.HTMLBody	= New.HTMLBody,
		Original.PlainBody	= New.PlainBody,
		Original.UpdateDate 	= New.UpdateDate,
		Original.UpdateUserID 	= New.UpdateUserID
	FROM	NLSection as Original, 
		inserted as New 	
	WHERE  Original.NLSectionID	= New.NLSectionID  

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
	SELECT ''UPDATE'' as AuditActionType,
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
