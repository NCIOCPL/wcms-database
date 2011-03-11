IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[t_SectionDirectoryMapOnDelete]') AND OBJECTPROPERTY(id, N'IsTrigger') = 1)
EXEC dbo.sp_executesql @statement = N'BEGIN
	INSERT INTO AuditSectionDirectoryMap (
		AuditActionType,
	  	SectionID,
		DirectoryID,
		UpdateUserID,                                       
		UpdateDate  )
	SELECT ''DELETE'' as AuditActionType,
		ins.SectionID,
		ins.DirectoryID, 
		ins.UpdateUserID,                                       
		ins.UpdateDate
	FROM 	deleted ins
END
' 
GO
