IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[t_DirectoriesOnUpdate]') AND OBJECTPROPERTY(id, N'IsTrigger') = 1)
EXEC dbo.sp_executesql @statement = N'BEGIN
	INSERT INTO AuditDirectories (AuditActionType,
		DirectoryID, 
		DirectoryName,
		CreateDate,
		UpdateUserID, 
		UpdateDate  )
	SELECT ''UPDATE'' as AuditActionType,
		ins.DirectoryID, 
		ins.DirectoryName,
		ins.CreateDate,
		ins.UpdateUserID, 
		ins.UpdateDate 
	FROM 	deleted ins
END

' 
GO
