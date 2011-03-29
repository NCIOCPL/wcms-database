IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetGlossary]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetGlossary]
GO

/**********************************************************************************

	Object's name:	usp_GetGlossaryTest
	Object's type:	store proc
	Purpose:	
	Change history:	11/09/2004	Lijia
	9/8/2006	Vadim Prvotorov Add selection for Spanish

**********************************************************************************/

CREATE PROCEDURE [dbo].[usp_GetGlossary]
	(
	@Criteria	varchar(2000) = null,
	@Language	varchar(10) = 'ENGLISH',
	@topN int = 0
	)
AS
BEGIN
		
	if @topN =0
		BEGIN
				IF (@Language  = 'ENGLISH')
					BEGIN
						SELECT gt.GlossaryTermID, gt.TermName, gt.TermPronunciation, gt.SpanishTermName as OLTermName, gtd.DefinitionHTML,ISNULL(gtd.MediaHTML,'') MediaHTML
						FROM GlossaryTerm gt, GlossaryTermDefinition gtd, GlossaryTermDefinitionAudience  gtda, GlossaryTermDefinitionDictionary gtdd
						WHERE TermName like 
						case @Criteria when '[0-9]%' 
							then '[[0-9]%' 
							ELSE isnull(@criteria, '%')  
							END
							AND gt.GlossaryTermID = gtd.GlossaryTermID
						AND gtd.Language = 'ENGLISH'
						AND gtd.GlossaryTermDefinitionID = gtda.GlossaryTermDefinitionID
						AND gtda.Audience = 'Patient'
						AND gtd.GlossaryTermDefinitionID = gtdd.GlossaryTermDefinitionID
						AND gtdd.Dictionary = 'Cancer.Gov'
						ORDER BY cast(lower(TermName) as binary)
					END
				ELSE
					BEGIN
						SELECT gt.GlossaryTermID, gt.SpanishTermName as TermName, NULL as TermPronunciation, gt.TermName as OLTermName, gtd.DefinitionHTML,ISNULL(gtd.MediaHTML,'') MediaHTML
						FROM GlossaryTerm gt, GlossaryTermDefinition gtd, GlossaryTermDefinitionAudience  gtda, GlossaryTermDefinitionDictionary gtdd
						WHERE SpanishTermName collate modern_spanish_CI_AI 
						LIKE 
						case @Criteria when '[0-9]%' 
							then '[[0-9]%' 
							ELSE isnull(@criteria, '%')  
							END
						AND gt.GlossaryTermID = gtd.GlossaryTermID
						AND gtd.Language = 'SPANISH'
						AND gtd.GlossaryTermDefinitionID = gtda.GlossaryTermDefinitionID
						AND gtda.Audience = 'Patient'
						AND gtd.GlossaryTermDefinitionID = gtdd.GlossaryTermDefinitionID
						AND gtdd.Dictionary = 'Cancer.Gov'
						ORDER BY SpanishTermName
					END
		END
			ELSE
				BEGIN
					 IF (@Language  = 'ENGLISH')  
					  BEGIN  
					   SELECT top (@topN) gt.GlossaryTermID, gt.TermName, gt.TermPronunciation, gt.SpanishTermName as OLTermName, gtd.DefinitionHTML,ISNULL(gtd.MediaHTML,'') MediaHTML
					   FROM GlossaryTerm gt, GlossaryTermDefinition gtd, GlossaryTermDefinitionAudience  gtda, GlossaryTermDefinitionDictionary gtdd  
					   WHERE TermName 
					   LIKE case @Criteria when '[0-9]%' 
							then '[[0-9]%' 
							ELSE isnull(@criteria, '%')  
							END   
					   AND gt.GlossaryTermID = gtd.GlossaryTermID  
					   AND gtd.Language = 'ENGLISH'  
					   AND gtd.GlossaryTermDefinitionID = gtda.GlossaryTermDefinitionID  
					   AND gtda.Audience = 'Patient'  
					   AND gtd.GlossaryTermDefinitionID = gtdd.GlossaryTermDefinitionID  
					   AND gtdd.Dictionary = 'Cancer.Gov'  
					   ORDER BY cast(lower(TermName) as binary)  
					  END  
					 ELSE  
					  BEGIN  
					   SELECT top (@topN) gt.GlossaryTermID, gt.SpanishTermName as TermName, NULL as TermPronunciation, gt.TermName as OLTermName, gtd.DefinitionHTML,ISNULL(gtd.MediaHTML,'') MediaHTML
					   FROM GlossaryTerm gt, GlossaryTermDefinition gtd, GlossaryTermDefinitionAudience  gtda, GlossaryTermDefinitionDictionary gtdd  
					   WHERE SpanishTermName collate modern_spanish_CI_AI 
					   LIKE case @Criteria when '[0-9]%' 
							then '[[0-9]%' 
							ELSE isnull(@criteria, '%')  
							END  
					   AND gt.GlossaryTermID = gtd.GlossaryTermID  
					   AND gtd.Language = 'SPANISH'  
					   AND gtd.GlossaryTermDefinitionID = gtda.GlossaryTermDefinitionID  
					   AND gtda.Audience = 'Patient'  
					   AND gtd.GlossaryTermDefinitionID = gtdd.GlossaryTermDefinitionID  
					   AND gtdd.Dictionary = 'Cancer.Gov'  
					   ORDER BY SpanishTermName  
					  END
				END  
		END
		
	

GO

grant execute on dbo.usp_GetGlossary to websiteuser_role