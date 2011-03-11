
drop function dbo.mig_getbacktotop
go
create function dbo.mig_getbacktotop
(@nciviewid uniqueidentifier, @documentid uniqueidentifier = NULL)
returns bit
as
BEGIN
declare @r varchar(50), @r1 bit

if @documentid is NULL
		select top 1 @r =   propertyvalue 
		from viewobjectproperty vop inner join viewobjects vo on vop.nciviewobjectid = vo.nciviewobjectid
		inner join nciview v1 on v1.nciviewid = vo.nciviewid
		inner join ncitemplate t on t.ncitemplateid = v1.ncitemplateid
		where t.name not in ('MultiPageContent',  'PowerPointPresentation')
			and
			propertyname = 'DisplayReturnToTop' and vo.nciviewid = v1.nciviewid
			and vo.type = 'document'
			and v1.nciviewid = 	@nciviewid
			and v1.nciviewid in (select nciviewid from migmap where [page content type] in ('nciGeneral','cgvFactSheet'))
		order by priority
	ELSE
		if not exists (select * from viewproperty vp
					where nciviewid = @nciviewid and propertyname = 'SuppressReturnToTop'
					)
			select @r = propertyvalue
			from viewobjects vo inner join viewobjectproperty vop on vo.nciviewobjectid = vop.nciviewobjectid
			where nciviewid = @nciviewid and objectid = @documentid
				and propertyname = 'DisplayReturnToTop' 
				and vo.nciviewid in (select nciviewid from migmap where [page content type] in ('cgvPgBooklet'))

	if @r = 'true'
		select @r1 = 1
	return @r1
END

GO



drop function dbo.mig_getShowpagetitle
go
create function dbo.mig_GetShowpagetitle
(@nciviewid uniqueidentifier, @documentid uniqueidentifier = NULL)
returns bit
as
BEGIN
declare @r varchar(50), @r1 bit

if @documentid is NULL

		if exists (select * from viewproperty vp 
					where nciviewid = @nciviewid and propertyname like 'SuppressPageTitle%'
						and nciviewid in (select nciviewid from migmap where [page content type] in ('nciGeneral','cgvFactSheet','nciLandingPage'))
					)
			select @r = 'false'
			ELSE
				select top 1 @r =   propertyvalue 
				from viewobjectproperty vop inner join viewobjects vo on vop.nciviewobjectid = vo.nciviewobjectid
				inner join nciview v1 on v1.nciviewid = vo.nciviewid
				inner join ncitemplate t on t.ncitemplateid = v1.ncitemplateid
				where t.name not in ('MultiPageContent',  'PowerPointPresentation')
					and
					propertyname = 'DisplayTitle' and vo.nciviewid = v1.nciviewid
					and vo.type in ( 'document', 'include')
					and v1.nciviewid = 	@nciviewid
					and v1.nciviewid in (select nciviewid from migmap where [page content type] in ('nciGeneral','cgvFactSheet', 'nciLandingPage'))
				order by priority
	ELSE
		if exists (select * from viewproperty vp 
					where nciviewid = @nciviewid and propertyname like 'SuppressPageTitle%'
						and nciviewid in (select nciviewid from migmap where [page content type] in ('cgvPgBooklet'))

					)
			select @r = 'false'
			ELSE
				select @r = propertyvalue
				from viewobjects vo inner join viewobjectproperty vop on vo.nciviewobjectid = vop.nciviewobjectid
				where nciviewid = @nciviewid and objectid = @documentid
					and propertyname = 'DisplayTitle'
					and vo.nciviewid in (select nciviewid from migmap where [page content type] in ('cgvPgBooklet'))
	if @r = 'false'
		select @r1 = 0
	return @r1
END
GO

---------------
drop function dbo.Mig_getprettyurl
go

create function dbo.Mig_getPrettyURL(@nciviewid uniqueidentifier)
returns varchar(500)
as
BEGIN
	declare @p varchar(500)
	if exists 	(select * from viewproperty
				where propertyname = 'tag' and propertyvalue = 'Private Archive'
					and nciviewid = @nciviewid
				)
		select @p = '/PrivateArchive/' + 
		(select top 1 right(currenturl, charindex('/', reverse(currenturl))-1) 
		from prettyurl p 
		where p.nciviewid = @nciviewid order by isprimary desc, isroot desc) 
	ELSE
		select @p = (select top 1 currenturl
		from prettyurl p 
		where p.nciviewid = @nciviewid order by isprimary desc, isroot desc) 

return @p


END
go


------------------
------------------

drop procedure Mig_shellpageMetaData
go
create procedure Mig_shellpageMetaData (@contentType nvarchar(100) = NULL)
as
BEGIN

if @contentType is null
	select 
	(select top 1 [Page Content Type] 
			from migMap m where m.nciviewid = v.nciviewid and [Page Content Type] <> 'rffNavon'  )
		as contentType,
		v.nciviewid as viewid,Title as long_title,
	ShortTitle as short_title,
	Description as long_description,
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
	,
	(select top 1 data from migmap m inner join document d on m.objectid = d.documentid
	where m.nciviewid = v.nciviewid and viewobjecttype ='navdoc'
	and [page content type] ='cgvcancerbulletin') as cancer_bulletin_leftnav
	,( select  case when currenturl like '%09' or currenturl like '%10' 
			THEN 'cgvPgCancerBulletin'  ELSE 'cgvPgLgcyCancerBulletin' END
		from prettyurl p 
		where p.nciviewid = v.nciviewid and isprimary =1 and isroot =1
			and nciviewid in (select nciviewid from dbo.migmap where [page content type] ='cgvcancerbulletin')
		 ) as template
	, (select case propertyvalue when 'true' then 1 else NULL END 
				from viewproperty vp 
				where vp.nciviewid = v.nciviewid and propertyname = 'SuppressCGovHeader'
						and v.ncitemplateid ='D9C8A380-6A06-4AFA-86E9-EA52E50E0493'
		) as suppress_banner
	
		 ,(select top 1 case when vp.propertyvalue like '%#%' then left(propertyvalue, charindex('#', propertyvalue)-1)  
		 ELSE propertyvalue END 
		from dbo.Viewproperty vp where vp.nciviewid = v.nciviewid
		and propertyname = 'CancerTypeDefinitionCDRID') as definitionID
		,(select top 1 propertyvalue from dbo.Viewproperty vp where vp.nciviewid = v.nciviewid
		and propertyname = 'CancerTypeDefinitionLabel') as definitionTitle
	from nciview v
	where 	
			nciviewid in (select nciviewid from dbo.migmap)
			and nciviewid not in (select nciviewid from dbo.migmap where [page content type] = 'ncifile')
			and nciviewid not in
				(select  m.nciviewid
				from viewobjects vo inner join migmap m on vo.nciviewid = m.nciviewid
				where vo.type = 'virsearch'
				)
			and nciviewid not in 
				(select nciviewid from dbo.migmap where [cancergov template] = 'digestpage')


ELSE
select 
	(select top 1 [Page Content Type] 
			from migMap m where m.nciviewid = v.nciviewid and [Page Content Type] <> 'rffNavon'  )
		as contentType,
		v.nciviewid as viewid,Title as long_title,
	ShortTitle as short_title,
	Description as long_description,
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
	,
	(select top 1 data from migmap m inner join document d on m.objectid = d.documentid
	where m.nciviewid = v.nciviewid and viewobjecttype ='navdoc'
	and [page content type] ='cgvcancerbulletin') as cancer_bulletin_leftnav
	,( select  case when currenturl like '%09' or currenturl like '%10' 
			THEN 'cgvPgCancerBulletin'  ELSE 'cgvPgLgcyCancerBulletin' END
		from prettyurl p 
		where p.nciviewid = v.nciviewid and isprimary =1 and isroot =1
			and nciviewid in (select nciviewid from dbo.migmap where [page content type] ='cgvcancerbulletin')
		 ) as template
	, (select case propertyvalue when 'true' then 1 else NULL END 
				from viewproperty vp 
				where vp.nciviewid = v.nciviewid and propertyname = 'SuppressCGovHeader'
						and v.ncitemplateid ='D9C8A380-6A06-4AFA-86E9-EA52E50E0493'
		) as suppress_banner
		 ,(select top 1 case when vp.propertyvalue like '%#%' then left(propertyvalue, charindex('#', propertyvalue)-1)  
		 ELSE propertyvalue END 
		from dbo.Viewproperty vp where vp.nciviewid = v.nciviewid
		and propertyname = 'CancerTypeDefinitionCDRID') as definitionID
		,(select top 1 propertyvalue from dbo.Viewproperty vp where vp.nciviewid = v.nciviewid
		and propertyname = 'CancerTypeDefinitionLabel') as definitionTitle
	from nciview v
	where nciviewid in (select nciviewid from dbo.migmap where  [Page Content Type] = @contenttype)
			and nciviewid not in (select nciviewid from dbo.migmap where [page content type] = 'ncifile')
	and nciviewid not in
		(select  m.nciviewid
		from viewobjects vo inner join migmap m on vo.nciviewid = m.nciviewid
		where vo.type = 'virsearch'
		)
		and nciviewid not in 
				(select nciviewid from dbo.migmap where [cancergov template] = 'digestpage')


END
