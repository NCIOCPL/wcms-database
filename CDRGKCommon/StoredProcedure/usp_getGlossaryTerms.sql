IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetGlossaryTerms]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetGlossaryTerms]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
--	Created:	11/14/2002
--	Author:		Greg Andres
--	Purpose:	Pulls glossary terms by term name, term sourceid, or term cdrid.
--	Used By:	CancerGov.Common.Extraction.GlossaryTermExtractor
--
--	Updated:	9/29/2003	Chen Ling	use new Glossary Tables

CREATE PROCEDURE dbo.usp_GetGlossaryTerms
	(
		@GlossaryIDs	varchar(8000) = null,		-- comma-delimited integer IDs
		@SourceIDs	varchar(8000) = 'xxxxxxxx',	-- comma-delimited integer IDs	-- source ids not currently mapped and are all null
		@Terms	varchar(8000) = null		-- comma-delimited strings
	)

 AS

(
select gt.GlossaryTermID as GlossaryID, gt.TermName as [Name], gtd.DefinitionHTML as Definition, gt.TermPronunciation as [Pronunciation], gtda.Audience, upper(gtd.Language) as language
from GlossaryTerm gt, GlossaryTermDefinition gtd, GlossaryTermDefinitionAudience gtda
where gt.GlossaryTermID = gtd.GlossaryTermID
and gtd.GlossaryTermDefinitionID = gtda.GlossaryTermDefinitionID
and gtd.Language = 'ENGLISH'
and gt.GlossaryTermID IN (SELECT LTRIM(RTRIM( ObjectID )) FROM dbo.udf_GetComaSeparatedIDs (@GlossaryIDs))
)

UNION

(
select gt.GlossaryTermID as GlossaryID, gt.SpanishTermName collate SQL_Latin1_General_CP1_CI_AS as [Name], gtd.DefinitionHTML as Definition, gt.TermPronunciation as [Pronunciation], gtda.Audience, upper(gtd.Language) as language
from GlossaryTerm gt, GlossaryTermDefinition gtd, GlossaryTermDefinitionAudience gtda
where gt.GlossaryTermID = gtd.GlossaryTermID
and gtd.GlossaryTermDefinitionID = gtda.GlossaryTermDefinitionID
and gtd.Language = 'SPANISH'
and gt.GlossaryTermID IN (SELECT LTRIM(RTRIM( ObjectID )) FROM dbo.udf_GetComaSeparatedIDs (@GlossaryIDs))
)

UNION

(
select gt.GlossaryTermID as GlossaryID, gt.TermName as [Name], gtd.DefinitionHTML as Definition, gt.TermPronunciation as [Pronunciation], gtda.Audience, upper(gtd.Language) as language
from GlossaryTerm gt, GlossaryTermDefinition gtd, GlossaryTermDefinitionAudience gtda
where gt.GlossaryTermID = gtd.GlossaryTermID
and gtd.GlossaryTermDefinitionID = gtda.GlossaryTermDefinitionID
and gtd.Language = 'ENGLISH'
and gt.TermName IN (SELECT LTRIM(RTRIM( ObjectID )) FROM dbo.udf_GetComaSeparatedIDs(@Terms))
)

UNION

(
select gt.GlossaryTermID as GlossaryID, gt.SpanishTermName   collate SQL_Latin1_General_CP1_CI_AS as [Name], gtd.DefinitionHTML as Definition, gt.TermPronunciation as [Pronunciation], gtda.Audience, upper(gtd.Language) as language
from GlossaryTerm gt, GlossaryTermDefinition gtd, GlossaryTermDefinitionAudience gtda
where gt.GlossaryTermID = gtd.GlossaryTermID
and gtd.GlossaryTermDefinitionID = gtda.GlossaryTermDefinitionID
and gtd.Language = 'SPANISH'
and gt.SpanishTermName  IN (SELECT LTRIM(RTRIM( ObjectID collate  Modern_Spanish_CI_AS )) FROM dbo.udf_GetComaSeparatedIDs(@Terms))
)

ORDER BY [Name] ASC
GO
GRANT EXECUTE ON [dbo].[usp_GetGlossaryTerms] TO [websiteuser_role]
GO
