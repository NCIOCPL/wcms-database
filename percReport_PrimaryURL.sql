if object_id('percReport_PrimaryURL') is not null
	drop procedure dbo.percReport_PrimaryURL
go
create procedure dbo.percReport_PrimaryURL( @folderID int, @allFolder bit, @siteid int = 305 )
as
BEGIN

declare @s varchar(max), @pagecontenttype varchar(2000)
declare @sitename varchar(255), @folderPath varchar(500)
create table #folder (ID int, path varchar(900))

select @folderpath = dbo.percReport_getFolderpath(@folderid)
		
		
	 if @allfolder = 1
			BEGIN
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
			  
			END
			ELSE
				BEGIN
					insert into #folder
					select @folderID, @folderPath
				END




		select c.contentid, left(c.title, (len(c.title)-7)) as title
		, f.path+ '/'+ dbo.percReport_getPretty_url_name(c.contentid)  AS primaryURL
		, f.path as itemPath
		, t.contenttypename
		, s.statename
		from dbo.contentstatus c 
		inner join PSX_ObjectRelationship r  ON r.dependent_id = c.contentid
		inner join #folder f on f.id = r.owner_id
		inner join contenttypes t on t.contenttypeid = c.contenttypeid
		inner join states s on s.STATEID = c.contentstateid and s.WORKFLOWAPPID = c.WORKFLOWAPPID
		where public_revision is not null and r.config_id =3
		 and t.contenttypename in 
						(select contenttypename from dbo.percReport_contenttype
						where type = 'page')
		and len(c.title)-7 >= 0
		order by 4

END
GO
