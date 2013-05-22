IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[t_NLissueOnUpdate]') AND OBJECTPROPERTY(id, N'IsTrigger') = 1)
EXEC dbo.sp_executesql @statement = N'BEGIN
	INSERT INTO AuditNLissue
		(AuditActionType,
		NewsletterID,
		NCIViewID,
		Priority,
		Status,    
		IssueType,
		SendDate,
		UpdateUserID,
		UpdateDate  
		)
	SELECT ''UPDATE'' as AuditActionType,
		tbl.NewsletterID,
		tbl.NCIViewID,
		tbl.Priority,
		tbl.Status,    
		tbl.IssueType,
		tbl.SendDate,
		tbl.UpdateUserID,
		tbl.UpdateDate  
	FROM 	inserted tbl
END



' 
GO
