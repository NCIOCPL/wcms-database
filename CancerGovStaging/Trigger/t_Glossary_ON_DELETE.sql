IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[t_Glossary_ON_DELETE]') AND OBJECTPROPERTY(id, N'IsTrigger') = 1)
EXEC dbo.sp_executesql @statement = N'BEGIN
	INSERT INTO AuditGlossary(AuditActionType,
		GlossaryID,
		[Name],
		Pronunciation,
		Definition,
		Status,
		Version, 
		UpdateDate,
		UpdateUserID,
		SourceID,
		DataSource 
	) 
	SELECT ''DELETE'' as AuditActionType,
		tbl.GlossaryID,
		tbl.[Name],
		tbl.Pronunciation,
		tbl.Definition,
		tbl.Status,
		tbl.Version, 
		tbl.UpdateDate,
		tbl.UpdateUserID,
		tbl.SourceID,
		tbl.DataSource 
	FROM 	deleted  tbl
END
' 
GO
