IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetGlossary]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetGlossary]
GO

/**********************************************************************************

	Object's name:	usp_GetGlossaryTest
	Object's type:	store proc
	Purpose:	
	Change history:	11/09/2004	Lijia
	9/8/2006	Vadim Prvotorov Add selection for Spanish
	06/03/2011  Prasad Betnag - Return AudioMediaHtml column
**********************************************************************************/

CREATE PROCEDURE [dbo].[usp_GetGlossary]
	(
	@Criteria	varchar(2000) = null,
	@Language	varchar(10) = 'ENGLISH',
	@topN int = 0,
	@pagenumber int = -1,
	@recordsPerPage int =10,
	@totalresult int output
	)
AS
BEGIN
	
	if (@pagenumber <> -1)
		BEGIN
				IF (@Language  = 'ENGLISH')
						BEGIN

								select
								@totalResult = count(*) 
								FROM GlossaryTerm gt
								, GlossaryTermDefinition gtd
								, GlossaryTermDefinitionAudience  gtda
								, GlossaryTermDefinitionDictionary gtdd
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

								SELECT glossarytermid, termname
									,termpronunciation
									,OLTermname
									, definitionhtml
									, Mediahtml
									, AudioMediaHTML
									, relatedInformationHTML
									, mediaCaption
									, mediaID
									from	
									(select
										row_number () over ( order by cast(lower(TermName) as binary)) as num
										,gt.GlossaryTermID, gt.TermName
										, gt.TermPronunciation
										, gt.SpanishTermName as OLTermName
										, gtd.DefinitionHTML,
										ISNULL(gtd.MediaHTML,'') MediaHTML, 
										ISNULL(gtd.AudioMediaHTML,'') AudioMediaHTML,
										ISNULL(gtd.RelatedInformationHtml,'') RelatedInformationHtml
										, mediaCaption
										, mediaID
								FROM GlossaryTerm gt
								, GlossaryTermDefinition gtd
								, GlossaryTermDefinitionAudience  gtda
								, GlossaryTermDefinitionDictionary gtdd
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
									)a
								where	@pagenumber = -1 OR
										(num > @recordsperpage*(@pagenumber-1)
										and num <= @recordsperpage*@pagenumber)
					
								ORDER BY num
							END
						ELSE --language
								BEGIN

									select
									@totalresult=	count(*) 
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

									SELECT glossarytermid, termname
									,termpronunciation
									,OLTermname
									, definitionhtml
									, Mediahtml
									, AudioMediaHTML
									, relatedInformationHTML
									, mediaCaption
									, mediaID

									from	
									(select
										row_number () over ( order by spanishtermname) as num
										,gt.GlossaryTermID
										, gt.SpanishTermName as TermName
										, NULL as TermPronunciation
										, gt.TermName as OLTermName
										, gtd.DefinitionHTML, 
										ISNULL(gtd.MediaHTML,'') MediaHTML, 
										ISNULL(gtd.AudioMediaHTML,'') AudioMediaHTML,
										ISNULL(gtd.RelatedInformationHtml,'') RelatedInformationHtml
										, mediaCaption
										, mediaID
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
									)a
								where	@pagenumber = -1 OR
										(num > @recordsperpage*(@pagenumber-1)
										and num <= @recordsperpage*@pagenumber)
					
								ORDER BY num
							END
			END--pagenumber 
			
		ELSE

			BEGIN
					 IF (@Language  = 'ENGLISH')  
					  BEGIN  
						SELECT @totalresult = count(*)
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

					 if @topN =0 
						SELECT gt.GlossaryTermID, gt.TermName, gt.TermPronunciation, gt.SpanishTermName as OLTermName, gtd.DefinitionHTML, 
							ISNULL(gtd.MediaHTML,'') MediaHTML, 
							ISNULL(gtd.AudioMediaHTML,'') AudioMediaHTML,
							ISNULL(gtd.RelatedInformationHtml,'') RelatedInformationHtml
									, mediaCaption
									, mediaID

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
						ELSE
					   SELECT top (@topN) gt.GlossaryTermID, gt.TermName, gt.TermPronunciation, gt.SpanishTermName as OLTermName, gtd.DefinitionHTML, 
							ISNULL(gtd.MediaHTML,'') MediaHTML, 
							ISNULL(gtd.AudioMediaHTML,'') AudioMediaHTML,
							ISNULL(gtd.RelatedInformationHtml,'') RelatedInformationHtml
									, mediaCaption
									, mediaID

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
			ELSE  --language
				BEGIN  
					
			
					SELECT @totalresult = count(*)
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

						if @topN = 0
							SELECT  gt.GlossaryTermID, gt.SpanishTermName as TermName, NULL as TermPronunciation, gt.TermName as OLTermName, gtd.DefinitionHTML, 
									ISNULL(gtd.MediaHTML,'') MediaHTML, 
									ISNULL(gtd.AudioMediaHTML,'') AudioMediaHTML,
									ISNULL(gtd.RelatedInformationHtml,'') RelatedInformationHtml
									, mediaCaption
									, mediaID

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
						ELSE
					   SELECT top (@topN) gt.GlossaryTermID, gt.SpanishTermName as TermName, NULL as TermPronunciation, gt.TermName as OLTermName, gtd.DefinitionHTML, 
									ISNULL(gtd.MediaHTML,'') MediaHTML, 
									ISNULL(gtd.AudioMediaHTML,'') AudioMediaHTML,
									ISNULL(gtd.RelatedInformationHtml,'') RelatedInformationHtml
									, mediaCaption
									, mediaID

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