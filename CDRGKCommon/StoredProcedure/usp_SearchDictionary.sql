IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_SearchDictionary]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[usp_SearchDictionary]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Returns a set of table containing up to @maxResults rows of
-- data mathing the specified search criteria

CREATE PROCEDURE [dbo].[usp_SearchDictionary]
	@searchText nvarchar(2000), -- The text to search for
	@Dictionary nvarchar(10), -- The dictionary to search (term/drug/genetic)
	@Language nvarchar(20), -- The language to use for search and results
	@Audience nvarchar(25), -- Target audience.
	@ApiVers nvarchar(10), -- What version of the API? (There may be multiple.)
	@offset int = 0, -- Zero-based offset into the list of results for the first record to return
	@maxResults int = 200, -- The maximum number of results to return

	@matchCount int out -- Returns the total number of rows matching the criteria.

AS
BEGIN


-- Query for the search results, keeping at most @maxResults records.
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
where row > @offset -- Use > because offset is zero-based but row is one-based



-- To get the total match count, we re-run the query without a row limit.
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
