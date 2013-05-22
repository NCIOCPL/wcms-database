IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetTopicTerms]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetTopicTerms]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*************************************************************************************************************
* NCI - National Cancer Institute
* 
* 
* Purpose: 
* 
*
* Objects Used:
* 
*
* Rem
* - data ordered by Priority then by TopicName
* 
* Change History:
*	??/??/200? 	Pizzillo, Bryan (NIH/NCI) 	Script Created 
* 
*
*************************************************************************************************************/


CREATE PROCEDURE dbo.usp_GetTopicTerms

	@ListId	uniqueidentifier

AS
BEGIN

	CREATE TABLE #TempTopicTerms (
		NCIViewID uniqueidentifier,
		Priority int
	)
	
	
	INSERT INTO #TempTopicTerms
	SELECT 	NCIViewID, 
		Priority
	FROM 	ListItem
	WHERE 	ListID = @ListId
		

	SELECT 	ts.TopicName,
		ts.TopicSearchTerm
	FROM 	TSTopics ts, 
		#TempTopicTerms ttt, 
		viewobjects vo
	WHERE 	ttt.nciviewid = vo.nciviewid
		AND ts.TopicId = vo.objectid
	ORDER BY ttt.priority ASC, 
		ts.TopicName ASC
	
	DROP TABLE #TempTopicTerms
END

GO
GRANT EXECUTE ON [dbo].[usp_GetTopicTerms] TO [websiteuser_role]
GO
