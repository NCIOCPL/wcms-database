drop procedure mig_isPDFAvailable
go
create procedure mig_isPDFAvailable
as
select nciviewid, (select top 1 [page content type] as [owner content type] from migmapall where nciviewid = vp.nciviewid)
as [owner content type]
, 'nciFile' as slot
, 'nciBnFile' as [snippet template]
, propertyvalue 
,(select nciviewid from prettyurl where currenturl = propertyvalue) as objectid
,'nciFile' as  [dependent content type]
from viewproperty vp
where propertyname = 'isPDFavailable'
and (select top 1 [page content type] from migmapall where nciviewid = vp.nciviewid) is not null
and propertyvalue <> ''