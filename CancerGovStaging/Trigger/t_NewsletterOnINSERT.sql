IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[t_NewsletterOnINSERT]') AND OBJECTPROPERTY(id, N'IsTrigger') = 1)
EXEC dbo.sp_executesql @statement = N'BEGIN
	INSERT INTO AuditNewsletter
		(AuditActionType,
		NewsletterID,
		OwnerGroupID, 
		[Section],
		Title,
		[Description],
		[From],
		ReplyTo,
		CreateUserID,
		CreateDate,
		Status,
		UpdateDate,
		UpdateUserID ,
		qcemail     
		)
	SELECT ''INSERT'' as AuditActionType,
		tbl.NewsletterID,
		tbl.OwnerGroupID, 
		tbl.[Section],
		tbl.Title,
		tbl.[Description],
		tbl.[From],
		tbl.ReplyTo,
		tbl.CreateUserID,
		tbl.CreateDate,
		tbl.Status,
		tbl.UpdateDate,
		tbl.UpdateUserID,
		tbl.qcemail   
	FROM 	inserted tbl
END


' 
GO
