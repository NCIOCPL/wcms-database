drop procedure dbo.Mig_contentSearch
go
create procedure dbo.Mig_contentSearch
as
select   
'cgvContentSearch' as contentType,
		v.nciviewid as viewid,v.Title as long_title,
	v.ShortTitle as short_title,
	v.Description as long_description,
	(select top 1 right(currenturl, charindex('/', reverse(currenturl))-1) 
		from prettyurl p 
		where p.nciviewid = v.nciviewid order by isprimary desc, isroot desc) 
		as pretty_url_name,
		dbo.Mig_getPrettyURL(v.nciviewid)
		as prettyurl,
	MetaKeyword as meta_keywords,
	Metadescription as meta_description,
	v.releasedate as date_last_modified,
	v.PostedDate as date_first_published,
	case when v.DisplayDateMode like '%none%' then 0 else v.displaydatemode END as date_display_mode,
	v.ReviewedDate as date_last_reviewed,
	v.expirationdate as date_next_review,
	isnull((select case when propertyvalue = 'YES' then 'es-us' when propertyvalue is null then 'en-us' else 'en-us' END from viewproperty vp where vp.nciviewid = v.nciviewid and propertyname = 'isSpanishContent'),  'en-us')  as sys_lang,
	(select propertyvalue from viewproperty vp where vp.nciviewid = v.nciviewid and propertyname = 'searchfilter') as legacy_search_filter
	, (select case propertyvalue when 'true' then 1 else 0 END 
		from viewproperty vp1 where propertyname = 'DoNotIndexView' and vp1.nciviewid = v.nciviewid) as do_not_index
	, (select propertyvalue from viewproperty vp1 where propertyname = 'IsPublicationAvailable' and vp1.nciviewid = v.nciviewid) as publication_locator
	, (select propertyvalue from viewproperty vp1 where propertyname = 'VolumeNumber' and vp1.nciviewid = v.nciviewid) as volume_number
	, (select case propertyvalue when 'NO' THEN 0 ELSE 1 END
		from viewproperty vp1 where propertyname = 'IsPrintAvailable' and vp1.nciviewid = v.nciviewid) as email_available
	, (select case propertyvalue when 'NO' THEN 0 ELSE 1 END
		from viewproperty vp1 where propertyname = 'IsPrintAvailable' and vp1.nciviewid = v.nciviewid) as share_available
	, (select case propertyvalue when 'NO' THEN 0 ELSE 1 END
		from viewproperty vp1 where propertyname = 'IsPrintAvailable' and vp1.nciviewid = v.nciviewid) as print_available
	
, convert(xml,d.data).value('/Search[1]/ResultsPerPage[1]', 'int')  as records_per_page  
 ,convert(xml,d.data).value('/Search[1]/MaximumResults[1]', 'int') as max_results  
 ,convert(xml,d.data).value('/Search[1]/SearchFilter[1]', 'varchar(255)') as search_filter  
 ,convert(xml,d.data).value('/Search[1]/NotSearchFilter[1]', 'varchar(255)') as exclude_search_filter  
 ,convert(xml,d.data).value('/Search[1]/SortOrder[1]', 'int') as results_sort_order  
 ,case convert(xml,d.data).value('/Search[1]/Language[1]', 'varchar(50)') 
		WHEN 'SPANISH' THEN 'es'
		ELSE 'en'
	 END as language
 ,case convert(xml,d.data).value('/Search[1]/SearchType[1]', 'varchar(50)') 
	when 'Keyword' then 'keyword'
			when 'NoParam' then 'no_parameter'
			when 'KeywordWithDate' then 'keyword_with_date'
			END	
as search_type  
 , 
case convert(xml,d.data).value('/Search[1]/SearchResultStyle[1]', 'varchar(255)') 
		when 'list' then 'no_media_links' when 'MultiMediaList' then 'media_links' ELSE 'no_media_links' END
as template
from viewobjects vo inner join document d on d.documentid = vo.objectid
inner join nciview v on v.nciviewid = vo.nciviewid
where type = 'virsearch'
and v.nciviewid in (select nciviewid from migmap)
and v.nciviewid <> '2F5AF9A8-0E7E-44E2-96C7-C3CB12CD1775'







