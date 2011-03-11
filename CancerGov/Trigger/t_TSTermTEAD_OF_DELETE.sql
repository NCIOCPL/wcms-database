IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[t_TSTermTEAD_OF_DELETE]') AND OBJECTPROPERTY(id, N'IsTrigger') = 1)
EXEC dbo.sp_executesql @statement = N'BEGIN
	DELETE 	Original
	FROM	TSTopics as Original, deleted as Old 	
	WHERE 	Original.TopicID = Old.TopicID

	INSERT INTO AuditTSTopics (
		AuditActionType,
		TopicId,
		TopicName,
		TopicSearchTerm,
		EditableTopicSearchTerm,
		UpdateDate,
		UpdateUserID)	
	SELECT 
		''DELETE'' as AuditActionType,
		del.TopicId,
		del.TopicName,
		del.TopicSearchTerm,
		del.EditableTopicSearchTerm,
		del.UpdateDate,
		del.UpdateUserID
	FROM 	deleted del
END
' 
GO
