select * from 
(
select 
 (select min(ch.EVENTTIME) from 
 dbo.CONTENTSTATUSHISTORY ch where ch.CONTENTID = c.CONTENTID and ch.REVISIONID = c.CURRENTREVISION) modifydate
 ,c.CONTENTID as parentID
, m.NAME as parentCommunity
,dbo.gaogetitemFolderPath(c.contentid, '')
+ ISNULL('/'+ dbo.percreport_getpretty_url_name(c.contentid), '')  as parentURL
, t.contenttypename as parentType
,c1.contentid 
, case when t1.CONTENTTYPENAME = 'gloimage' then 'cancergov/PublishedContent/Images' + dbo.gaogetitemFolderPath(c1.contentid, 'cancergov')  + 
(select top 1 '/' + i.IMG1_FILENAME  from RXS_CT_SHAREDIMAGE i where i.CONTENTID = c1.CONTENTID and i.REVISIONID = c1.CURRENTREVISION) 
else
dbo.gaogetitemFolderPath(c1.contentid, 'cancergov') 
+ ISNULL('/'+ dbo.percreport_getpretty_url_name(c1.contentid), '') 
END as url
, t1.contenttypename
from CONTENTSTATUS c 
inner join PSX_OBJECTRELATIONSHIP r on c.CONTENTID = r.OWNER_ID and c.CURRENTREVISION = r.OWNER_REVISION 
inner join RXCOMMUNITY m on c.COMMUNITYID = m.COMMUNITYID
inner join CONTENTTYPES t on t.CONTENTTYPEID = c.CONTENTTYPEID 
inner join CONTENTSTATUS c1 on c1.CONTENTID = r.DEPENDENT_ID
inner join RXCOMMUNITY m1 on c1.COMMUNITYID = m1.COMMUNITYID
inner join CONTENTTYPES t1 on t1.CONTENTTYPEID = c1.CONTENTTYPEID 
inner join RXSLOTTYPE s on s.SLOTID = r.SLOT_ID
where  m1.NAME like 'cancergov%' and m.NAME not like 'cancergov%'  and t1.CONTENTTYPENAME <> 'gloRawHTML'
) a
where modifydate > DATEADD(day, -1, getdate())

