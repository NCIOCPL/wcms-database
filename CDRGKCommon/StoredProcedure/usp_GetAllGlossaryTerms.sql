IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetAllGlossaryTerms]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetAllGlossaryTerms]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/**********************************************************************************

	Object's name:	usp_GetAllGlossaryTerms
	Object's type:	Stored procedure
	Purpose:	Get GlossaryTerm name list
	
	Change History:
	10/13/2004	Lijia Chu	

**********************************************************************************/


CREATE PROCEDURE dbo.usp_GetAllGlossaryTerms

AS

SELECT	TermName 
FROM 	GlossaryTerm 
ORDER BY cast(lower(TermName) as binary)

	


GO
GRANT EXECUTE ON [dbo].[usp_GetAllGlossaryTerms] TO [websiteuser_role]
GO
