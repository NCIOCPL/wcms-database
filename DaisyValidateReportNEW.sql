create table #contentid (contentid int)

insert into #contentid (contentid) values
--(960),(9855),(2356),(542631)


select distinct g.[contentid], c.CONTENTID,  s.STATENAME 
from #contentid g left outer join CONTENTSTATUS c on g.[contentid] = c.CONTENTID 
left outer join STATES s on s.STATEID = c.CONTENTSTATEID and s.WORKFLOWAPPID = c.WORKFLOWAPPID
where g.[contentid] is not null and (c.CONTENTID is null or  s.STATENAME <> 'public')
order by 3