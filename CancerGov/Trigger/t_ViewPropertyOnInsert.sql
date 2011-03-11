IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[t_ViewPropertyOnInsert]') AND OBJECTPROPERTY(id, N'IsTrigger') = 1)
EXEC dbo.sp_executesql @statement = N'BEGIN
	INSERT INTO AuditViewProperty(AuditActionType,
		AuditActionDate,
		AuditActionUserID,
		ViewPropertyID,
		NCIViewID,
		PropertyName,
		PropertyValue,
		UpdateDate,
		UpdateUserID)
	SELECT ''INSERT'' as AuditActionType,
		GETDATE() AS AuditActionDate,
		user_name() AS AuditActionUserID,
		tbl.ViewPropertyID,
		tbl.NCIViewID,
		tbl.PropertyName,
		tbl.PropertyValue,
		tbl.UpdateDate,
		tbl.UpdateUserID
	FROM 	inserted tbl
END
' 
GO
