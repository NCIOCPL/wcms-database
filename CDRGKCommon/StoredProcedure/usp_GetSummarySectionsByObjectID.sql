IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetSummarySectionsByObjectID]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetSummarySectionsByObjectID]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/**********************************************************************************

	Object's name:	usp_GetSummarySectionsByObjectID
	Object's type:	Stored procedure
	Purpose:	Get Pretty Url
	
	Change History:
	9/27/2004	Lijia Chu	

**********************************************************************************/


CREATE PROCEDURE dbo.usp_GetSummarySectionsByObjectID
		@objectId uniqueidentifier
AS

SELECT 	ss.SectionID
FROM 	SummarySection ss
INNER JOIN	Document d
ON 	ss.SummaryID = d.DocumentID
WHERE 	d.DocumentGUID = @objectID
  AND 	ss.SectionLevel = 1
  AND	ss.SectionType = 'SummarySection'
ORDER BY Priority

	


GO
GRANT EXECUTE ON [dbo].[usp_GetSummarySectionsByObjectID] TO [websiteuser_role]
GO
