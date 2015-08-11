IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_ClearDictionaryData]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[usp_ClearDictionaryData]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[usp_ClearDictionaryData]
	@TermID int	-- Identifier for the term (not just a row)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Remove any existing entries from the dictionary table.
	delete
	from dbo.Dictionary  with (TABLOCKX)
	where TermId = @TermID
	
	delete
	from dbo.DictionaryTermAlias  with (TABLOCKX)
	where TermID = @TermID
	
END
GO


GO
GRANT EXECUTE ON [dbo].[usp_ClearDictionaryData] TO [gatekeeper_role]
GO
