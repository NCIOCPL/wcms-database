IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetGlossaryTermList]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetGlossaryTermList]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




/**********************************************************************************

	Object's name:	usp_GetGlossaryTermList
	Object's type:	Stored procedure
	Purpose:	Get GlossaryTerm list
	
	Change History:
	10/13/2004	Lijia Chu	

**********************************************************************************/


CREATE PROCEDURE dbo.usp_GetGlossaryTermList
	@beginWith	varchar(2000)
AS

SELECT	gt.TermName, 
	gt.TermPronunciation, 
	gtd.DefinitionHTML, 
	gtd.Language, 
	gtda.Audience, 
	gtdd.Dictionary,
	ISNULL(gtd.MediaHTML,'') MediaHTML 
FROM	GlossaryTerm gt, 
	GlossaryTermDefinition gtd, 
	GlossaryTermDefinitionAudience  gtda, 
	GlossaryTermDefinitionDictionary gtdd
WHERE 	gt.GlossaryTermID = gtd.GlossaryTermID
  AND 	gtd.GlossaryTermDefinitionID = gtda.GlossaryTermDefinitionID
  AND 	gtd.GlossaryTermDefinitionID = gtdd.GlossaryTermDefinitionID
  And 	TermName like @beginWith + '%'
ORDER BY cast(lower(gt.TermName) as binary)



	



GO
GRANT EXECUTE ON [dbo].[usp_GetGlossaryTermList] TO [websiteuser_role]
GO
