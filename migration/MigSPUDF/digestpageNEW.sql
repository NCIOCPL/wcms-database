drop function dbo.mig_DPGetFolder
go
create function dbo.mig_DPGetFolder(@prettyurl varchar(800))
returns varchar(1500)
as
BEGIN
	if exists (
	select * from migmap
	where prettyurl like @prettyurl + '/%'
	)
	return @prettyurl + '/main'
	
return @prettyurl
END
GO


drop procedure dbo.Mig_DPMicrositeIndex
go
create procedure dbo.Mig_DPMicrositeIndex
as
select distinct v.nciviewid as viewid, dbo.mig_DPGetFolder(prettyurl) as folder,
'cgvMicrositeIndex' as [content type],
	v.Title as long_title,
	v.ShortTitle as short_title,
	v.Description as long_description
from migmap m inner join nciview v on v.nciviewid = m.nciviewid
where [cancergov template] ='digestpage'
Go

drop procedure dbo.Mig_DPsectionNavWithNavon
go
create procedure dbo.Mig_DPsectionNavWithNavon
as
select distinct dbo.mig_DPGetFolder(prettyurl) as folder, 
'nciSectionNav' as [content type], 1 as levels_to_show
, v.shortTitle + ' section nav' as section_nav_title
, 'rffNavon' as [dependent content type]
, 'nciSectionNavRootNavon' as slot, 'nciSnSectionNavRoot' as template
from migmap v
where [cancergov template] ='digestpage'
GO

drop procedure dbo.Mig_DPNavon
go
create procedure dbo.Mig_DPNavon
as
select distinct v.nciviewid as viewid, dbo.mig_DPGetFolder(prettyurl) as folder,
'cgvMicrositeIndex' as [dependent content type], 
'rffNavLandingPage' as slot,
'cgvSnTitleLink' as template,
'nciSectionNav' as [dependent content type2],
'cgvSectionNav' as slot2, 
'cgvSnSectionNav' as template2
from migmap v
where [cancergov template] ='digestpage'
GO

drop procedure dbo.Mig_DPdocument
go
create procedure dbo.Mig_DPdocument(@nciviewid uniqueidentifier = NULL)
as
BEGIN
	if @nciviewid is null
		select vo.objectid as viewid, 
			dbo.mig_DPGetFolder(prettyurl) + '/Page' + convert(varchar(30), priority) as folder, 
		'nciGeneral' as [content type],
		d.title as long_title,
		d.shorttitle as short_title,
		d.documentid as objectid,
		d.description as long_description,
		d.data as bodyfield,
		'rffNavon' as [owner content type],
		'rffNavLandingPage' as slot,
		'cgvSnTitleLink' as template
		from migmap m inner join document d on m.objectid = d.documentid
		inner join viewobjects vo on vo.nciviewid = m.nciviewid and vo.objectid = m.objectid
		where [cancergov template] ='digestpage'
			and viewobjecttype = 'document'
		order by m.nciviewid, priority
	ELSE
		select vo.objectid as viewid,  
			dbo.mig_DPGetFolder(prettyurl) + '/Page' + convert(varchar(30), priority) as folder, 
		'nciGeneral' as [content type],
		d.title as long_title,
		d.shorttitle as short_title,
		d.documentid as objectid,
		d.description as long_description,
			d.data as bodyfield,
		'rffNavon' as [owner content type],
		'rffNavLandingPage' as slot,
		'cgvSnTitleLink' as template
		from migmap m inner join document d on m.objectid = d.documentid
		inner join viewobjects vo on vo.nciviewid = m.nciviewid and vo.objectid = m.objectid
		where [cancergov template] ='digestpage'
			and viewobjecttype = 'document'
			and m.nciviewid = @nciviewid
		order by priority
END	
GO


drop procedure Mig_DPlist
go
create procedure Mig_DPlist(@nciviewid uniqueidentifier = NULL)
as
BEGIN
	if @nciviewid is null
		select vo.objectid as viewid, 
		dbo.mig_DPGetFolder(prettyurl) + '/Page' + convert(varchar(30), vo.priority) as folder, 
		'nciList' as [content type],
		l.listid as objectid,
		l.listname as list_title,
		l.listdesc as list_description,
		m.slot as slot,
		m.[snippet template]
		from migmap m inner join list l on m.objectid = l.listid
		inner join viewobjectproperty vop on vop.propertyvalue = convert(varchar(80),l.parentlistid)
		inner join viewobjects vo on vop.nciviewobjectid = vo.nciviewobjectid
		where [cancergov template] ='digestpage'
			and viewobjecttype = 'list'
		order by m.nciviewid, vo.priority
	ELSE
		select vo.objectid as viewid, 
		dbo.mig_DPGetFolder(prettyurl) + '/Page' + convert(varchar(30), vo.priority) as folder, 
		'nciList' as [content type],
		l.listid as objectid,
		l.listname as list_title,
		l.listdesc as list_description,
		m.slot as slot,
		m.[snippet template]
		from migmap m inner join list l on m.objectid = l.listid
		inner join viewobjectproperty vop on vop.propertyvalue = convert(varchar(80),l.parentlistid)
		inner join viewobjects vo on vop.nciviewobjectid = vo.nciviewobjectid
		where [cancergov template] ='digestpage'
			and viewobjecttype = 'list'
			and m.nciviewid = @nciviewid
		order by  vo.priority
	END

GO

-----------------
drop procedure dbo.Mig_DPrelatedPage
go
create procedure dbo.Mig_DPrelatedPage
as
BEGIN
	select distinct vo.objectid as viewid, 'nciGeneral' as [page content type], 
	slot as Slot, 'ncilink' as [content type]
	, case [snippet item template] when 'cgvSnQuickLinksListItemNoDescription' then 'cgvSnQuickLinksListItemNoDesc'
		when 'cgvSnQuickLinksListItemWithDescription' then 'cgvSnQuickLinksListItemWithDesc' 
		ELSE [snippet item template] END as template
	, li.priority
		, convert(varchar(80), li.nciviewid) as nciviewid
	from migmap m inner join viewobjects vo on vo.nciviewid = m.nciviewid
	inner join listitem li on li.listid = m.objectid
	where [cancergov template] = 'digestpage'
	and slot like '%related%' and vo.type = 'document'
	and li.nciviewid in (select nciviewid from nciview where ncitemplateid is null)
	and m.[cancergov template] = 'digestpage'
	and vo.type = 'document'
-- normal
union
select distinct
	vo.objectid as viewid, 'nciGeneral' as [page content type],
	slot as Slot, (select top 1 [page content type] from dbo.migmap m1 where m1.nciviewid = li.nciviewid) as [content type]
	, case [snippet item template] when 'cgvSnQuickLinksListItemNoDescription' then 'cgvSnQuickLinksListItemNoDesc'
		when 'cgvSnQuickLinksListItemWithDescription' then 'cgvSnQuickLinksListItemWithDesc' 
				ELSE [snippet item template] END as template
	, li.priority
		, convert(varchar(80), li.nciviewid)
from migmap m inner join viewobjects vo on vo.nciviewid = m.nciviewid 
inner join dbo.listitem li on m.objectid = li.listid
where slot = 'cgvrelatedpages'
and li.nciviewid in (select nciviewid from nciview where ncitemplateid is not null)
and li.nciviewid in (select nciviewid from migmap)
and m.[cancergov template] = 'digestpage'
and vo.type = 'document'
union
--summary
select  distinct

vo.objectid as viewid, 'nciGeneral' as [page content type],
	slot as Slot, 
	'pdqCancerInfoSummaryLink' as [content type]
	, 'pdqSnCancerInformationSummaryLink' as template
	, li.priority
		, dbo.Mig_getCDRID (li.nciviewid)
	from migmap m inner join viewobjects vo on vo.nciviewid = m.nciviewid
	inner join listItem li on m.objectid = li.listid 
	where slot = 'cgvrelatedpages'
	and li.nciviewid in 
		(select nciviewid from nciview where ncitemplateid in (select ncitemplateid from dbo.ncitemplate where name = 'summary'))
and m.[cancergov template] = 'digestpage'
and vo.type = 'document'
union
--druginfosummary
select distinct vo.objectid as viewid, 'nciGeneral' as [page content type],
	slot as Slot,  
	'pdqDrugInfoSummary' as [content type]
	, [snippet item template] as template
	, li.priority
		, convert(varchar(80), li.nciviewid)
	from migmap m inner join viewobjects vo on vo.nciviewid = m.nciviewid
	inner join listItem li on m.objectid = li.listid 
	where slot = 'cgvrelatedpages'
	and li.nciviewid in 
		(select nciviewid from nciview where ncisectionid in 
			(select ncisectionid from dbo.ncisection where name = 'druginfo')
			and updateuserid = 'gatekeeper')
and m.[cancergov template] = 'digestpage'
and vo.type = 'document'
union

select distinct
	vo.objectid as viewid, 'nciGeneral' as [page content type],
	slot as Slot, (select top 1 [content type] 
		from dbo.microsites s where s.nciviewid = li.nciviewid and [content type] <> 'nciList' order by priority) as [content type]
	, case [snippet item template] when 'cgvSnQuickLinksListItemNoDescription' then 'cgvSnQuickLinksListItemNoDesc'
		when 'cgvSnQuickLinksListItemWithDescription' then 'cgvSnQuickLinksListItemWithDesc' 
				ELSE [snippet item template] END as template
	, li.priority
		, convert(varchar(80), li.nciviewid)
from migmap m inner join viewobjects vo on vo.nciviewid = m.nciviewid
inner join dbo.listitem li on m.objectid = li.listid
where slot = 'cgvrelatedpages' and li.nciviewid in (select nciviewid from microsites)
and m.[cancergov template] = 'digestpage'
and vo.type = 'document'
union 
--redirect etc.
select distinct vo.objectid as viewid, 'nciGeneral' as [page content type],
	slot as Slot,  
	NULL as [content type]
	, [snippet item template] as template
	, li.priority
		, convert(varchar(80), li.nciviewid)
	from migmap m inner join viewobjects vo on vo.nciviewid = m.nciviewid
	inner join listItem li on m.objectid = li.listid 
	where slot = 'cgvrelatedpages'
	and li.nciviewid not in (select nciviewid from migmap)
	and li.nciviewid not in 
		(select nciviewid from nciview where ncisectionid in 
			(select ncisectionid from dbo.ncisection where name = 'druginfo')
			and updateuserid = 'gatekeeper')
	and li.nciviewid not in 
		(select nciviewid from nciview where ncitemplateid in (select ncitemplateid from dbo.ncitemplate where name = 'summary'))
	and li.nciviewid  in 
	(select nciviewid from nciview where ncitemplateid is not null)
	and li.nciviewid not in (select nciviewid from microsites)
and m.[cancergov template] = 'digestpage'
and vo.type = 'document'
order by 1, priority

END