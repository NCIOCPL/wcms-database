IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[t_usersubscriptionmapOnInsert]') AND OBJECTPROPERTY(id, N'IsTrigger') = 1)
EXEC dbo.sp_executesql @statement = N'BEGIN
	INSERT INTO Auditusersubscriptionmap
		(AuditActionType,
		NewsletterID,
		UserID,
		EmailFormat, 
		IsSubscribed,
		UnSubscribeDate,
		SubscriptionDate,
		KeywordList,
		UpdateDate,
		UpdateUserID,
		Priority
		)
	SELECT ''INSERT'' as AuditActionType,
		tbl.NewsletterID,
		tbl.UserID,
		tbl.EmailFormat, 
		tbl.IsSubscribed,
		tbl.UnSubscribeDate,
		tbl.SubscriptionDate,
		tbl.KeywordList,
		tbl.UpdateDate,
		tbl.UpdateUserID,
		tbl.Priority
	FROM 	inserted tbl
END

' 
GO
