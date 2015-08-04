IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_SaveDictionaryTerm]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[usp_SaveDictionaryTerm]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[usp_SaveDictionaryTerm]
	@TermID int,	-- Identifier for the term (not the row)
	@Entries udt_DictionaryEntry READONLY, -- Collection of individual entries.
	@Aliases udt_DictionaryTermAlias READONLY -- List of aliases for the term name.
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @r int

	-- Remove any existing entries from the dictionary tables.
	BEGIN
		EXEC @r =  dbo.usp_ClearDictionaryData @TermID
		IF (@@ERROR <> 0) or (@r <>0)
		BEGIN
			
			RAISERROR ( 70001, 16, 1, @TermID, 'Dictionary')
			RETURN 70001
		END 
	END

	-- Bulk update of the dictionary table.
	insert into dbo.dictionary(termid, termname, dictionary, language, audience, apiVers, [object])
	select termid, termname, dictionary, language, audience, apiVers, [object]
	from @Entries

	-- Bulk update of the alias table.
	insert into dbo.DictionaryTermAlias(TermID, Othername, OtherNameType, Language)
	select TermID, Name, NameType, Language
	from @Aliases

END
GO


GO
GRANT EXECUTE ON [dbo].[usp_SaveDictionaryTerm] TO [gatekeeper_role]
GO
