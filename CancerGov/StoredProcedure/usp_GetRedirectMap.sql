IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetRedirectMap]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetRedirectMap]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/**********************************************************************************

	Object's name:	usp_GetRedirectMap
	Object's type:	Stored procedure
	Purpose:	Get current URL
	
	Change History:
	9/21/2004	Lijia Chu	

**********************************************************************************/


CREATE PROCEDURE dbo.usp_GetRedirectMap
       	     @OldURL VARCHAR(512),
	     @Source VARCHAR(20)
AS

SELECT	currenturl 
FROM	RedirectMap 
WHERE 	OldURL=@oldUrl
AND	Source=@Source



GO
GRANT EXECUTE ON [dbo].[usp_GetRedirectMap] TO [websiteuser_role]
GO
