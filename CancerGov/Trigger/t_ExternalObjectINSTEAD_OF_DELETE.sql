IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[t_ExternalObjectINSTEAD_OF_DELETE]') AND OBJECTPROPERTY(id, N'IsTrigger') = 1)
EXEC dbo.sp_executesql @statement = N'BEGIN
	DELETE 	Original
	FROM	ExternalObject as Original, deleted as Old 	
	WHERE 	Original.ExternalObjectID = Old.ExternalObjectID

	INSERT INTO AuditExternalObject (
		AuditActionType,
		ExternalobjectID,
		Title,
		[Format],
		[Description],
		Path,
		[Text],
		UpdateDate,
		UpdateUserID)	
	SELECT 
		''DELETE'' as AuditActionType,
		del.ExternalobjectID,
		del.Title,
		del.[Format],
		del.[Description],
		del.Path,
		del.[Text],
		del.UpdateDate,
		del.UpdateUserID
	FROM 	deleted del
END




' 
GO
