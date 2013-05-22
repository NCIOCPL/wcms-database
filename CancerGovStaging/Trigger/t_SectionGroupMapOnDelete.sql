IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[t_SectionGroupMapOnDelete]') AND OBJECTPROPERTY(id, N'IsTrigger') = 1)
EXEC dbo.sp_executesql @statement = N'BEGIN
	INSERT INTO AuditSectionGroupMap (AuditActionType,
	  	SectionID,
		GroupID,
		CreateDate,
		UpdateUserID,                                       
		UpdateDate  )
	SELECT ''DELETE'' as AuditActionType,
		ins.SectionID,
		ins.GroupID,
		ins.CreateDate,
		ins.UpdateUserID,                                       
		ins.UpdateDate
	FROM 	deleted ins
END

' 
GO
