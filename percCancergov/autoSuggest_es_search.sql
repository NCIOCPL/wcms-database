if object_id('autosuggest_es_search') is not null
drop procedure autosuggest_es_search
go
create procedure dbo.autosuggest_es_search (@t varchar(100))
as
BEGIN
	
	declare @s varchar(100)
	select @s = ltrim(rtrim(@t))

	select @s = isnull( termname , @s)
					from dbo.autosuggest_es_misspell
					where misspell = @s 

	if @s like '% %'
		BEGIN
				select top 10  termname
				from (select distinct termname , weight from dbo.autosuggest_spanish) a
				where termname like @s + '%'
					or termname like '% ' + @s+ '%'
				order by weight desc, termname
		END

		ELSE		
			BEGIN

					select termname from
					(
					select distinct top 10 termname, weight
						from dbo.autosuggest_spanish
						where termword like  @s + '%'
						order by weight desc, termname
					) a
					order by weight desc, termname
		END

END

go

grant execute on autosuggest_es_search to CDEUser

