IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetRealURL]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetRealURL]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/**********************************************************************************

	Object's name:	usp_GetRealURL
	Object's type:	Stored procedure
	Purpose:	Get real URL
	
	Change History:
	9/21/2004	Lijia Chu	

**********************************************************************************/


CREATE PROCEDURE dbo.usp_GetRealURL
       	     @CurrentURL VARCHAR(200)
AS

SELECT	realurl 
FROM	PrettyURL 
WHERE 	ISNULL(ProposedURL, CurrentURL) = @currentUrl
	


GO
GRANT EXECUTE ON [dbo].[usp_GetRealURL] TO [websiteuser_role]
GO
