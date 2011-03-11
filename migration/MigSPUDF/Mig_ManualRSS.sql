drop procedure dbo.mig_manualRSS
go
create procedure dbo.mig_manualRSS
as
select (select top 1 right(currenturl, charindex('/', reverse(currenturl))-1)  
 from prettyurl p where p.nciviewid = v.nciviewid order by isprimary desc, isroot desc) as pretty_url_name
, Title as long_title,  
 ShortTitle as short_title,
 v.Description as long_description
from dbo.nciview v 
inner join dbo.ncitemplate t on t.ncitemplateid = v.ncitemplateid
where t.name = 'ManualRSSFeed'
GO

drop function dbo.mig_manualRSSItem
go
create function dbo.mig_manualRSSItem (@title varchar(500))
returns @r table (nciviewid uniqueidentifier, slot varchar(500) , [content type] varchar(100) 
, priority int, template varchar(200))
as
BEGIN
	insert into @r
	select  li.nciviewid, 'cgvRSSItems' as slot,'nciLink' as [content type]
	, li.priority, 'cgvSnRSSListItem' as template 
	from dbo.nciview v 
	inner join dbo.ncitemplate t on t.ncitemplateid = v.ncitemplateid
	inner join viewobjects vo on vo.nciviewid = v.nciviewid
	inner join listItem li on li.listid = vo.objectid
	inner join nciview v1 on v1.nciviewid = li.nciviewid 
	where t.name = 'ManualRSSFeed'  and v1.ncitemplateid is null
	and v.title = @title
	union
	select  li.nciviewid, 'cgvRSSItems' as slot, g.[page content type]as [content type]
	, li.priority, 'cgvSnRSSListItem' as template 
	from dbo.nciview v 
	inner join dbo.ncitemplate t on t.ncitemplateid = v.ncitemplateid
	inner join viewobjects vo on vo.nciviewid = v.nciviewid
	inner join listItem li on li.listid = vo.objectid
	inner join migmap g on g.nciviewid = li.nciviewid 
	where t.name = 'ManualRSSFeed'  
	and v.title = @title
	order by  li.priority
	return 
END
go
