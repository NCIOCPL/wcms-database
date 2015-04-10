create table #contentid (contentid varchar(900))

insert into #contentid (contentid) values
--('960'),('9855'),('2356'),('542631')

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
	



select distinct g.[contentid], c.CONTENTID,  s.STATENAME 
from #contentid g left outer join CONTENTSTATUS c on g.[contentid] = c.CONTENTID 
left outer join STATES s on s.STATEID = c.CONTENTSTATEID and s.WORKFLOWAPPID = c.WORKFLOWAPPID
where g.[contentid] is not null and (c.CONTENTID is null or ( s.STATENAME <> 'public' and s.STATENAME <> 'cdrlive'))
and g.contentid not like '/%'
union all
select  
distinct 
g.contentid 
,c.contentid  
, statename 
from #contentid g left outer join  
(dbo.contentstatus c 
inner join dbo.psx_objectrelationship ff on c.contentid = ff.dependent_id and config_id = 3
inner join #folder f on f.id = ff.owner_id
inner join contenttypes t on t.contenttypeid = c.contenttypeid and contenttypename = 'rffnavon'
inner join STATES  s on s.STATEID = c.CONTENTSTATEID  and s.WORKFLOWAPPID = c.WORKFLOWAPPID
) on g.[contentid] = f.Path 
where   g.contentid like '/%'
and g.[contentid] is not null and (c.CONTENTID is null or ( s.STATENAME <> 'public' and s.STATENAME <> 'cdrlive'))








