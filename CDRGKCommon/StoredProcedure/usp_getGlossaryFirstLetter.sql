if object_id('usp_getGlossaryFirstLetter') is not null
	drop procedure dbo.usp_getGlossaryFirstLetter
go
create procedure dbo.usp_getGlossaryFirstLetter(@language varchar(80) = 'english')
AS
BEGIN

	if @language = 'english'
		select distinct left(termname,1)
		from dbo.glossaryterm
		where termname like '[a-zA-Z]%'
		union 
		select '#'
		where exists 
		(select * from dbo.glossaryterm where termname not like '[a-zA-Z]%')
		order by 1
	ELSE
		select distinct left(spanishtermname collate modern_spanish_CI_AI,1)
		from dbo.glossaryterm
		where spanishtermname collate modern_spanish_CI_AI  like '[a-zA-Z]%'
		union
		select '#'
		where exists 
		(select * from dbo.glossaryterm where spanishtermname collate modern_spanish_CI_AI not like '[a-zA-Z]%')
		order by 1


END
go
grant execute on dbo.usp_getGlossaryFirstLetter to websiteuser_role


--exec usp_getGlossaryFirstLetter 'spanish'