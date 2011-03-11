IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_UpdateTSTopics]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_UpdateTSTopics]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/****** 	Object:  Stored Procedure dbo.usp_UpdateTopicSearch    
	Owner:	Jay He
	Script Date: 3/17/2003 14:43:49 pM 
******/

CREATE PROCEDURE dbo.usp_UpdateTSTopics
(
	@TopicSearchTerm 		ntext,
	@TopicID			UniqueIdentifier
)
AS
BEGIN

	UPDATE TSTopics 
	set 	TopicSearchTerm=@TopicSearchTerm
	where TopicID = @TopicID
	IF (@@ERROR <> 0)
	BEGIN
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 

	RETURN 0 

END

GO
GRANT EXECUTE ON [dbo].[usp_UpdateTSTopics] TO [webadminuser_role]
GO
