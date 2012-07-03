update p 
set p.pretty_url_name = 'dyanamic-list' + convert(varchar(40), c.contentid)
from contentstatus c inner join CGVPUBLISHEDPAGEMETADATA_CGVPUBLISHEDPAGEMETADATA1
p on c.contentid = p.contentid 
where contenttypeid = 439
and pretty_url_name is null
