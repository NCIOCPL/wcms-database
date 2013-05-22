IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[t_NCIObjectPropertyOnDelete]') AND OBJECTPROPERTY(id, N'IsTrigger') = 1)
EXEC dbo.sp_executesql @statement = N'BEGIN
	INSERT INTO AuditNCIObjectProperty
		(AuditActionType,
		ObjectInstanceID,
		PropertyName,
		PropertyValue,
		UpdateDate,
		UpdateUserID
		)
	SELECT ''DELETE'' as AuditActionType,
		tbl.ObjectInstanceID,
		tbl.PropertyName,
		tbl.PropertyValue,
		tbl.UpdateDate,
		tbl.UpdateUserID   
	FROM 	deleted tbl
END



' 
GO
