drop procedure dbo.Mig_relatedPage
go
Create procedure dbo.Mig_relatedPage
as

-- External link
select 
	m.nciviewid as viewid, m.[page content type],
	slot as Slot, 'ncilink' as [content type]
	, case [snippet item template] when 'cgvSnQuickLinksListItemNoDescription' then 'cgvSnQuickLinksListItemNoDesc'
		when 'cgvSnQuickLinksListItemWithDescription' then 'cgvSnQuickLinksListItemWithDesc' 
		ELSE [snippet item template] END as template
	, priority
		, convert(varchar(80), li.nciviewid) as nciviewid
from migmap m inner join dbo.listitem li on m.objectid = li.listid
where slot = 'cgvrelatedpages'
and li.nciviewid in (select nciviewid from nciview where ncitemplateid is null)

-- normal
union
select 
	m.nciviewid as viewid, m.[page content type],
	slot as Slot, (select top 1 [page content type] from dbo.migmap m1 where m1.nciviewid = li.nciviewid) as [content type]
	, case [snippet item template] when 'cgvSnQuickLinksListItemNoDescription' then 'cgvSnQuickLinksListItemNoDesc'
		when 'cgvSnQuickLinksListItemWithDescription' then 'cgvSnQuickLinksListItemWithDesc' 
				ELSE [snippet item template] END as template
	, priority
		, convert(varchar(80), li.nciviewid)
from migmap m inner join dbo.listitem li on m.objectid = li.listid
where slot = 'cgvrelatedpages'
and li.nciviewid in (select nciviewid from nciview where ncitemplateid is not null)
and li.nciviewid in (select nciviewid from migmap)

union
--summary
select  

m.nciviewid as viewid, m.[page content type],
	slot as Slot, 
	'pdqCancerInfoSummaryLink' as [content type]
	, 'pdqSnCancerInformationSummaryLink' as template
	, priority
		, dbo.Mig_getCDRID (li.nciviewid)
	from migmap m inner join listItem li on m.objectid = li.listid 
	where slot = 'cgvrelatedpages'
	and li.nciviewid in 
		(select nciviewid from nciview where ncitemplateid in (select ncitemplateid from dbo.ncitemplate where name = 'summary'))
union
--druginfosummary
select  m.nciviewid as viewid, m.[page content type],
	slot as Slot,  
	'pdqDrugInfoSummary' as [content type]
	, [snippet item template] as template
	, priority
		,dbo.mig_getcdrid(li.nciviewid)
	from migmap m inner join listItem li on m.objectid = li.listid 
	where slot = 'cgvrelatedpages'
	and li.nciviewid in 
		(select nciviewid from nciview where ncisectionid in 
			(select ncisectionid from dbo.ncisection where name = 'druginfo')
			and updateuserid = 'gatekeeper')

union

select 
	m.nciviewid as viewid, m.[page content type],
	slot as Slot, (select top 1 [content type] 
		from dbo.microsites s where s.nciviewid = li.nciviewid and [content type] <> 'nciList' order by priority) as [content type]
	, case [snippet item template] when 'cgvSnQuickLinksListItemNoDescription' then 'cgvSnQuickLinksListItemNoDesc'
		when 'cgvSnQuickLinksListItemWithDescription' then 'cgvSnQuickLinksListItemWithDesc' 
				ELSE [snippet item template] END as template
	, priority
		, convert(varchar(80), li.nciviewid)
from migmap m inner join dbo.listitem li on m.objectid = li.listid
where slot = 'cgvrelatedpages' and li.nciviewid in (select nciviewid from microsites)

union 
--redirect etc.
select  m.nciviewid as viewid, m.[page content type],
	slot as Slot,  
	NULL as [content type]
	, [snippet item template] as template
	, priority
		, convert(varchar(80), li.nciviewid)
	from migmap m inner join listItem li on m.objectid = li.listid 
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
order by 1, priority
GO

