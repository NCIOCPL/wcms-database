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


---------!!!
insert into GLOPAGEMETADATASET_GLOPAGEMETADATASET 
(contentid, revisionid, pretty_url_name, short_title)
select c.contentid, c.currentrevision, 'carousel'+ convert(varchar(30), c.contentid)
, left( c.title, len(c.title)-7)
from dbo.contentstatus c 
inner join dbo.psx_objectrelationship ff on c.contentid = ff.dependent_id and config_id = 3
inner join #folder f on f.id = ff.owner_id
inner join contenttypes t on c.contenttypeid =t.contenttypeid
left outer join GLOPAGEMETADATASET_GLOPAGEMETADATASET p on p.contentid = c.contentid
where contenttypename = 'gloVideoCarousel' and p.contentid is null