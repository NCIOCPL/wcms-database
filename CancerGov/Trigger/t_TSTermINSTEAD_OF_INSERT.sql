IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[t_TSTermINSTEAD_OF_INSERT]') AND OBJECTPROPERTY(id, N'IsTrigger') = 1)
EXEC dbo.sp_executesql @statement = N'BEGIN
	--First Inser the Document
	INSERT INTO TSTopics (
		TopicId,
		TopicName,
		TopicSearchTerm,
		EditableTopicSearchTerm,
		UpdateDate,
		UpdateUserID)	
	SELECT 
		ins.TopicId,
		ins.TopicName,
		ins.TopicSearchTerm,
		ins.EditableTopicSearchTerm,
		ins.UpdateDate,
		ins.UpdateUserID
	FROM 	inserted ins


	--Then we log information in to the DocumentAudit table
	INSERT INTO AuditTSTopics (
		AuditActionType,
		TopicId,
		TopicName,
		TopicSearchTerm,
		EditableTopicSearchTerm,
		UpdateDate,
		UpdateUserID)	
	SELECT 
		''INSERT'' as AuditActionType,
		ins.TopicId,
		ins.TopicName,
		ins.TopicSearchTerm,
		ins.EditableTopicSearchTerm,
		ins.UpdateDate,
		ins.UpdateUserID
	FROM 	inserted ins
END
' 
GO
