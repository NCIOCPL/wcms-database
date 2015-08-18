IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_SearchDictionary]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[usp_SearchDictionary]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Retrieves a specific term

CREATE PROCEDURE [dbo].[usp_SearchDictionary]
	@searchText nvarchar(2000),
	@Dictionary nvarchar(10),
	@Language nvarchar(20),
	@Audience nvarchar(25),
	@ApiVers nvarchar(10), -- What version of the API? (There may be multiple.)
	@offset int = 0,
	@maxResults int = 200,
	@matchCount int out

AS
BEGIN



select top(@maxResults) row, TermID, TermName, Dictionary, Language, Audience, ApiVers, object
from
(
	select ROW_NUMBER() over (order by TermName ) as row, *
	from Dictionary
	where Dictionary = @dictionary
	  and Language = @language
	  and Audience = @Audience
	  and ApiVers = @ApiVers
	  and (TermName like @searchText
		   or TermID in
			(select termid from DictionaryTermAlias where Othername like @searchText)
		)
) filtered
where row > @offset

-- Get the total number of matches.
select @matchCount = COUNT(*)
from Dictionary
where Dictionary = @dictionary
  and Language = @language
  and Audience = @Audience
  and ApiVers = @ApiVers
  and (TermName like @searchText
       or TermID in
		(select termid from DictionaryTermAlias where Othername like @searchText)
	)

	
END
GO


GO
GRANT EXECUTE ON [dbo].[usp_SearchDictionary] TO [webSiteUser_role]
GO
