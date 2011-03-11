IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[t_DOCPartOnDELETE]') AND OBJECTPROPERTY(id, N'IsTrigger') = 1)
EXEC dbo.sp_executesql @statement = N'BEGIN
	DELETE 	Original
	FROM	DOCPart as Original, deleted as Old 	
	WHERE 	Original.DocPartID = Old.DocPartID

	INSERT INTO AuditDocPart (AuditActionType,
		DocPartID, 
		DocumentID,
		Priority,
		Heading,
		Content,
		ShowTitleOrNot,
		UpdateUserID,
		UpdateDate  )
	SELECT ''DELETE'' as AuditActionType,
		tbl.DocPartID, 
		tbl.DocumentID,
		tbl.Priority,
		tbl.Heading,
		tbl.Content,
		tbl.ShowTitleOrNot,
		tbl.UpdateUserID,
		tbl.UpdateDate
	FROM 	deleted tbl
END' 
GO
