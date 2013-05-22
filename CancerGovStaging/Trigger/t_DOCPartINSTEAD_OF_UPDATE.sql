IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[t_DOCPartINSTEAD_OF_UPDATE]') AND OBJECTPROPERTY(id, N'IsTrigger') = 1)
EXEC dbo.sp_executesql @statement = N'BEGIN
	--First we update Original Document
	UPDATE Original
	SET 	
		Original.DocPartID	= 	New.DocPartID,
		Original.DocumentID	= 	New.DocumentID,
		Original.Priority	= 	New.Priority,	
		Original.Heading	= 	New.Heading,
		Original.Content	= 	New.Content,
		Original.ShowTitleOrNot = 	New.ShowTitleOrNot,
		Original.UpdateDate 	= GETDATE(),	
		Original.UpdateUserID = New.UpdateUserID
	FROM	DocPart as Original, inserted as New 	
	WHERE 	Original.docpartID = New.docpartID

	INSERT INTO AuditDocPart (AuditActionType,
		DocPartID, 
		DocumentID,
		Priority,
		Heading,
		Content,
		ShowTitleOrNot,
		UpdateUserID,
		UpdateDate  )
	SELECT ''UPDATE'' as AuditActionType,
		tbl.DocPartID, 
		tbl.DocumentID,
		tbl.Priority,
		tbl.Heading,
		tbl.Content,
		tbl.ShowTitleOrNot,
		tbl.UpdateUserID,
		tbl.UpdateDate
	FROM 	inserted tbl
END


' 
GO
