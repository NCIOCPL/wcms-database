IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetAllNCIViewsOfSummary]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetAllNCIViewsOfSummary]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/**********************************************************************************

	Object's name:	usp_GetAllNCIViewsOfSummary
	Object's type:	Stored procedure
	Purpose:	Get Pretty Url
	
	Change History:
	9/27/2004	Lijia Chu	

**********************************************************************************/


CREATE PROCEDURE dbo.usp_GetAllNCIViewsOfSummary

AS

SELECT 	p.NCIViewID, 
	ObjectID, 
	ISNULL(ProposedURL, CurrentURL) as CurrentURL,
	realURL 
FROM 	PrettyURL p
INNER JOIN NCIView v
	ON p.NCIViewID = v.NCIViewID
INNER JOIN NCITemplate t
	ON t.NCITemplateID =v.NCITemplateID 
WHERE 	t.name='Summary'
 AND	IsRoot = 0
 AND 	ObjectID IS NOT NULL
	


GO
GRANT EXECUTE ON [dbo].[usp_GetAllNCIViewsOfSummary] TO [websiteuser_role]
GO
