IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[t_NCIObjectPropertyOnINSERT]') AND OBJECTPROPERTY(id, N'IsTrigger') = 1)
EXEC dbo.sp_executesql @statement = N'BEGIN
	INSERT INTO AuditNCIObjectProperty
		(AuditActionType,
		ObjectInstanceID,
		PropertyName,
		PropertyValue,
		UpdateDate,
		UpdateUserID
		)
	SELECT ''INSERT'' as AuditActionType,
		tbl.ObjectInstanceID,
		tbl.PropertyName,
		tbl.PropertyValue,
		tbl.UpdateDate,
		tbl.UpdateUserID   
	FROM 	inserted tbl
END




' 
GO
