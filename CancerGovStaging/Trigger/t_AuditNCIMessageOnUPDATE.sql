IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[t_AuditNCIMessageOnUPDATE]') AND OBJECTPROPERTY(id, N'IsTrigger') = 1)
EXEC dbo.sp_executesql @statement = N'BEGIN
	INSERT INTO AuditNCIMessage(
		AuditActionType,
		MessageID,                            
		SenderID ,                            
		RecipientID,                          
		Subject,                                                                                                                                                                                                                                                         
		Message ,                                                                                                                                                                                                                                                         
		Status,     
		SendDate,                                               
		DeleteDate,                                             
		UpdateDate,
		UpdateUserID) 
	SELECT ''UPDATE'' as AuditActionType,
		tbl.MessageID,                            
		tbl.SenderID ,                            
		tbl.RecipientID,                          
		tbl.Subject,                                                                                                                                                                                                                                                         
		tbl.Message ,                                                                                                                                                                                                                                                         
		tbl.Status,     
		tbl.SendDate,                                               
		tbl.DeleteDate,                                             
		tbl.UpdateDate,
		tbl.UpdateUserID
	FROM 	inserted  tbl
END

' 
GO
