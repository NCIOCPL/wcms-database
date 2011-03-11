IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[t_NCITemplateOnDelete]') AND OBJECTPROPERTY(id, N'IsTrigger') = 1)
EXEC dbo.sp_executesql @statement = N'BEGIN
	INSERT INTO AuditNCITemplate( AuditActionType,  NCITemplateID, Name, 
					URL, Description, UpdateDate, UpdateUserID, AddURL, EditURL)
	SELECT  ''DELETE'' as AuditActionType,
		del.NCITemplateID,
		del.Name,
		del.URL,
		del.Description,
		del.UpdateDate,
		del.UpdateUserID,
                           del.AddURL,
                           del.EditURL
	FROM 	deleted del
END
' 
GO
