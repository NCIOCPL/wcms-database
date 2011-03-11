IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[t_Glossary_INSTEAD_OF_UPDATE]') AND OBJECTPROPERTY(id, N'IsTrigger') = 1)
EXEC dbo.sp_executesql @statement = N'BEGIN
	--first update data 
	UPDATE 	Original
	SET	Original.[Name] = New.[Name],
		Original.Pronunciation = New.Pronunciation,
		Original.Definition = New.Definition,
		Original.Status = New.Status,
		Original.Version = [dbo].[GetNextSubVersion] (New.Version),
		Original.UpdateDate = New.UpdateDate,
		Original.UpdateUserID = New.UpdateUserID,
		Original.SourceID = New.SourceID,
		Original.DataSource = New.DataSource
	FROM	dbo.Glossary as Original, 
		inserted as New 	
	WHERE  	Original.GlossaryID = New.GlossaryID

	--then log event into audit table
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
	SELECT ''UPDATE'' AS AuditActionType,
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
