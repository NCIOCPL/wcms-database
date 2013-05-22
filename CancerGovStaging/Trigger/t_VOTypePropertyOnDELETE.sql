IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[t_VOTypePropertyOnDELETE]') AND OBJECTPROPERTY(id, N'IsTrigger') = 1)
EXEC dbo.sp_executesql @statement = N'BEGIN
	INSERT INTO AuditViewObjectTypeProperty(AuditActionType,
		NCIObjectID,
		PropertyName,
		PropertyValue,
		Comments,
		Description,  
		IsDefaultValue, 
		UpdateUserID,   
		UpdateDate,     
		ValueType,      
		Editable )
	SELECT ''DELETE'' as AuditActionType,
		tbl.NCIObjectID,
		tbl.PropertyName,
		tbl.PropertyValue,
		tbl.Comments,     
		tbl.Description,  
		tbl.IsDefaultValue, 
		tbl.UpdateUserID,   
		tbl.UpdateDate,     
		tbl.ValueType,      
		tbl.Editable 
	FROM 	inserted tbl
END
' 
GO
