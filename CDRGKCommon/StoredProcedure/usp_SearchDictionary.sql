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

create table #resultSet(
	TermID int,
	TermName nvarchar(1000)
);

declare @termCount int,
		@aliasCount int;


insert #resultSet (TermID, TermName)
	select top(@maxResults) TermID, TermName
	from Dictionary
	where TermName like @searchText
	  and Language = @language
	  and Dictionary = @dictionary
	order by TermName
	
select @termCount = COUNT(*) 
	from Dictionary
	where TermName like @searchText
	  and Language = @language
	  and Dictionary = @dictionary


insert #resultSet (TermID, TermName)
	select top(@maxResults) d.TermID, dta.OtherName
	from Dictionary d join DictionaryTermAlias dta on d.TermID = dta.TermID
	where dta.OtherName like @searchText
	  and d.Language = @language
	  and d.Dictionary = @dictionary
	order by TermName

select @aliasCount = COUNT(*)
	from Dictionary d join DictionaryTermAlias dta on d.TermID = dta.TermID
	where dta.OtherName like @searchText
	  and d.Language = @language
	  and d.Dictionary = @dictionary

select @matchCount = @termCount + @aliasCount;


select top (@maxResults) row, TermID, TermName --, Dictionary, Language, Audience, ApiVers, object
from
(
	select ROW_NUMBER() over (order by termName) as row, *
	from #resultSet
) oresult
where row > @offset


	
END
GO


GO
GRANT EXECUTE ON [dbo].[usp_SearchDictionary] TO [webSiteUser_role]
GO
