if object_id('autosuggest_en_search') is not null
drop procedure autosuggest_en_search
go
create procedure dbo.autosuggest_en_search (@t varchar(100))
as
BEGIN
	
	declare @s varchar(100)
	select @s = ltrim(rtrim(@t))

	select @s = isnull( termname , @s)
					from dbo.autosuggest_en_misspell
					where misspell = @s 

	if @s like '% %'
		BEGIN
				select top 10  termname
				from (select distinct termname , weight from dbo.autosuggest_english) a
				where termname like @s + '%'
					or termname like '% ' + @s+ '%'
				order by weight desc, termname
		END

		ELSE		
			BEGIN
					select termname from
					(
					select distinct top 10 termname, weight
						from dbo.autosuggest_english
						where termword like  @s + '%'
						order by weight desc, termname
					) a
					order by weight desc, termname
		END

END

go
grant execute on autosuggest_en_search to CDEUser
