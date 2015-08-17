set statistics time on

SET NOCOUNT ON;

declare @searchType nvarchar(11);
select @searchType = 'magic';

declare @searchTerm nvarchar(100);
select @searchTerm = '%';

declare @language nvarchar(11);
select @language = 'English';

declare @dictionary nvarchar(11);
select @dictionary = 'drug';


create table #resultSet(
	searchType nvarchar(10),
	TermID int,
	TermName nvarchar(1000)
);

declare @beginsTerm nvarchar(100),
		@containsTerm nvarchar(100)

select @beginsTerm = @searchTerm + '%';
select @containsTerm = '%' + @searchTerm + '%';


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

--select row, TermID, TermName, Dictionary, Language, Audience, ApiVers, object
select top 200 row, TermID, TermName
from
(
	select ROW_NUMBER() over (order by searchType, termName) as row, *
	from #resultSet
) oresult

drop table #resultSet;

