IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[t_NLKeywordOnUPDATE]') AND OBJECTPROPERTY(id, N'IsTrigger') = 1)
EXEC dbo.sp_executesql @statement = N'BEGIN
	INSERT INTO AuditNLKeyword
		(AuditActionType,
		KeywordID,  
		NewsletterID,
		Keyword,
		UpdateDate,
		UpdateUserID      
		)
	SELECT ''UPDATE'' as AuditActionType,
		tbl.KeywordID,  
		tbl.NewsletterID,
		tbl.Keyword,
		tbl.UpdateDate,
		tbl.UpdateUserID   
	FROM 	inserted tbl
END


' 
GO
