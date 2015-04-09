---initial URL that needs to be in redirect map file
select distinct right(url , LEN(url) - 9) as oldurl
from 
(select 
case when t1.CONTENTTYPENAME = 'gloimage' then 'cancergov/PublishedContent/Images' + dbo.gaogetitemFolderPath(c1.contentid, 'cancergov')  + 
(select top 1 '/' + i.IMG1_FILENAME  from RXS_CT_SHAREDIMAGE i where i.CONTENTID = c1.CONTENTID and i.REVISIONID = c1.CURRENTREVISION) 
else
dbo.gaogetitemFolderPath(c1.contentid, 'cancergov') 
+ ISNULL('/'+ dbo.percreport_getpretty_url_name(c1.contentid), '') 
END
as url
from CONTENTSTATUS c inner join PSX_OBJECTRELATIONSHIP r on c.CONTENTID = r.OWNER_ID and c.CURRENTREVISION = r.OWNER_REVISION 
inner join RXCOMMUNITY m on c.COMMUNITYID = m.COMMUNITYID
inner join CONTENTTYPES t on t.CONTENTTYPEID = c.CONTENTTYPEID 
inner join CONTENTSTATUS c1 on c1.CONTENTID = r.DEPENDENT_ID
inner join RXCOMMUNITY m1 on c1.COMMUNITYID = m1.COMMUNITYID
inner join CONTENTTYPES t1 on t1.CONTENTTYPEID = c1.CONTENTTYPEID 
where  m1.NAME like 'cancergov%' and m.NAME not like 'cancergov%' and t1.CONTENTTYPENAME <> 'gloRawHTML'
and t1.contenttypename <> 'nciHome'
) a
order by 1







