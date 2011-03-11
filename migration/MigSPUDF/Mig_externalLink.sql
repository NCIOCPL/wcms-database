
drop procedure Mig_externalLink
go
create procedure Mig_externalLink
as
BEGIN


	select distinct  v.nciviewid as viewid, title as long_title, shortTitle as short_title, description as long_description, url
	from nciview v 
	where  ncitemplateid is null and v.nciviewid in
		(select li.nciviewid from listItem li 
			inner join migmapall m on m.objectid = li.listid
		)
	union 
	select distinct  v.nciviewid as viewid, title as long_title, shortTitle as short_title, description as long_description, url  
	 from nciview v   
	 where  ncitemplateid is null 
	and v.nciviewid in
	(select li.nciviewid from cancergovstaging.dbo.bestbetcategories b 
	inner join cancergovstaging.dbo.listitem
	li on li.listid = b.listid)
	and v.nciviewid not in  
	  (select li.nciviewid from listItem li   
	   inner join migmap m on m.objectid = li.listid
		)  
	union
	select distinct  v1.nciviewid as viewid, v1.title as long_title
	, v1.shortTitle as short_title, v1.description as long_description, v1.url  
	from dbo.nciview v 
	inner join dbo.ncitemplate t on t.ncitemplateid = v.ncitemplateid
	inner join viewobjects vo on vo.nciviewid = v.nciviewid
	inner join listItem li on li.listid = vo.objectid
	inner join nciview v1 on v1.nciviewid = li.nciviewid 
	where t.name = 'ManualRSSFeed'  and v1.ncitemplateid is null
	union
	select distinct  v.nciviewid as viewid, v.title as long_title
	, v.shortTitle as short_title, v.description as long_description, v.url  
	from dbo.nciview v 
	where  ncitemplateid is null 
	and v.nciviewid in (select li.nciviewid from uniquelist u inner join listitem li on 
	u.listid = li.listid)

END
Go