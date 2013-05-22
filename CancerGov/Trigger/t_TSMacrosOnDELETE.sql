IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[t_TSMacrosOnDELETE]') AND OBJECTPROPERTY(id, N'IsTrigger') = 1)
EXEC dbo.sp_executesql @statement = N'BEGIN
	INSERT INTO AuditTSMacros (AuditActionType,
		MacroID,
		MacroName,
		MacroValue,
		IsOnProduction,
		Status,
		UpdateDate,
		UpdateUserID)
	SELECT ''DELETE'' as AuditActionType,
		tbl.MacroID,
		tbl.MacroName,
		tbl.MacroValue,
		tbl.IsOnProduction,
		tbl.Status,
		tbl.UpdateDate,
		tbl.UpdateUserID
	FROM 	deleted tbl
END' 
GO
