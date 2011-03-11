IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetAllPrettyUrls]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetAllPrettyUrls]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/**********************************************************************************

	Object's name:	usp_GetAllPrettyUrls
	Object's type:	Stored procedure
	Purpose:	Get Pretty Url
	
	Change History:
	9/27/2004	Lijia Chu	

**********************************************************************************/


CREATE PROCEDURE dbo.usp_GetAllPrettyUrls

AS

SELECT 	ISNULL(ProposedURL, CurrentURL) currenturl, 
	realurl 
FROM 	PrettyURL
	


GO
GRANT EXECUTE ON [dbo].[usp_GetAllPrettyUrls] TO [websiteuser_role]
GO
