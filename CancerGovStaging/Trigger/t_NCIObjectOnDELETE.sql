IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[t_NCIObjectOnDELETE]') AND OBJECTPROPERTY(id, N'IsTrigger') = 1)
EXEC dbo.sp_executesql @statement = N'BEGIN
	INSERT INTO AuditNCIObject (AuditActionType,
		NCIObjectID,
		Name,
		TableName,
		Description,
		UpdateUserID,
		UpdateDate  )
	SELECT ''DELETE'' as AuditActionType,
		tbl.NCIObjectID,
		tbl.Name,
		tbl.TableName,
		tbl.Description,
		tbl.UpdateUserID,
		tbl.UpdateDate 
	FROM 	inserted tbl
END



' 
GO
