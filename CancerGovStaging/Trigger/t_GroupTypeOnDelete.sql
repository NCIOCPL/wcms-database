IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[t_GroupTypeOnDelete]') AND OBJECTPROPERTY(id, N'IsTrigger') = 1)
EXEC dbo.sp_executesql @statement = N'BEGIN
	INSERT INTO AuditGroupTypes (AuditActionType,
		typeID,	
		typeName,	
		UpdateDate,	
		UpdateUserID)
	SELECT ''DELETE'' as AuditActionType,
		tbl.typeID,	
		tbl.typeName,	
		tbl.UpdateDate,	
		tbl.UpdateUserID
	FROM 	deleted tbl
END
' 
GO
