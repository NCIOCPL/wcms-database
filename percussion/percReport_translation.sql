if object_id('percReport_translation') is not null
	drop procedure percReport_translation
GO
create procedure dbo.percReport_translation (@folderid int)
AS

BEGIN

declare @s varchar(max), @pagecontenttype varchar(2000)
declare @sitename varchar(255), @folderPath varchar(500)
create table #folder (ID int, path varchar(900))

select @folderpath = dbo.percReport_getFolderpath(@folderid)
			
				;with folders as (
					  select null as ParentID, f.ContentID as ID, cs.title as FolderName, 
					convert(varchar(512),isnull(@folderpath,'')) as Path
					  from PSX_folder f join contentstatus cs on f.contentid = cs.contentid
					  where cs.contentid = @folderid
					  UNION ALL
					  select r.owner_ID as ParentID, f.contentid as ID, cs.title as FolderName, 
					convert(varchar(512),folders.Path + '/' + cs.title) as Path
					  from PSX_folder f inner JOIN PSX_ObjectRelationship r  ON r.dependent_id = f.contentid
					  inner JOIN folders ON folders.ID = r.owner_id
					  inner join contentstatus cs on f.contentid = cs.contentid
				)
				insert into #folder
			  select ID, path  from folders

		select 
		c.contentid as EnglishContentid, c.title as EnglishTitle
		, case    
		   when  dbo.percReport_getpretty_url_name(c.contentid) = '***'   
		   then NULL  
		   when dbo.percreport_getitemfolderpath(c.contentid)  like 'CancerGov/PrivateArchive%'  
		   then NULL  
		   ELSE dbo.percreport_getitemfolderpath(c.contentid) +   
			case when dbo.percReport_getpretty_url_name(c.contentid) is null   
			 then '' ELSE '/' +  dbo.percReport_getpretty_url_name(c.contentid) END   
			END 
		as EnglishPrettyurl	
		,c. contentcreateddate as EnglishCreateDate
		,c. contentlastmodifieddate as EnglishLastModifyDate
		, c.locale
		,d.contentid as SpanishContentid, d.title as SpanishTitle
		, case    
		   when  dbo.percReport_getpretty_url_name(d.contentid) = '***'   
		   then NULL  
		   when dbo.percreport_getitemfolderpath(d.contentid)  like 'CancerGov/PrivateArchive%'  
		   then NULL  
		   ELSE dbo.percreport_getitemfolderpath(d.contentid) +   
			case when dbo.percReport_getpretty_url_name(d.contentid) is null   
			 then '' ELSE '/' +  dbo.percReport_getpretty_url_name(d.contentid) END   
			END 
		as SpanishPrettyurl
		,d. contentcreateddate as SpanishCreatedate
		,d. contentlastmodifieddate as SpanishLastModifydate
		, d.locale
		from dbo.contentstatus c inner join dbo.psx_objectrelationship ff on c.contentid = ff.dependent_id and config_id = 3
		and c.locale = 'en-us'
		inner join #folder f on f.id = ff.owner_id
		inner join dbo.psx_objectrelationship r on c.contentid = r.owner_id and 
				(r.owner_revision = -1 or r.owner_revision = c.public_revision
					or r.owner_revision = c.currentrevision
					or r.owner_revision = c.editrevision
					or r.owner_revision = c.tiprevision)
		inner join dbo.contentstatus d on d.contentid = r.dependent_id and r.config_id in (6,7)
		union 
		select
		o.contentid, o.title
		, case    
		   when  dbo.percReport_getpretty_url_name(o.contentid) = '***'   
		   then NULL  
		   when dbo.percreport_getitemfolderpath(o.contentid)  like 'CancerGov/PrivateArchive%'  
		   then NULL  
		   ELSE dbo.percreport_getitemfolderpath(o.contentid) +   
			case when dbo.percReport_getpretty_url_name(o.contentid) is null   
			 then '' ELSE '/' +  dbo.percReport_getpretty_url_name(o.contentid) END   
			END 
		,o. contentcreateddate
		,o. contentlastmodifieddate
		, o.locale
		,c.contentid, c.title
		, case    
		   when  dbo.percReport_getpretty_url_name(c.contentid) = '***'   
		   then NULL  
		   when dbo.percreport_getitemfolderpath(c.contentid)  like 'CancerGov/PrivateArchive%'  
		   then NULL  
		   ELSE dbo.percreport_getitemfolderpath(c.contentid) +   
			case when dbo.percReport_getpretty_url_name(c.contentid) is null   
			 then '' ELSE '/' +  dbo.percReport_getpretty_url_name(c.contentid) END   
			END 
		,c. contentcreateddate
		,c. contentlastmodifieddate
		, c.locale
		from dbo.contentstatus c inner join dbo.psx_objectrelationship ff on c.contentid = ff.dependent_id and config_id = 3
		and c.locale = 'es-us'
		inner join #folder f on f.id = ff.owner_id
		inner join dbo.psx_objectrelationship r on c.contentid = r.dependent_id and r.config_id in (6,7)
		inner join dbo.contentstatus o on 
			o.contentid = r.owner_id and (r.owner_revision = -1 or r.owner_revision = o.public_revision)
		order by 3

END