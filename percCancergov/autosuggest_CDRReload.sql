if object_id('autosuggest_CDRreload') is not null
	drop procedure autosuggest_CDRreload
GO
create procedure autosuggest_CDRreload
as
BEGIN
	
	--- term
	delete from autosuggest_english where category = 10
	insert into autosuggest_english(termname, category, weight, termword)
	select  distinct termname, 10, 1 ,s.objectid
	from cdrlivegk..glossaryterm t  cross apply dbo.autosuggest_stringSplit(termname) s
	where 
		termname not in (select termname from autosuggest_english)
		and termname not in (select termname from autosuggest_en_exclude)
	order by s.objectid

	update a
	set a.weight  = 1 , a.category = 10
	from autosuggest_english a inner join cdrlivegk..glossaryterm b on a.termname  = b.termname
	where a.category > 10



	delete from autosuggest_spanish where category = 10
	insert into autosuggest_spanish(termname, category, weight, termword)
	select distinct spanishtermname, 10, 1 , s.objectid
	from cdrlivegk..glossaryterm t  
	cross apply dbo.autosuggest_stringSplit(spanishtermname) s
	where spanishtermname is not null
	and spanishtermname collate modern_spanish_CI_AI  
			not in (select termname from autosuggest_spanish) 
	and Spanishtermname collate modern_spanish_CI_AI 
			not in (select termname from autosuggest_es_exclude)
	order by s.objectid


	update a
	set a.weight  = 1 , a.category = 10
	from autosuggest_spanish a inner join cdrlivegk..glossaryterm b on a.termname  = b.spanishtermname collate Modern_Spanish_CI_AI
	where a.category > 10
END
GO


