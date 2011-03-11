IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetActiveSummaries]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetActiveSummaries]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/**********************************************************************************

	Object's name:	usp_GetActiveSummaries
	Object's type:	Stored procedure
	Purpose:	Get active summaries
	
	Change History:
	10/13/2004	Lijia Chu
	12/08/2010	Blair Learn - Look up Pretty URL instead of DocumentGUID

**********************************************************************************/


CREATE PROCEDURE dbo.usp_GetActiveSummaries

AS

SELECT	S.SummaryID, 
	S.Type, 
	S.Audience, 
	S.Title, 
	S.Language, 
	S.PrettyURL
FROM	dbo.Summary S 
INNER JOIN dbo.Document D 
ON 	S.SummaryID = D.DocumentID
WHERE 	D.IsActive = 1
ORDER BY S.Type, S.Title, S.Language, S.Audience


	


GO
GRANT EXECUTE ON [dbo].[usp_GetActiveSummaries] TO [websiteuser_role]
GO
