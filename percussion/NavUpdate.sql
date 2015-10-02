
create table #t (url varchar(250), channel varchar(250), suite varchar(250), [content-group] varchar(250))

insert into #t (url, channel, suite, [content-group]) 
values ('www.cancer.gov', 'Home page', 'nci', null)

insert into #t(url, channel, suite, [content-group]) 
values ('www.cancer.gov/about-cancer', 'About Cancer (Other)', 'ncicancertopics,ncienglish-all,nci', null)



select 
 n.contentid as navonID,  f.CONTENTID as folderID
 , dbo.gaogetitemFolderPath(f.contentid , '') + '/'+  c1.title  as folderpath
 into #navonFolder 
from RXS_CT_NAVON n 
inner join contentstatus c on c.contentid = n.contentid and n.REVISIONID = c.CURRENTREVISION
inner join PSX_OBJECTRELATIONSHIP r on n.CONTENTid = r.DEPENDENT_ID
inner join psx_folder f on f.contentid = r.OWNER_ID
inner join contentstatus c1 on c1.contentid = f.CONTENTID
inner join RXCOMMUNITY m on m.COMMUNITYID = c.COMMUNITYID 
where m.NAME <> 'CDR_PublishPreview' and dbo.gaogetitemFolderPath(f.contentid , '') not like 'MobileCancerGov%'


select n.contentid as NavTreeID, dbo.gaogetitemFolderPath(n.contentid , '') as sitename
into #navTree
from RXS_CT_NAVTREE n 
inner join contentstatus c on c.contentid = n.contentid and n.REVISIONID = c.CURRENTREVISION
inner join PSX_OBJECTRELATIONSHIP r on n.CONTENTid = r.DEPENDENT_ID
inner join psx_folder f on f.contentid = r.OWNER_ID
inner join contentstatus c1 on c1.contentid = f.CONTENTID
inner join RXCOMMUNITY m on m.COMMUNITYID = c.COMMUNITYID 
where m.NAME <> 'CDR_PublishPreview' and dbo.gaogetitemFolderPath(n.contentid , '') not like 'MobileCancerGov%'

select * from #navtree

select * into #siteNameMap from
(
select 'cancergov' as sitename, 'www.cancer.gov' as url
union
select 'DCEG', 'DCEG.cancer.gov'
union
select 'TCGA', 'cancergenome.nih.gov'
union
select 'imaging', 'imaging.cancer.gov'
union
select 'Proteomics', 'Proteomics.cancer.gov'
)a

----NavTree
--update w set w.CHANNEL = u.channel, w.REPORT_SUITE = u.Suite, w.CONTENT_GROUP = u.[content-group] 
select *
 from test..urlchannel u 
inner join #siteNameMap sm on sm.url = u.url 
inner join #navtree n  on n.sitename = sm.sitename 
inner join GENWEBANALYTICS_GENWEBANALYTICS w on w.CONTENTID = n.navtreeID

select * from #siteNameMap

--update w set w.CHANNEL = u.channel, w.REPORT_SUITE = u.Suite, w.CONTENT_GROUP = u.[content-group] 
select * 
from test..urlchannel u  
inner join #siteNameMap sm on  case when charindex('/', u.url) = 0 then u.url else  left(u.url, charindex('/', u.url)-1) END = sm.url
inner join #navonFolder n  on sm.sitename+ substring(u.url,charindex('/', u.url), 9999) = n.folderpath 
inner join GENWEBANALYTICS_GENWEBANALYTICS w on w.CONTENTID = n.navonID

