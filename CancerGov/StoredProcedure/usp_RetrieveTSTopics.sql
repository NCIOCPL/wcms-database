IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_RetrieveTSTopics]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_RetrieveTSTopics]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/****** Object:  Stored Procedure dbo.usp_RetrieveTopicMacro
Owner: Jhe 
Purpose: For admin side 
Script Date: 3/17/2003 16:00:49 pm 
******/

CREATE PROCEDURE dbo.usp_RetrieveTSTopics
AS
BEGIN
	SELECT TopicId,
                            TopicName,
		 TopicSearchTerm,
		 EditableTopicSearchTerm,
		UpdateUserID,
		UpdateDate
	FROM 	TSTopics
	order by TopicName
END


GO
GRANT EXECUTE ON [dbo].[usp_RetrieveTSTopics] TO [webadminuser_role]
GO
