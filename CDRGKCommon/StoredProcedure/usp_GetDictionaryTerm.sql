IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_GetDictionaryTerm]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[usp_GetDictionaryTerm]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Retrieves a specific term

CREATE PROCEDURE [dbo].[usp_GetDictionaryTerm]
	@TermID int,	-- Identifier for the term (not just a row)
	@Dictionary nvarchar(10),
	@Language nvarchar(20),
	@Audience nvarchar(25),
	@ApiVers nvarchar(10) -- What version of the API (there may be multiple).

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	select TermID, TermName, Dictionary, Language, Audience, ApiVers, object
	from Dictionary
	where TermID = @TermID
	  and Dictionary = @Dictionary
	  and Language = @Language
	  and Audience = @Audience
	  and ApiVers = @ApiVers
	
END
GO


GO
GRANT EXECUTE ON [dbo].[usp_GetDictionaryTerm] TO [webSiteUser_role]
GO
