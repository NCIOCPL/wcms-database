IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetAllPrintableUrls]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetAllPrintableUrls]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/**********************************************************************************

	Object's name:	usp_GetAllPrintableUrls
	Object's type:	Stored procedure
	Purpose:	Get Pretty Url
	
	Change History:
	9/27/2004	Lijia Chu	

**********************************************************************************/


CREATE PROCEDURE dbo.usp_GetAllPrintableUrls

AS

SELECT	ISNULL(ProposedURL, CurrentURL) as CurrentURL, 
	RealURL
FROM 	ViewProperty vp
INNER JOIN	PrettyURL p
ON	vp.NCIViewID = p.NCIViewID
WHERE PropertyName = 'IsPrintAvailable'
 AND PropertyValue = 'YES'
 
	


GO
GRANT EXECUTE ON [dbo].[usp_GetAllPrintableUrls] TO [websiteuser_role]
GO
