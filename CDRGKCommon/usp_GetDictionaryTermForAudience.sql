if object_id('usp_GetDictionaryTermForAudience') is not null
drop procedure dbo.usp_GetDictionaryTermForAudience
GO


create procedure dbo.usp_GetDictionaryTermForAudience (
				@TermID int,     -- Identifier for the term (not just a row)
                @Language nvarchar(20),
                @PreferredAudience nvarchar(25),
                @ApiVers nvarchar(10) -- What version of the API (there may be multiple).
)

AS
BEGIN

	SET NOCOUNT ON;

	if exists (select *
					from dbo.Dictionary
					where TermID = @TermID
					  and Language = @Language
					  and Audience = @PreferredAudience
					  and ApiVers = @ApiVers
					  )
			select TermID, TermName, Dictionary, Language, Audience, ApiVers, object
			from dbo.Dictionary
			where TermID = @TermID
			  and Language = @Language
			  and Audience = @PreferredAudience
			  and ApiVers = @ApiVers
		ELSE
			select TermID, TermName, Dictionary, Language, Audience, ApiVers, object
				from dbo.Dictionary
				where TermID = @TermID
				  and Language = @Language
				   and ApiVers = @ApiVers


END 
GO
Grant execute on dbo.usp_GetDictionaryTermForAudience to websiteuser_role