IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[t_ViewObjectPropertyOnUPDATE]') AND OBJECTPROPERTY(id, N'IsTrigger') = 1)
EXEC dbo.sp_executesql @statement = N'BEGIN
	INSERT INTO AuditViewObjectProperty(AuditActionType,
		NCIViewObjectID,
		PropertyName,
		PropertyValue,
		UpdateDate,
		UpdateUserID)
	SELECT ''UPDATE'' as AuditActionType,
		tbl.NCIViewObjectID,
		tbl.PropertyName,
		tbl.PropertyValue,
		tbl.UpdateDate,
		tbl.UpdateUserID
	FROM 	inserted tbl
END
' 
GO
