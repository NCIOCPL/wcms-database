IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetGlossaryTermNeighbors]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetGlossaryTermNeighbors]
GO


/**********************************************************************************

	Object's name:	usp_GetGlossaryTermNeighbors
	Object's type:	store proc
	Purpose:	To search the glossary by string match and also return 5 previous and 5 next matches
	Author:		11/01/2004	Lijia
	
*	Change History:	
*	9/8/2006	Vadim Prvotorov Add selection for Spanish
**********************************************************************************/	

CREATE PROCEDURE [dbo].[usp_GetGlossaryTermNeighbors]
	(
	@name		varchar(2000),
	@num		smallint,
	@language	varchar(10) = 'ENGLISH'
	)
AS
BEGIN
	

	DECLARE	@Glossary TABLE
		(
		GlossaryTermID	int,
		TermName	varchar(2000),
		TermPronunciation	varchar(2000),
		DefinitionHTML	varchar(3900),
		IsPrevious	char(1)	
		)


	DECLARE	@SpanishGlossary TABLE
		(
		GlossaryTermID	int,
		TermName	varchar(2000) collate  Modern_Spanish_CI_AS,
		TermPronunciation	varchar(2000),
		DefinitionHTML	varchar(3900),
		IsPrevious	char(1)	
		)

	SET ROWCOUNT @num
 
	 IF (@language = 'ENGLISH')
	 BEGIN
		INSERT INTO @Glossary
		SELECT gt.GlossaryTermID, gt.TermName, gt.TermPronunciation, gtd.DefinitionHTML,'N' IsPrevious
		FROM	GlossaryTerm gt, 
			GlossaryTermDefinition gtd, 
			GlossaryTermDefinitionAudience  gtda, 
			GlossaryTermDefinitionDictionary gtdd
		WHERE 	cast(lower(TermName) as binary) >cast(lower(@Name) as binary)
		AND 	gt.GlossaryTermID = gtd.GlossaryTermID
		AND 	gtd.Language = 'ENGLISH'
		AND 	gtd.GlossaryTermDefinitionID = gtda.GlossaryTermDefinitionID
		AND 	gtda.Audience = 'Patient'
		AND 	gtd.GlossaryTermDefinitionID = gtdd.GlossaryTermDefinitionID
		AND 	gtdd.Dictionary = 'Cancer.Gov'
		ORDER BY cast(lower(TermName) as binary) ASC
	END
	ELSE
	BEGIN
		INSERT INTO @SpanishGlossary
		SELECT gt.GlossaryTermID, gt.SpanishTermName TermName, gt.TermPronunciation, gtd.DefinitionHTML,'N' IsPrevious
		FROM	GlossaryTerm gt, 
			GlossaryTermDefinition gtd, 
			GlossaryTermDefinitionAudience  gtda, 
			GlossaryTermDefinitionDictionary gtdd
		WHERE 	SpanishTermName > @Name
		AND 	gt.GlossaryTermID = gtd.GlossaryTermID
		AND 	gtd.Language = 'SPANISH'
		AND 	gtd.GlossaryTermDefinitionID = gtda.GlossaryTermDefinitionID
		AND 	gtda.Audience = 'Patient'
		AND 	gtd.GlossaryTermDefinitionID = gtdd.GlossaryTermDefinitionID
		AND 	gtdd.Dictionary = 'Cancer.Gov'
		ORDER BY SpanishTermName ASC
	END
	

	SET ROWCOUNT @num

	 IF (@language = 'ENGLISH')
	 BEGIN
		INSERT INTO @Glossary
		SELECT gt.GlossaryTermID, gt.TermName, gt.TermPronunciation, gtd.DefinitionHTML,'Y' IsPrevious
		FROM	GlossaryTerm gt, 
			GlossaryTermDefinition gtd, 
			GlossaryTermDefinitionAudience  gtda, 
			GlossaryTermDefinitionDictionary gtdd
		WHERE 	cast(lower(TermName) as binary) <cast(lower(@Name) as binary)
		AND 	gt.GlossaryTermID = gtd.GlossaryTermID
		AND 	gtd.Language = 'ENGLISH'
		AND 	gtd.GlossaryTermDefinitionID = gtda.GlossaryTermDefinitionID
		AND 	gtda.Audience = 'Patient'
		AND 	gtd.GlossaryTermDefinitionID = gtdd.GlossaryTermDefinitionID
		AND 	gtdd.Dictionary = 'Cancer.Gov'
		ORDER BY cast(lower(TermName) as binary) DESC
	END
	ELSE
	BEGIN
		INSERT INTO @SpanishGlossary
		SELECT gt.GlossaryTermID, gt.SpanishTermName as TermName, gt.TermPronunciation, gtd.DefinitionHTML,'Y' IsPrevious
		FROM	GlossaryTerm gt, 
			GlossaryTermDefinition gtd, 
			GlossaryTermDefinitionAudience  gtda, 
			GlossaryTermDefinitionDictionary gtdd
		WHERE 	SpanishTermName < @Name
		AND 	gt.GlossaryTermID = gtd.GlossaryTermID
		AND 	gtd.Language = 'SPANISH'
		AND 	gtd.GlossaryTermDefinitionID = gtda.GlossaryTermDefinitionID
		AND 	gtda.Audience = 'Patient'
		AND 	gtd.GlossaryTermDefinitionID = gtdd.GlossaryTermDefinitionID
		AND 	gtdd.Dictionary = 'Cancer.Gov'
		ORDER BY SpanishTermName DESC
	END

	SET ROWCOUNT 0
	
	IF (@language = 'ENGLISH')
	BEGIN
		SELECT * FROM @Glossary ORDER BY cast(lower(TermName) as binary) ASC
	END
	ELSE
	BEGIN
		SELECT * FROM @SpanishGlossary ORDER BY TermName ASC
	END



	
END
GO
grant execute on usp_GetGlossaryTermNeighbors to websiteuser_role