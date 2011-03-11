IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_RetrieveTopic]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_RetrieveTopic]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  Stored Procedure dbo.usp_RetrieveTopic
Owner: Jhe 
Purpose: For admin side 
Script Date: 3/17/2003 16:00:49 pm 
******/

CREATE PROCEDURE dbo.usp_RetrieveTopic
(
	@TopicID       	UniqueIdentifier
)
AS
BEGIN
	SELECT  N.Title, N.ShortTitle, N.[Description], 'URL'=N.URL + '?' + N.URLArguments,  T.TopicName, T.EditableTopicSearchTerm, N.IsOnProduction, N.Status, N.CreateDate, N.Updatedate, N.UpdateUserID
	FROM 	TSTopics T, ViewObjects V, NCIView N
	Where T.TopicID =@TopicID and T.TopicID = V.ObjectID and V.NCIViewID= N.NCIViewID
END
GO
GRANT EXECUTE ON [dbo].[usp_RetrieveTopic] TO [webadminuser_role]
GO
