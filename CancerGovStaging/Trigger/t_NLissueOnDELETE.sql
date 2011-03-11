IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[t_NLissueOnDELETE]') AND OBJECTPROPERTY(id, N'IsTrigger') = 1)
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
	SELECT ''DELETE'' as AuditActionType,
		tbl.NewsletterID,
		tbl.NCIViewID,
		tbl.Priority,
		tbl.Status,    
		tbl.IssueType,
		tbl.SendDate,
		tbl.UpdateUserID,
		tbl.UpdateDate  
	FROM 	deleted tbl
END









' 
GO
