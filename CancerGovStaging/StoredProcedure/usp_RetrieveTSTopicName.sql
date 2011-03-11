IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_RetrieveTSTopicName]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_RetrieveTSTopicName]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/****** Object:  Stored Procedure dbo.usp_RetrieveMacro
Owner: Jhe 
Purpose: For admin side 
Script Date: 3/17/2003 16:00:49 pm 
******/

CREATE PROCEDURE dbo.usp_RetrieveTSTopicName
(
	@Macro ntext
)
AS
BEGIN
	select TopicName from TSTopics where EditableTopicSearchTerm like '%{" + macro +"}%'
END

GO
GRANT EXECUTE ON [dbo].[usp_RetrieveTSTopicName] TO [webadminuser_role]
GO
