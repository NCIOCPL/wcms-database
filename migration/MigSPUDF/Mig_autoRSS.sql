drop procedure dbo.mig_AutomaticRSSFeed
GO
create procedure dbo.mig_AutomaticRSSFeed
as
select (select top 1 right(currenturl, charindex('/', reverse(currenturl))-1)  
 from prettyurl p where p.nciviewid = v.nciviewid order by isprimary desc, isroot desc) as pretty_url_name
, v.Title as long_title,  
  v.Description as long_description
, convert(xml,d.data).value('/Search[1]/ResultsPerPage[1]', 'int')  as num_items
 ,convert(xml,d.data).value('/Search[1]/SearchFilter[1]', 'varchar(255)') as search_filter  
from dbo.nciview v 
inner join dbo.ncitemplate t on t.ncitemplateid = v.ncitemplateid
inner join dbo.viewobjects vo on vo.nciviewid = v.nciviewid
inner join dbo.document d on d.documentid = vo.objectid
where t.name = 'AutomaticRSSFeed'

GO

