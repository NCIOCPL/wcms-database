

drop procedure dbo.Mig_PagelistItem
go
create procedure dbo.Mig_PagelistItem (@listID uniqueidentifier)
as
select distinct li.listid, convert(varchar(80), li.nciviewid) as nciviewid, 
	[snippet item slot] as Slot, 'ncilink' as [content type]
	, [snippet item template] as template
	, priority
	from migmapall m  inner join listItem li on m.objectid = li.listid 
	where [snippet content type] = 'ncilist'
	and li.nciviewid in (select nciviewid from nciview where ncitemplateid is null)
	and listid = @listid
union
select distinct li.listid, convert(varchar(80), li.nciviewid) , 
	[snippet item slot] as Slot, (select top 1 [page content type] from dbo.migmapall m  where m.nciviewid = li.nciviewid) as [content type]
	, [snippet item template] as template
	, priority
	from migmapall m  inner join listItem li on m.objectid = li.listid 
	where [snippet content type] = 'ncilist'
	and li.nciviewid in (select nciviewid from nciview where ncitemplateid is not null)
	and li.nciviewid in (select nciviewid from migmap)
	and listid = @listid
union
	--microsites
	select distinct  li.listid, convert(varchar(80), ms.viewid) , 
	[snippet item slot] as Slot, 
	'cgvMicrositeIndex' as [content type]
	, [snippet item template] as template
	, li.priority
	from migmapall m inner join listItem li on m.objectid = li.listid 
	inner join prettyurl p on p.nciviewid = li.nciviewid
	inner join MSmicrositeindex ms  on p.currenturl = ms.folder
	where [snippet content type] = 'ncilist' 
			and listid = @listID



union
select  distinct li.listid, dbo.Mig_getCDRID(li.nciviewid), 
	[snippet item slot] as Slot, 
	'pdqCancerInfoSummaryLink' as [content type]
	, 'pdqSnCancerInformationSummaryLink' as template
	, priority
	from migmapall m  inner join listItem li on m.objectid = li.listid 
	where [snippet content type] = 'ncilist'
	and li.nciviewid in 
		(select nciviewid from nciview where ncitemplateid in (select ncitemplateid from dbo.ncitemplate where name = 'summary'))
	and listid = @listid
union
select distinct li.listid,  dbo.Mig_getCDRID(li.nciviewid), 
	[snippet item slot] as Slot, 
	'pdqDrugInfoSummary' as [content type]
	, [snippet item template] as template
	, priority
	from migmapall m  inner join listItem li on m.objectid = li.listid 
	where [snippet content type] = 'ncilist'
	and li.nciviewid in 
		(select nciviewid from nciview where ncisectionid in 
			(select ncisectionid from dbo.ncisection where name = 'druginfo')
			and updateuserid = 'gatekeeper')
	and listid = @listid
union 
select distinct li.listid,convert(varchar(80), li.nciviewid) ,  
	[snippet item slot] as Slot, 
	NULL as [content type]
	, [snippet item template] as template
	, priority
	from migmapall m  inner join listItem li on m.objectid = li.listid 
	where [snippet content type] = 'ncilist'
	and listid = @listid
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
order by priority
GO


drop function dbo.Mig_getCDRID
go
create function dbo.Mig_getCDRID(@nciviewid uniqueidentifier)
returns varchar(80)
as
BEGIN
	declare @r varchar(80)
	
	
	select top 1 @r = d.documentid from viewobjects vo inner join cdrlivegk.dbo.document d on 
	vo.objectid = d.documentguid
	where nciviewid = @nciviewid
	order by vo.type
	return @r
END
GO

