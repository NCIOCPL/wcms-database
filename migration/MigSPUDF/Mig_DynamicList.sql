drop procedure dbo.Mig_DynamicList
go

create procedure dbo.Mig_DynamicList
as 
	select 
	m.nciviewid as viewid, m.[page content type],
	[Slot],
	[Snippet Content Type],
	case convert(xml,d.data).value('/Search[1]/SearchResultStyle[1]', 'varchar(255)') 
		when 'list' then 'cgvSnDynamicListNoMedia' when 'MultiMediaList' then 'cgvSnDynamicListMedia' ELSE 'cgvSnDynamicListNoMedia' END as [Snippet Template]	, 
	m.objectid, 
d.title as long_title,
	convert(xml,d.data).value('/Search[1]/ResultsPerPage[1]', 'int')  as records_per_page
	,convert(xml,d.data).value('/Search[1]/MaximumResults[1]', 'int') as max_results
	,convert(xml,d.data).value('/Search[1]/SearchFilter[1]', 'varchar(255)') as search_filter
	,convert(xml,d.data).value('/Search[1]/NotSearchFilter[1]', 'varchar(255)') as exclude_search_filter
	,convert(xml,d.data).value('/Search[1]/SortOrder[1]', 'int') as results_sort_order
	,CASE convert(xml,d.data).value('/Search[1]/Language[1]', 'varchar(50)') 
		WHEN 'SPANISH' THEN 'es'
		ELSE 'en'
	 END as language
	,	case convert(xml,d.data).value('/Search[1]/SearchType[1]', 'varchar(50)') 
			when 'Keyword' then 'keyword'
			when 'NoParam' then 'no_parameter'
			when 'KeywordWithDate' then 'keyword_with_date'
			END
		as search_type
	,convert(xml,d.data).value('/Search[1]/SearchParameters[1]/Keyword[1]', 'varchar(255)') as keyword
	,dateadd(mm,
	convert(xml,d.data).value('/Search[1]/SearchParameters[1]/StartDate[1]/Month[1]', 'int') -1, 
	convert(xml,d.data).value('/Search[1]/SearchParameters[1]/StartDate[1]/Year[1]', 'datetime')) 
	as start_date
	,dateadd(mm,
	convert(xml,d.data).value('/Search[1]/SearchParameters[1]/EndDate[1]/Month[1]', 'int') -1, 
	convert(xml,d.data).value('/Search[1]/SearchParameters[1]/EndDate[1]/Year[1]', 'datetime')) 
	as end_date
	from migmap m inner join dbo.document d on m.objectid = d.documentid
	where [snippet content type] = 'cgvDynamicList'
GO


