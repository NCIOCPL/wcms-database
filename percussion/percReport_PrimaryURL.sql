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



		select c.contentid, left(c.title, len(c.title)-7)
		, f.path+ case when p.pretty_url_name is null then '' ELSE '/' + pretty_url_name END as primaryURL
		, t.contenttypename
		from dbo.contentstatus c 
		inner join PSX_ObjectRelationship r  ON r.dependent_id = c.contentid
		inner join #folder f on f.id = r.owner_id
		inner join contenttypes t on t.contenttypeid = c.contenttypeid
		left outer join CGVPUBLISHEDPAGEMETADATA_CGVPUBLISHEDPAGEMETADATA1 p on p.contentid = c.contentid
		and p.revisionid = c.public_revision
		where public_revision is not null and r.config_id =3
		 and t.contenttypename in 
						('cgvBooklet',
						'cgvCancerBulletin',
						'cgvCancerTypeHome',
						'cgvClinicalTrialResult',
						'cgvDrugInfoSummary',
						'cgvFactSheet',
						'cgvFeaturedClinicalTrial',
						'cgvPowerPoint',
						'cgvPressRelease',
						'nciAppModulePage',
						'nciErrorPage',
						'nciForm',
						'nciGeneral',
						'nciHome',
						'nciLandingPage',
						'gloImage',
						'gloVideo',
						'pdqCancerInfoSummary',
						'pdqDrugInfoSummary'
						, 'nciFile'
						)
		union all

		select c1.contentid, c1.title
		, f.path+ case when p.pretty_url_name is null then '' ELSE '/' + pretty_url_name END  
		+ '/page' + convert(varchar(3),r1.sort_rank +1)
		 as primaryURL
		, t1.contenttypename
		from dbo.contentstatus c 
		inner join PSX_ObjectRelationship r  ON r.dependent_id = c.contentid
		inner join #folder f on f.id = r.owner_id
		inner join CGVPUBLISHEDPAGEMETADATA_CGVPUBLISHEDPAGEMETADATA1 p on p.contentid = c.contentid
		and p.revisionid = c.public_revision
		inner join PSX_ObjectRelationship r1 on r1.owner_id = c.contentid and r1.owner_revision = c.public_revision
		inner join contentstatus c1 on c1.contentid = r1.dependent_id
		inner join contenttypes t1 on t1.contenttypeid = c1.contenttypeid
		where  r1.config_id = 112  and c.public_revision is not null and r.config_id =3
		and c1.public_revision is not null
		order by 3

END
GO
