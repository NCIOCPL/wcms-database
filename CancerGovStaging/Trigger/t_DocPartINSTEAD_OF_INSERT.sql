IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[t_DocPartINSTEAD_OF_INSERT]') AND OBJECTPROPERTY(id, N'IsTrigger') = 1)
EXEC dbo.sp_executesql @statement = N'BEGIN
	INSERT into DocPart (
		DocPartID, 
		DocumentID,
		Priority,
		Heading,
		Content,
		ShowTitleOrNot,
		UpdateUserID,
		UpdateDate ) 
	SELECT 	ins.DocPartID, 
		ins.DocumentID,
		ins.Priority,
		ins.Heading,
		ins.Content,
		ins.ShowTitleOrNot,
		ins.UpdateUserID,
		ins.UpdateDate
	FROM 	inserted ins

	INSERT INTO AuditDocPart (AuditActionType,
		DocPartID, 
		DocumentID,
		Priority,
		Heading,
		Content,
		ShowTitleOrNot,
		UpdateUserID,
		UpdateDate ) 
	SELECT ''INSERT'' as AuditActionType,
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
