IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[t_NCITemplateOnInsert]') AND OBJECTPROPERTY(id, N'IsTrigger') = 1)
EXEC dbo.sp_executesql @statement = N'BEGIN
	INSERT INTO AuditNCITemplate( AuditActionType,  NCITemplateID, Name, 
					URL, Description, UpdateDate, UpdateUserID, AddURL, EditURL)
	SELECT 	''INSERT'' as AuditActionType,
		ins.NCITemplateID,
		ins.Name,
		ins.URL,
		ins.Description,
		ins.UpdateDate,
		ins.UpdateUserID,
                           ins.AddURL,
                           ins.EditURL
	FROM 	inserted ins
END
' 
GO
