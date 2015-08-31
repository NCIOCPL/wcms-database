IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_SearchExpandDictionary]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[usp_SearchExpandDictionary]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Retursn a table containing term names or aliases which match the
-- specified search criteria

CREATE PROCEDURE [dbo].[usp_SearchExpandDictionary]
	@searchText nvarchar(1000), -- text to match
	@IncludeTypes udt_DictionaryAliasTypeFilter READONLY, -- List of otherNameType values to include
	@Dictionary nvarchar(10), -- The dictionary to search (term/drug/genetic)
	@Language nvarchar(20), -- The language to use for search and results
	@Audience nvarchar(25), -- Target audience.
	@ApiVers nvarchar(10), -- What version of the API? (There may be multiple.)
	@offset int = 0, -- Zero-based offset into the list of results for the first record to return
	@maxResults int = 10, -- The maximum number of results to return

	@matchCount int out -- Returns the total number of rows matching the criteria.

AS
BEGIN

-- Temporary table to hold the search results.  Object will be added in
-- later via a JOIN.
create table #resultSet(
	TermID int,
	MatchedTermName nvarchar(1000)
);

-- Expand is always based on a begins with match the first letter.
select @searchText = @searchText + '%';

-- If no includes were specified, then include everything.
declare @filter_count int;
declare @filter udt_DictionaryAliasTypeFilter;

select @filter_count = count(*) from @IncludeTypes
if(@filter_count = 0)
begin
	-- No JOIN, so this will get everything. Aliases only exist for drugs,
	-- so this won't matter much.
	insert into @filter(NameType)
	select distinct otherNameType
	from dictionaryTermAlias
end
else
begin
	insert into @filter(NameType)
	select nameType
	from @IncludeTypes
end


-- Gather up the full set of results.  Don't worry about
-- sorting or limiting to @maxResults yet because we need to
-- find out the total number of possible matches too.
-- Prepending begins vs contains provides a means of ordering them
-- for the "magic" search type.

-- spanish accent insensitive

IF @language = 'english'
		BEGIN
			insert #resultSet (TermID, MatchedTermName)
			(
				-- Match term name beginning with @searchText
				select TermID, TermName
				from Dictionary
				where TermName like @searchText
				  and Language = @language
				  and Dictionary = @dictionary
			  
			  union

				-- Match alternate name beginning with @searchText
				select d.TermID, dta.OtherName
				from Dictionary d join DictionaryTermAlias dta on d.TermID = dta.TermID
					and dta.OtherNameType in (select NameType from @filter)
				where dta.OtherName like @searchText
				  and d.Language = @language
				  and d.Dictionary = @dictionary
			)
		END
	ELSE
		BEGIN
			insert #resultSet (TermID, MatchedTermName)
			(
				-- Match term name beginning with @searchText
				select TermID, TermName
				from Dictionary
				where TermName  collate modern_spanish_CI_AI like @searchText
				  and Language = @language
				  and Dictionary = @dictionary
			  
			  union

				-- Match alternate name beginning with @searchText
				select d.TermID, dta.OtherName
				from Dictionary d join DictionaryTermAlias dta on d.TermID = dta.TermID
					and dta.OtherNameType in (select NameType from @filter)
				where dta.OtherName  collate modern_spanish_CI_AI  like @searchText
				  and d.Language = @language
				  and d.Dictionary = @dictionary
			)
		END
		
-- Get the number of results matching the search criteria.
select @matchCount = @@RowCount


-- Return the requested search results.
select top (@maxResults) row, TermID, TermName, object
from
(
	select ROW_NUMBER() over (order by rs.MatchedTermName) as row, rs.TermId, rs.MatchedTermName as TermName, d.Object
	from #resultSet rs join dictionary d on rs.termid = d.termid
) oresult
where row > @offset -- Use > because offset is zero-based but row is one-based
	
END
GO


GO
GRANT EXECUTE ON [dbo].[usp_SearchExpandDictionary] TO [webSiteUser_role]
GO
