IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_SaveDictionaryTerm]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[usp_SaveDictionaryTerm]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[usp_SaveDictionaryTerm]
	@TermID int,	-- Identifier for the term (not the row)
	@Entries udt_DictionaryEntry READONLY -- Collection of individual entries.
	-- FUTURE PARAMETER @AliasList udt_DictionaryAlias READONLY -- List of aliases for the term name.
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @r int

	-- Remove any existing entries from the dictionary table.
	BEGIN
		EXEC @r =  dbo.usp_ClearDictionaryData @TermID
		IF (@@ERROR <> 0) or (@r <>0)
		BEGIN
			
			RAISERROR ( 70001, 16, 1, @TermID, 'Dictionary')
			RETURN 70001
		END 
	END

	-- Bulk update from the @Entries parameter
	insert into dbo.dictionary(termid, termname, dictionary, language, audience, apiVers, [object])
	select termid, termname, dictionary, language, audience, apiVers, [object]
	from @Entries
END
GO


GO
GRANT EXECUTE ON [dbo].[usp_SaveDictionaryTerm] TO [gatekeeper_role]
GO
