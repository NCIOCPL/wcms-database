IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetTopicView]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetTopicView]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE dbo.usp_GetTopicView 

	@NCIViewID	uniqueidentifier

AS
BEGIN

	SELECT tst.TopicName, tst.TopicSearchTerm
	FROM TSTopics tst, viewobjects vo
	WHERE vo.nciviewid=@NCIViewID
	AND vo.objectid=tst.topicid
	AND vo.type='TSTOPIC'

END
GO
GRANT EXECUTE ON [dbo].[usp_GetTopicView] TO [websiteuser_role]
GO
