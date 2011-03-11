drop procedure Mig_MSmicrositeIndex
go
create procedure Mig_MSmicrositeIndex
as
select * from MSmicrositeindex
GO



-------------------------------------------------
-------------------------------------------------
drop procedure Mig_MSshellpageMetaData 
go
create procedure Mig_MSshellpageMetaData 
as  
BEGIN  
  
 select   distinct 
  (select top 1 [Content Type] from microsites s where s.nciviewid = v.nciviewid
	and [content type] <> 'ncilist')
   as contentType,  
nciviewid as viewid,
	Title as long_title,  
 ShortTitle as short_title,  
 Description as long_description,  
  (select 
	top 1 case when urlname is not null 
	then urlname 
	else right(folder, charindex ('/',reverse(folder))-1) END
	from microsites s where s.nciviewid = v.nciviewid order by urlname desc)
	as pretty_url_name,
	(select top 1 folder + case when urlname is null then '' else '/'+ urlname END 
		from microsites s where s.nciviewid = v.nciviewid order by urlname desc)
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
 , (select propertyvalue from viewproperty vp1 where propertyname = 'videoURL' and vp1.nciviewid = v.nciviewid) as video  
 , (select propertyvalue from viewproperty vp1 where propertyname = 'imageURL' and vp1.nciviewid = v.nciviewid) as image  
 , (select propertyvalue from viewproperty vp1 where propertyname = 'audioURL' and vp1.nciviewid = v.nciviewid) as audio  
 , (select propertyvalue from viewproperty vp1 where propertyname = 'QandAURL' and vp1.nciviewid = v.nciviewid) as news_qanda  
 , dbo.mig_getbacktotop(v.nciviewid, NULL) as backtotop  
 , dbo.mig_getshowpagetitle(v.nciviewid, NULL) as showpagetitle  
 from nciview v where v.nciviewid in 
	( select nciviewid from microsites 
		where [content type]  in ( 'ncigeneral', 'ncilandingPage')
		and template = 'singlepagecontent')
union
select   distinct 
  (select top 1 [Content Type] from microsites s where s.objectid = v.documentid
	)
   as contentType,  
	--!!viewID for priority =1
	case when priority = 1 then vo.nciviewid ELSE documentid END  as viewid,
	v.Title as long_title,  
 v.ShortTitle as short_title,  
 v.Description as long_description,  
  (select 
	top 1 case when urlname is not null 
	then urlname 
	else right(folder, charindex ('/',reverse(folder))-1) END
	from microsites s where s.objectid = v.documentid order by urlname desc)
	as pretty_url_name,
	(select top 1 folder + case when urlname is null then '' else '/'+ urlname END 
		from microsites s where s.objectid = v.documentid order by urlname desc)
  as prettyurl,  
	vv.MetaKeyword as meta_keywords,  
 vv.Metadescription as meta_description,  
 v.releasedate as date_last_modified,  
 v.PostedDate as date_first_published,  
 case when v.DisplayDateMode like '%none%' then 0 else v.displaydatemode END as date_display_mode,  
 vv.ReviewedDate as date_last_reviewed,  
 v.expirationdate as date_next_review,  
 isnull((select case when propertyvalue = 'YES' then 'es-us' when propertyvalue is null then 'en-us' else 'en-us' END from viewproperty vp where vp.nciviewid = vv.nciviewid and propertyname = 'isSpanishContent'),  'en-us')  as sys_lang,  
 (select propertyvalue from viewproperty vp where vp.nciviewid = vv.nciviewid and propertyname = 'searchfilter') as legacy_search_filter  
 , (select case propertyvalue when 'true' then 1 else 0 END 
		from viewproperty vp1 where propertyname = 'DoNotIndexView' and vp1.nciviewid = vv.nciviewid) as do_not_index
	, (select propertyvalue from viewproperty vp1 where propertyname = 'IsPublicationAvailable' and vp1.nciviewid = vv.nciviewid) as publication_locator
	, (select propertyvalue from viewproperty vp1 where propertyname = 'VolumeNumber' and vp1.nciviewid = vv.nciviewid) as volume_number
	, (select case propertyvalue when 'NO' THEN 0 ELSE 1 END
		from viewproperty vp1 where propertyname = 'IsPrintAvailable' and vp1.nciviewid = vv.nciviewid) as email_available
	, (select case propertyvalue when 'NO' THEN 0 ELSE 1 END
		from viewproperty vp1 where propertyname = 'IsPrintAvailable' and vp1.nciviewid = vv.nciviewid) as share_available
	, (select case propertyvalue when 'NO' THEN 0 ELSE 1 END
		from viewproperty vp1 where propertyname = 'IsPrintAvailable' and vp1.nciviewid = vv.nciviewid) as print_available
 , (select propertyvalue from viewproperty vp1 where propertyname = 'videoURL' and vp1.nciviewid = vv.nciviewid) as video  
 , (select propertyvalue from viewproperty vp1 where propertyname = 'imageURL' and vp1.nciviewid = vv.nciviewid) as image  
 , (select propertyvalue from viewproperty vp1 where propertyname = 'audioURL' and vp1.nciviewid = vv.nciviewid) as audio  
 , (select propertyvalue from viewproperty vp1 where propertyname = 'QandAURL' and vp1.nciviewid = vv.nciviewid) as news_qanda  
 , dbo.mig_getbacktotop(vv.nciviewid, NULL) as backtotop  
 , dbo.mig_getshowpagetitle(vv.nciviewid, NULL) as showpagetitle  
  from document v  
	inner join viewobjects vo on v.documentid = vo.objectid
	inner join nciview vv on vv.nciviewid = vo.nciviewid
	where v.documentid in 
	( select objectid from microsites 
		where [content type]  in ( 'ncigeneral', 'ncilandingpage')
		and template = 'multipagecontent')
END  
GO


------------
drop function Mig_MSSinglePageDocument 
go

create function Mig_MSSinglePageDocument 
(@nciviewid uniqueidentifier )  
returns @r table (objectid uniqueidentifier, Slot varchar(150), bodyfield varchar(max), priority int,   
[snippet content type] varchar(250), [Snippet Template] varchar(250), long_title varchar(500))  
as  
BEGIN  
   
  insert into @r  

    select distinct vo.objectid, 'bodyfield' as slot, isnull(convert(varchar(max),data),'')  , vo.priority , NULL, NULL,NULL  
    from viewobjects vo inner join document d on d.documentid = vo.objectid  
    inner join microsites m on m.nciviewid = vo.nciviewid and m.objectid = vo.objectid  
    where vo.nciviewid = @nciviewid   
    and [content type] in (  
         'cgvClinicalTrialResult',  
         'cgvDrugInfoSummary',  
         'cgvFactSheet',  
         'cgvFeaturedClinicalTrial',  
         'cgvPressRelease',  
         'nciGeneral',  
         'nciHome',  
         'cgvCancerTypeHome',  
         'nciLandingPage')  
   and vo.priority =  
    (select min(vo.priority)   
      from viewobjects vo inner join document d on d.documentid = vo.objectid   
      where vo.nciviewid = @nciviewid and vo.type <> 'search'  
     )  
      and vo.type <> 'search'  
     union 
     select distinct vo.objectid, 'cgvbody' as slot, isnull(convert(varchar(max),data),'')  , vo.priority, 'nciDocFragment', 'cgvSnBody', d.title  
    from viewobjects vo inner join document d on d.documentid = vo.objectid  
    inner join microsites m on m.nciviewid = vo.nciviewid and m.objectid = vo.objectid  
    where vo.nciviewid = @nciviewid   
    and [content type] in (  
         'cgvClinicalTrialResult',  
         'cgvDrugInfoSummary',  
         'cgvFactSheet',  
         'cgvFeaturedClinicalTrial',  
         'cgvPressRelease',  
         'nciGeneral',  
         'nciHome',  
         'cgvCancerTypeHome',  
         'nciLandingPage')  
   and vo.priority >(select min(vo.priority)   
      from viewobjects vo inner join document d on d.documentid = vo.objectid   
      where vo.nciviewid = @nciviewid and 
		vo.type <> 'search'  
     )  
      and vo.type <> 'search'  
	
 return  
END  
GO

--??

drop function Mig_MSBreakPageDocument 
go
create function Mig_MSBreakPageDocument 
(@nciviewid uniqueidentifier )  
returns @r table (viewid uniqueidentifier, Slot varchar(150), bodyfield varchar(max), priority int,   
[snippet content type] varchar(250), [Snippet Template] varchar(250), long_title varchar(500))  
as  
BEGIN  
   
  insert into @r 
	select s.nciviewid as viewid, 'bodyfield' as field, 
	convert(varchar(max),isnull(data,''))  , 1 , NULL, NULL,NULL  
    from viewobjects vo inner join document d on d.documentid = vo.objectid 
	inner join microsites s on s.objectid = d.documentid
	where template = 'multipagecontent'
	and s.priority =1
	and s.nciviewid = @nciviewid 
	union
	select vo.objectid as viewid, 'bodyfield' as field, 
	convert(varchar(max),isnull(data,''))  , 1 , NULL, NULL,NULL  
    from viewobjects vo inner join document d on d.documentid = vo.objectid 
	inner join microsites s on s.objectid = d.documentid
	where template = 'multipagecontent'
	and s.priority <> 1
	and s.objectid = @nciviewid


return
END

GO

drop procedure dbo.Mig_MSPDFfile  
go
create procedure dbo.Mig_MSPDFfile  
as  
select  v.url,  
v.nciviewid as viewid,  m.objectid, v.Title as long_title,  
 v.ShortTitle as short_title,  
 v.Description as long_description,  
 (select 
	top 1 case when urlname is not null 
	then urlname 
	else right(folder, charindex ('/',reverse(folder))-1) END
	from microsites s where s.nciviewid = v.nciviewid order by urlname desc)
	as pretty_url_name,
	(select top 1 folder + case when urlname is null then '' else '/'+ urlname END 
		from microsites s where s.nciviewid = v.nciviewid order by urlname desc)
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
 from microsites m inner join nciview v on m.nciviewid = v.nciviewid  
where [content type] = 'ncifile' 

go
-------------
---------------------

---List is for SinglePageContent ONLY

drop procedure dbo.Mig_MSpagelist  
go

create procedure dbo.Mig_MSpagelist  
as  
  
select distinct m.nciviewid as viewid, 
s.[content type] as [page content type],  
  m.objectid, slot, [Snippet Content Type],    
  [Snippet Template]  as [Snippet Template]  
  , l.listname as list_title, l.listdesc as list_description, vo.priority  
 , (select top 1 currenturl from prettyurl p where p.nciviewid = l.nciviewid order by isprimary desc, isroot desc) as url  
  , (select case when propertyvalue = 'true' then 0 else NULL END from dbo.viewobjectproperty vop   
   where vop.nciviewobjectid = vo.nciviewobjectid and propertyname = 'suppresspagetitle')  
   as showpagetitle  
 from migmapmicrosites m inner join list l on m.objectid = l.listid   
 inner join dbo.viewobjects vo on vo.nciviewid = m.nciviewid and m.objectid = vo.objectid  
inner join microsites s on s.nciviewid = m.nciviewid and s.[content type] <> 'ncilist'
  where [snippet content type] = 'ncilist'  
order by m.nciviewid, priority  
GO


-------------------------------------
---------------this is for single Page content
drop procedure mig_MSContentheader
go
create procedure mig_MSContentheader
as
select distinct m.nciviewid ,  s.[content type] as [page content type], 
m.objectid, vo.priority  
,'cgvContentHeader' as slot, 'nciContentHeader' as [Snippet Content Type],
'cgvSnContentHeader' as [Snippet Template]  
from migmapmicrosites m  inner join viewobjects vo on vo.objectid = m.objectid and vo.nciviewid = m.nciviewid  
inner join microsites s on s.nciviewid = m.nciviewid
where viewobjecttype like '%header%' 
and s.template = 'singlepagecontent'
and s.[content type] <> 'ncilist'
GO

---------- this is for Multipagecontent

drop procedure mig_MSNavContentHeader
go
create procedure mig_MSNavContentHeader
as
select distinct s.folder + case when s.urlname is null then '' else '/'+ urlname END
as folder
, m.objectid
,'cgvContentHeader' as slot, 'nciContentHeader' as [Snippet Content Type],
'cgvSnContentHeader' as [Snippet Template]  
from migmapmicrosites m  
inner join viewobjects vo on vo.objectid = m.objectid 
and vo.nciviewid = m.nciviewid  
inner join microsites s on s.nciviewid = m.nciviewid and s.priority =1
where m.viewobjecttype like '%header%' 
and s.template = 'MultiPageContent'
GO
--------------------
drop procedure dbo.Mig_MSSectionNav
go
create procedure dbo.Mig_MSSectionNav
as
select
distinct folder as folder
, 'nciSectionNav' as [content type], case folder when '/aboutnci/recovery' then 2 else 1 END as levels_to_show
, s.Title + ' section nav' as section_nav_title
, 'rffNavon' as [dependent content type]
, 'nciSectionNavRootNavon' as slot, 'nciSnSectionNavRoot' as template
from microsites s
where level =0

GO


drop procedure dbo.Mig_MSNavon
go
create procedure dbo.Mig_MSNavon
as
select distinct folder ,
[content type] as [dependent content type], 
'rffNavLandingPage' as slot,
'cgvSnTitleLink' as template,
'nciSectionNav' as [dependent content type2],
'cgvSectionNav' as slot2, 
'cgvSnSectionNav' as template2
from microsites v
where level=0
GO


------------
-----------------
--- Single page content ONLY!
drop procedure dbo.mig_MSrelatedpage
GO
create procedure dbo.mig_MSrelatedpage
as
-- normal  
select   distinct 
 m.nciviewid as viewid, s.[content type] as [page content type],  
 slot as Slot, s1.[content type] as [content type]  
 ,  m.[snippet item template]  as template  
 , li.priority  
  , convert(varchar(80), li.nciviewid)  as nciviewid
from migmapmicrosites m inner join dbo.listitem li on m.objectid = li.listid  
inner join microsites s on s.nciviewid = m.nciviewid 
left outer join microsites s1 on s1.nciviewid = li.nciviewid and s1.[content type]  <> 'ncilist'
where slot = 'cgvrelatedpages'  and s.[content type] <> 'ncilist'
order by 1, priority
 GO

---------------------


drop procedure dbo.Mig_MSpromoURL
go

create procedure dbo.Mig_MSpromoURL
as
 select distinct s.nciviewid as viewid, 
s.[content type] as [page content type] 
  , currenturl as promo_url  
 , currenturl as promo_url_name  
 from microsites s inner join prettyurl p on s.nciviewid = p.nciviewid
 where p.isroot =1 and isprimary =0  
	and s.template <> 'multipagecontent'

union 
select distinct v.objectid, 
v.[content type] as [page content type]
 	,prettyurl + '/page' + convert(varchar(30),priority) as promo_URL
,prettyurl + '/page' + convert(varchar(30),priority) as promo_url_name 
from microsites v
where  folder + case when urlname is null then '' else '/'+ urlname END 
		<> prettyurl + '/page' + convert(varchar(30),priority)
and template = 'multipagecontent'
and (folder + case when urlname is null then '' else '/'+ urlname END )
not in (select currenturl from prettyurl)
and priority <>1
union 
select distinct v.nciviewid, v.[content type] as [page content type]
 	,prettyurl + '/page' + convert(varchar(30),priority) as promo_URL
,prettyurl + '/page' + convert(varchar(30),priority) as promo_url_name 
from microsites v
where  folder + case when urlname is null then '' else '/'+ urlname END 
		<> prettyurl + '/page' + convert(varchar(30),priority)
and template = 'multipagecontent'
and (folder + case when urlname is null then '' else '/'+ urlname END )
not in (select currenturl from prettyurl)
and priority = 1

order by 3
GO




----------------------------
-------------------------------
--------------------
drop function dbo.mig_getURLViewID
go
create function dbo.mig_getURLViewID(@url varchar(300))
returns uniqueidentifier
as
BEGIN
	declare @s uniqueidentifier
	select top 1 @s = nciviewid from microsites s 
	where s.folder + case when urlname is null then '' else '/'+ urlname END = @url
	and s.template = 'singlepagecontent' and s.[content type] <> 'ncilist'
	if @s is null
			BEGIN
				select top 1 @s = nciviewid from microsites s
				where s.folder = @url and urlname is not null and level is not null
					if @s is null
					BEGIN
						select top 1 @s = nciviewid 
							from microsites s 
							where s.folder + case when urlname is null then '' else '/'+ urlname END = @url
							and s.template = 'multipagecontent' and priority =1
						if @s is null
							select top 1 @s = objectid 
							from microsites s 
							where s.folder + case when urlname is null then '' else '/'+ urlname END = @url
							and s.template = 'multipagecontent' and priority <> 1
					END
			END
	return @s

END

GO


drop procedure dbo.Mig_MSsetlanding
go

create procedure dbo.Mig_MSsetlanding
as
BEGIN
	create table #folder (urlpath varchar(800))
	insert into #folder exec Mig_MSfolder 

	select urlpath ,
	dbo.mig_getURLViewid(urlpath) as viewid,

	(select top 1 [content type] from microsites where (nciviewid = dbo.mig_getURLViewid(urlpath) and [content type]<> 'ncilist')
	or objectid = dbo.mig_getURLViewid(urlpath)
	order by isnull(level, 1000) 
	) as [content type]
	,'rffNavlandingpage'	as slot
		, 'cgvSnTitleLink' as template
	from #folder f 
	where dbo.mig_getURLViewid(urlpath) is not null
END
GO

------------------




