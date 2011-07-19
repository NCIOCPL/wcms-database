if object_id('percReport_contentaging') is not null
	drop procedure dbo.percReport_contentaging
go
create procedure dbo.percReport_contentaging
( @folderID int, @allFolder bit)
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


			select t.contenttypelabel,c.title 
			, f.path+ case when pretty_url_name is null then '' else '/' + pretty_url_name END as primaryURL
			, c.contentlastmodifieddate as [last modified date]
			,DATE_FIRST_PUBLISHED as [posted date]
			,DATE_LAST_MODIFIED as [updated date]
			,DATE_LAST_REVIEWED  as [reviewed date]
			from dbo.contentstatus c 
					inner join PSX_ObjectRelationship r  ON r.dependent_id = c.contentid
					inner join CGVCONTENTDATES_CGVCONTENTDATES1 d on d.contentid = c.contentid and d.revisionid = c.public_revision
					inner join #folder f on f.id = r.owner_id
					inner join contenttypes t on t.contenttypeid = c.contenttypeid
					left outer join dbo.CGVPUBLISHEDPAGEMETADATA_CGVPUBLISHEDPAGEMETADATA1 p on p.contentid = c.contentid and p.revisionid = c.public_revision
					where contenttypename in
			('cgvBooklet',
			'cgvCancerBulletin',	
			'cgvCancerTypeHome', 	
			'cgvClinicalTrialResult', 	
			'cgvDrugInfoSummary', 	
			'cgvFactSheet', 	
			'cgvFeaturedClinicalTrial', 	
			'cgvPowerPoint',	
			'cgvPressRelease', 	
			'gloImage', 	
			'gloVideo', 	
			'nciAppModulePage', 	
			'nciErrorPage', 	
			'nciFile', 	
			'nciGeneral', 	
			'nciHome', 	
			'nciLandingPage', 	
			'pdqCancerInfoSummary', 	
			'pdqDrugInfoSummary')
					

END