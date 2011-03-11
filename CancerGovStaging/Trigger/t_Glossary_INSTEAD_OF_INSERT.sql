IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[t_Glossary_INSTEAD_OF_INSERT]') AND OBJECTPROPERTY(id, N'IsTrigger') = 1)
EXEC dbo.sp_executesql @statement = N'BEGIN
	--Set correct version
	INSERT INTO Glossary(
		GlossaryID,
		[Name],
		Pronunciation,
		Definition,
		Status,
		Version,
		UpdateDate,
		UpdateUserID,
		SourceID,
		DataSource) 
	SELECT 	tbl.GlossaryID,
		tbl.[Name],
		tbl.Pronunciation,
		tbl.Definition,
		tbl.Status,
		[dbo].[GetNextSubVersion] (tbl.Version), -- GET NEXT Version --tbl.Version,
		tbl.UpdateDate,
		tbl.UpdateUserID,
		tbl.SourceID,
		tbl.DataSource 
	FROM 	inserted tbl

	--Log event into audit table
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
		DataSource) 
	SELECT ''INSERT'' as AuditActionType,
		tbl.GlossaryID,
		tbl.[Name],
		tbl.Pronunciation,
		tbl.Definition,
		tbl.Status,
		[dbo].[GetNextSubVersion] (tbl.Version), -- GET NEXT Version --tbl.Version,
		tbl.UpdateDate,
		tbl.UpdateUserID,
		tbl.SourceID,
		tbl.DataSource 
	FROM 	inserted tbl
END
' 
GO
