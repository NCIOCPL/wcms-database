use percussion

if OBJECT_ID('tempdb..#folder') is not null
	drop table #folder

if OBJECT_ID('tempdb..#d') is not null
	drop table #d
	
if OBJECT_ID('tempdb..#m') is not null
	drop table #m 
GO 
;with folders as (
					  select null as ParentID, f.ContentID as ID, cs.title as FolderName, 
					convert(varchar(512),'') as Path
					  from PSX_folder f join contentstatus cs on f.contentid = cs.contentid
					  where cs.contentid = 305
					  UNION ALL
					  select r.owner_ID as ParentID, f.contentid as ID, cs.title as FolderName, 
					convert(varchar(512),folders.Path + '/' + cs.title) as Path
					  from PSX_folder f inner JOIN PSX_ObjectRelationship r  ON r.dependent_id = f.contentid
					  inner JOIN folders ON folders.ID = r.owner_id
					  inner join contentstatus cs on f.contentid = cs.contentid
				)
select * into #folder from folders
	
select  
c.contentid , 
'www.cancer.gov' + f.path + isnull('/'+ nullif(dbo.percReport_getPretty_url_name(c.contentid),'***'), '') as desktopurl
, c.TITLE 
, contenttypename
, path as folder
, statename 
into #d
from dbo.contentstatus c 
inner join dbo.psx_objectrelationship ff on c.contentid = ff.dependent_id and config_id = 3
inner join #folder f on f.id = ff.owner_id
inner join contenttypes t on t.contenttypeid = c.contenttypeid
inner join STATES  s on s.STATEID = c.CONTENTSTATEID  and s.WORKFLOWAPPID = c.WORKFLOWAPPID
where 
contenttypename not like 'rffNav%'

go 
drop table #folder 


;with folders as (
					  select null as ParentID, f.ContentID as ID, cs.title as FolderName, 
					convert(varchar(512),'') as Path
					  from PSX_folder f join contentstatus cs on f.contentid = cs.contentid
					  where cs.contentid = 172511
					  UNION ALL
					  select r.owner_ID as ParentID, f.contentid as ID, cs.title as FolderName, 
					convert(varchar(512),folders.Path + '/' + cs.title) as Path
					  from PSX_folder f inner JOIN PSX_ObjectRelationship r  ON r.dependent_id = f.contentid
					  inner JOIN folders ON folders.ID = r.owner_id
					  inner join contentstatus cs on f.contentid = cs.contentid
				)
				
			  select * into #folder from folders
	
	
	
	
select  
c.contentid , 
'm.cancer.gov' + f.path + isnull('/'+ nullif( dbo.percReport_getPretty_url_name(c.contentid),'***'), '') as mobileurl
, c.TITLE 
, contenttypename
, path as folder
, statename 
into #m
from dbo.contentstatus c 
inner join dbo.psx_objectrelationship ff on c.contentid = ff.dependent_id and config_id = 3
inner join #folder f on f.id = ff.owner_id
inner join contenttypes t on t.contenttypeid = c.contenttypeid
inner join STATES  s on s.STATEID = c.CONTENTSTATEID  and s.WORKFLOWAPPID = c.WORKFLOWAPPID
where 
contenttypename not like 'rffNav%'

if OBJECT_ID('tempdb..#s') is not null
	drop table #s
select isnull(d.CONTENTID, m.contentid) as contentid
, isnull(d.TITLE, m.title) as title
, isnull(d.CONTENTTYPENAME, m.contenttypename) as contenttypename
, isnull(d.STATENAME, m.statename)  as state
, d.desktopurl , d.folder 
, m.mobileurl , m.folder as mobilefolder 
into #s
from #m m left outer join #d d on d.CONTENTID = m.CONTENTID



select * from #s where desktopurl is null
order by contenttypename, mobilefolder


select * from #s where desktopurl is not null
order by contenttypename, mobilefolder



---------------------------------MOVE

declare @f int 
select @f =   f.CONTENTID  from PSX_FOLDER f inner join CONTENTSTATUS c on f.CONTENTID = c.CONTENTID 
where c.TITLE = 'mobileonly'
update PSX_OBJECTRELATIONSHIP set OWNER_ID = @f  where CONFIG_ID = 3 and  DEPENDENT_ID in
(select contentid from #s where desktopurl is null)


----- delete mobile only slot

delete r
 from psx_objectrelationship r 
 inner join rxslottype s on s.slotid = r.SLOT_ID
 where slotname in (
 'cgvMobileBody'
 ,'cgvMobileCTMoreInfoSl'
 ,'cgvMobileCTPrvntionListSl'
 ,'cgvMobileCTTrtmntListSl'
 ,'cgvMobileFooter'
 ,'cgvMobileSiteBanner'
 )
 