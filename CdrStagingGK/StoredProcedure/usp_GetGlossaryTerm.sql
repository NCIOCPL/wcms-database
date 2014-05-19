IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_GetGlossaryTerm]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[usp_GetGlossaryTerm]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].usp_GetGlossaryTerm
	@GlossaryTermID	varchar(50) -- Document's CDRID
AS
BEGIN
	set nocount ON

	select GlossaryTermID, TermName, TermPronunciation, SpanishTermName
	from GlossaryTerm
	where GlossaryTermID = @GlossaryTermID

	select gtda.Audience, gtd.Language, gtd.DefinitionText, gtd.DefinitionHTML, gtd.MediaHTML, gtd.AudioMediaHTML, gtd.RelatedInformationHtml
	from GlossaryTermDefinition gtd join GlossaryTermDefinitionAudience gtda
		on gtd.GlossaryTermDefinitionID = gtda.GlossaryTermDefinitionID
	where gtd.GlossaryTermID = @GlossaryTermID

	RETURN 0  --Succesful return 0
END


GO
GRANT EXECUTE ON [dbo].[usp_GetGlossaryTerm] TO [gatekeeper_role]
GO
