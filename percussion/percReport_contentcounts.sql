if object_id('percReport_contentcount') is not null
	drop procedure dbo.percReport_contentcount
go
create procedure dbo.percReport_contentcount
( @folderID int, @allFolder bit, @contenttype varchar(300) )
as
BEGIN

 create table #folder (ID int, path varchar(900))
	
	 if @allfolder = 1
			BEGIN
				;with folders as (
					  select null as ParentID, f.ContentID as ID, cs.title as FolderName, 
					convert(varchar(512),'') as Path
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
					select @folderID, ''
				END


		select * from
			(	
			select 
				contenttypelabel
				, CASE WHEN (GROUPING(statename) = 1) THEN 'ALL'
					ELSE ISNULL(statename, 'UNKNOWN')
					END AS workflowstate,
			   SUM(counts) AS counts
				from
					(select t.contenttypelabel, statename,  count(*) as counts
					from dbo.contentstatus c 
					inner join PSX_ObjectRelationship r  ON r.dependent_id = c.contentid
					inner join #folder f on f.id = r.owner_id
					inner join contenttypes t on t.contenttypeid = c.contenttypeid
					inner join WORKFLOWAPPS w on w.workflowappid = c.workflowappid
					inner join states s on c.contentstateid = s.stateid and s.workflowappid = w.workflowappid
					where r.config_id =3  and (@contenttype = 'ALL' or t.contenttypename = @contenttype)
					group by contenttypelabel, s.statename 
					) a
				group by contenttypelabel, statename with rollup
				
				)b
		where contenttypelabel is not null
		order by contenttypelabel, workflowstate desc
END
GO
