if object_id('percreport_neverpublic') is not null
drop procedure percreport_neverpublic
go
Create procedure dbo.percReport_neverpublic (@folderid int , @allFolder bit)
as
BEGIN
create table #folder (ID int, path varchar(900))
	
	 if @allfolder = 1
			BEGIN
				;with folders as (
					  select null as ParentID, f.ContentID as ID, cs.title as FolderName, 
					convert(varchar(512),dbo.percReport_getfolderpath(@folderid)) as Path
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
					select @folderID, dbo.percReport_getfolderpath(@folderid)
				END




	select * from	
		(
		select c.contentid
			, t.contenttypelabel
			, case    
   when  dbo.percReport_getpretty_url_name(c.contentid) = '***'   
   then NULL  
   when dbo.percreport_getitemfolderpath(c.contentid)  like 'CancerGov/PrivateArchive%'  
   then NULL  
   ELSE dbo.percreport_getitemfolderpath(c.contentid) +   
    case when dbo.percReport_getpretty_url_name(c.contentid) is null   
     then '' ELSE '/' +  dbo.percReport_getpretty_url_name(c.contentid) END   
    END as prettyurl  
			, title
			,statename from contentstatus c
			inner join contenttypes t on t.contenttypeid = c.contenttypeid
			inner join WORKFLOWAPPS w on w.workflowappid = c.workflowappid
			inner join states s on c.contentstateid = s.stateid and s.workflowappid = w.workflowappid
			inner join PSX_ObjectRelationship r  ON r.dependent_id = c.contentid
			inner join #folder f on f.id = r.owner_id
			where 	public_revision is null
			and contenttypename in
			(
				select contenttypename from dbo.percReport_contenttype
			)
		)a
		order by 2


END