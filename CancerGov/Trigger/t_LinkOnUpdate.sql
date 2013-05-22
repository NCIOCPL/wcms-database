IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[t_LinkOnUpdate]') AND OBJECTPROPERTY(id, N'IsTrigger') = 1)
EXEC dbo.sp_executesql @statement = N'BEGIN
	INSERT INTO AuditLink (AuditActionType,
	 	LinkID,
		Title,
		URL,
		InternalOrExternal,
		UpdateUserID,
		UpdateDate   )
	SELECT ''UPDATE'' as AuditActionType,
	 	ins.LinkID,
		ins.Title,
		ins.URL,
		ins.InternalOrExternal,
		ins.UpdateUserID,
		ins.UpdateDate 
	FROM 	deleted ins
END

' 
GO
