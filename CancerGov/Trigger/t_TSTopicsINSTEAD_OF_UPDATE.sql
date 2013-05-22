IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[t_TSTopicsINSTEAD_OF_UPDATE]') AND OBJECTPROPERTY(id, N'IsTrigger') = 1)
EXEC dbo.sp_executesql @statement = N'BEGIN
	--First we update Original Document
	UPDATE Original
	SET 	
		Original.TopicID 	= 	New.TopicID,
		Original.TopicName	=	New.TopicName	,
		Original.TopicSearchTerm=	New.TopicSearchTerm,
		Original.EditableTopicSearchTerm=	New.EditableTopicSearchTerm,
		Original.UpdateDate 	= GETDATE(),	
		Original.UpdateUserID = New.UpdateUserID
	FROM	TSTopics as Original, inserted as New 	
	WHERE 	Original.TopicID = New.TopicID

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
		''UPDATE'' as AuditActionType,
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
