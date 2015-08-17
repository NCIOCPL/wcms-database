IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_SearchSuggestDictionary]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[usp_SearchSuggestDictionary]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Retrieves a specific term

CREATE PROCEDURE [dbo].[usp_SearchSuggestDictionary]
	@searchText nvarchar(2000),
	@searchType nvarchar(11),
	@Dictionary nvarchar(10),
	@Language nvarchar(20),
	@Audience nvarchar(25),
	@ApiVers nvarchar(10), -- What version of the API (there may be multiple).
	@offset int = 0,
	@maxResults int = 10

AS
BEGIN

create table #resultSet(
	searchType nvarchar(10),
	TermID int,
	TermName nvarchar(1000)
);

declare @beginsTerm nvarchar(100),
		@containsTerm nvarchar(100)

select @beginsTerm = @searchText + '%';
select @containsTerm = '%[- ]' + @searchText + '%';


insert #resultSet (searchType, TermID, TermName)
(
	select 'begins' as searchType, TermID, TermName
	from Dictionary
	where TermName like @beginsTerm
	  and Language = @language
	  and Dictionary = @dictionary
	  and (@searchType = 'magic' or @searchType = 'begins')
union
	select 'begins' as searchType, d.TermID, dta.OtherName
	from Dictionary d join DictionaryTermAlias dta on d.TermID = dta.TermID
	where dta.OtherName like @beginsTerm
	  and d.Language = @language
	  and d.Dictionary = @dictionary
	  and (@searchType = 'magic' or @searchType = 'begins')
)

insert #resultSet (searchType, TermID, TermName)
(
	select 'contains' as searchType, TermID, TermName
	from Dictionary
	where TermName like @containsTerm
	  and Language = @language
	  and Dictionary = @dictionary
	  and (@searchType = 'magic' or @searchType = 'contains')
	  and TermID not in (select TermID from #resultSet)
union
	select 'contains' as searchType, d.TermID, dta.OtherName
	from Dictionary d join DictionaryTermAlias dta on d.TermID = dta.TermID
		and dta.Othername not in(select TermName from #resultSet)
	where dta.OtherName like @containsTerm
	  and d.Language = @language
	  and d.Dictionary = @dictionary
	  and (@searchType = 'magic' or @searchType = 'begins')
)


--select COUNT(*) as possible
--from #resultSet

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
