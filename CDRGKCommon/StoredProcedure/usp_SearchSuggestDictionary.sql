IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_SearchSuggestDictionary]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[usp_SearchSuggestDictionary]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Retursn a table containing term names or aliases which match the
-- specified search criteria

CREATE PROCEDURE [dbo].[usp_SearchSuggestDictionary]
	@searchText nvarchar(1000), -- text to match
	@searchType nvarchar(11), -- 'begins', 'contains' or 'magic' (begins followed by contains)
	@Dictionary nvarchar(10), -- The dictionary to search (term/drug/genetic)
	@Language nvarchar(20), -- The language to use for search and results
	@Audience nvarchar(25), -- Target audience.
	@ApiVers nvarchar(10), -- What version of the API? (There may be multiple.)
	@maxResults int = 10, -- The maximum number of results to return

	@matchCount int out -- Returns the total number of rows matching the criteria.

AS
BEGIN

-- Temporary table to hold the search results.
create table #resultSet(
	searchType nvarchar(10),
	TermID int,
	TermName nvarchar(1000)
);

-- Separate comparison values for begins vs contains. Doing this here vs. the
-- middle tier allows us to do the "magic" search with the same set of queries..
declare @beginsTerm nvarchar(1000),
		@containsTerm nvarchar(1000)

select @beginsTerm = @searchText + '%';
select @containsTerm = '%[- ]' + @searchText + '%';

-- Gather up the full set of results.  Don't worry about
-- sorting or limiting to @maxResults yet because we need to
-- find out the total number of possible matches too.
-- Prepending begins vs contains provides a means of ordering them
-- for the "magic" search type.

-- spanish search uses spanish accent insensive locale. 

IF @Language = 'english'
		BEGIN
			insert #resultSet (searchType, TermID, TermName)
		(
			-- Match term name beginning with @beginsTerm
			select 'begins' as searchType, TermID, TermName
			from Dictionary with (nolock)
			where TermName like @beginsTerm
			  and Language = @language
			  and Dictionary = @dictionary
			  and (@searchType = 'magic' or @searchType = 'begins')
		  
		  union

			-- Match alternate name beginning with @beginsTerm
			select 'begins' as searchType, d.TermID, dta.OtherName
			from Dictionary d with (nolock) join DictionaryTermAlias dta with (nolock) on d.TermID = dta.TermID
			where dta.OtherName like @beginsTerm
			  and d.Language = @language
			  and d.Dictionary = @dictionary
			  and (@searchType = 'magic' or @searchType = 'begins')

		  union

			-- Match term name containing @containsTerm
			select 'contains' as searchType, TermID, TermName
			from Dictionary with (nolock)
			where TermName like @containsTerm
			  and Language = @language
			  and Dictionary = @dictionary
			  and (@searchType = 'magic' or @searchType = 'contains')
			  and TermID not in (select TermID from #resultSet)

		union

			-- Match alternate name containing @containsTerm
			select 'contains' as searchType, d.TermID, dta.OtherName
			from Dictionary d with (nolock) join DictionaryTermAlias dta with (nolock) on d.TermID = dta.TermID
				and dta.Othername not in(select TermName from #resultSet)
			where dta.OtherName like @containsTerm
			  and d.Language = @language
			  and d.Dictionary = @dictionary
			  and (@searchType = 'magic' or @searchType = 'begins')
		)
	END
	ELSE
		BEGIN
			insert #resultSet (searchType, TermID, TermName)
			(
				-- Match term name beginning with @beginsTerm
				select 'begins' as searchType, TermID, TermName
				from Dictionary with (nolock)
				where TermName  collate modern_spanish_CI_AI  like @beginsTerm
				  and Language = @language
				  and Dictionary = @dictionary
				  and (@searchType = 'magic' or @searchType = 'begins')
			  
			  union

				-- Match alternate name beginning with @beginsTerm
				select 'begins' as searchType, d.TermID, dta.OtherName
				from Dictionary d with (nolock) join DictionaryTermAlias dta with (nolock) on d.TermID = dta.TermID
				where dta.OtherName  collate modern_spanish_CI_AI  like @beginsTerm
				  and d.Language = @language
				  and d.Dictionary = @dictionary
				  and (@searchType = 'magic' or @searchType = 'begins')

			  union

				-- Match term name containing @containsTerm
				select 'contains' as searchType, TermID, TermName
				from Dictionary with (nolock)
				where TermName  collate modern_spanish_CI_AI  like @containsTerm
				  and Language = @language
				  and Dictionary = @dictionary
				  and (@searchType = 'magic' or @searchType = 'contains')
				  and TermID not in (select TermID from #resultSet)

			union

				-- Match alternate name containing @containsTerm
				select 'contains' as searchType, d.TermID, dta.OtherName
				from Dictionary d with (nolock) join DictionaryTermAlias dta with (nolock) on d.TermID = dta.TermID
					and dta.Othername not in(select TermName from #resultSet)
				where dta.OtherName  collate modern_spanish_CI_AI  like @containsTerm
				  and d.Language = @language
				  and d.Dictionary = @dictionary
				  and (@searchType = 'magic' or @searchType = 'begins')
			)
	END

-- Get the number of results matching the search criteria.
select @matchCount = @@RowCount


-- Return the requested search results.
select top (@maxResults) row, TermID, TermName --, Dictionary, Language, Audience, ApiVers, object
from
(
	select ROW_NUMBER() over (order by searchType, termName) as row, *
	from #resultSet
) oresult






	
END
GO


GO
GRANT EXECUTE ON [dbo].[usp_SearchSuggestDictionary] TO [webSiteUser_role]
GO
