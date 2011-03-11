IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_RetrieveTopicSearch]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_RetrieveTopicSearch]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  Stored Procedure dbo.usp_RetrieveTopicSearch
Owner: Jhe 
Purpose: For admin side 
Script Date: 3/17/2003 16:00:49 pm 

SELECT T.TopicID, T.TopicName, 'Edit Page' As PageURL, 'EditNCIView.aspx?NCIViewID='+ CONVERT(varchar(36), V.NCIViewID) + '&ReturnURL='  AS URL
	FROM 	TSTopics T, ViewObjects V
	WHERE T.TopicID = V.ObjectID
******/

CREATE PROCEDURE dbo.usp_RetrieveTopicSearch
AS
	SELECT T.TopicID, V.NCIViewID, T.TopicName, N.Status
	FROM 	TSTopics T, ViewObjects V, NCIView N
	WHERE T.TopicID = V.ObjectID and N.NCIviewID= V.NCIViewID
	ORDER By T.TopicName
GO
GRANT EXECUTE ON [dbo].[usp_RetrieveTopicSearch] TO [webadminuser_role]
GO
