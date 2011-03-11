
drop procedure dbo.Mig_PDFfile
go
create procedure dbo.Mig_PDFfile
as
select  v.url,
v.nciviewid as viewid,  m.objectid, v.Title as long_title,
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
	releasedate as date_last_modified,
	PostedDate as date_first_published,
	case when DisplayDateMode like '%none%' then 0 else displaydatemode END as date_display_mode,
	ReviewedDate as date_last_reviewed,
	expirationdate as date_next_review,
	isnull((select case when propertyvalue = 'YES' then 'es-us' when propertyvalue is null then 'en-us' else 'en-us' END from viewproperty vp where vp.nciviewid = v.nciviewid and propertyname = 'isSpanishContent'),  'en-us')  as sys_lang,
	(select propertyvalue from viewproperty vp where vp.nciviewid = v.nciviewid and propertyname = 'searchfilter') as legacy_search_filter
	, (select propertyvalue from viewproperty vp1 where propertyname = 'DoNotIndexView' and vp1.nciviewid = v.nciviewid) as do_not_index
	, (select propertyvalue from viewproperty vp1 where propertyname = 'IsPublicationAvailable' and vp1.nciviewid = v.nciviewid) as publication_locator
	from migmap m inner join nciview v on m.nciviewid = v.nciviewid
where [page content type] = 'ncifile'
GO