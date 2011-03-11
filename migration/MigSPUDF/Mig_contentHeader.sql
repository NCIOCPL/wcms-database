drop procedure Mig_sharedcontentHeader
go
create procedure Mig_sharedcontentHeader
as
select headerid as objectid, name as long_title, data as bodyfield
from header 
where headerid in
	(select objectid from migmapall
		where [snippet content type] = 'ncicontentheader'
	) and headerid not in 
	(select objectid from bodyheader)
	and headerid <> '32425B29-12AA-4236-A08D-DC6C14B3458B'
union all
select  objectid, long_title,  bodyfield
from bodyheader


GO


drop procedure Mig_contentHeader
go
create procedure Mig_contentHeader
as
select m.nciviewid, m.[page content type], m.objectid, vo.priority
,slot,[Snippet Content Type],[Snippet Template]
from migmap m  inner join viewobjects vo on vo.objectid = m.objectid and vo.nciviewid = m.nciviewid
where [snippet content type] = 'ncicontentheader'
order by m.nciviewid, priority
GO