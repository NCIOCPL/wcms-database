IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[t_NCISectionOnDELETE]') AND OBJECTPROPERTY(id, N'IsTrigger') = 1)
EXEC dbo.sp_executesql @statement = N'BEGIN
	INSERT INTO AuditNCISection(AuditActionType,
		NCISectionID,
		SectionHomeViewID,
		Name,
		URL,
		Description,
		UpdateDate,
		UpdateUserID)		
	SELECT ''DELETE'' as AuditActionType,
		tbl.NCISectionID,
		tbl.SectionHomeViewID,
		tbl.Name,
		tbl.URL,
		tbl.Description,
		tbl.UpdateDate,
		tbl.UpdateUserID		
	FROM 	deleted tbl
END


' 
GO
