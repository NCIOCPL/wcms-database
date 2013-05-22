IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_createSection]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_createSection]
GO
create procedure [dbo].[usp_createSection]
@ncisectionid uniqueidentifier,
@directoryid uniqueidentifier,
@parentsectionid uniqueidentifier = null,
@leftNavID uniqueidentifier,
@objectinstanceid uniqueidentifier,
@prettyURL varchar(100),
@sectionName varchar(255),
@updateuserid varchar(50) ,
@groupid int = 3,
@tabimgName varchar(50) = NULL

as
begin

		if (@TabImgName is NULL  or @TabImgName = '' ) and  @parentsectionid is not null
			select @TabImgName =  TabImgName from dbo.ncisection where ncisectionid = @parentsectionid
		if @parentSectionid is not null
			select @groupid = groupid from dbo.sectiongroupmap where sectionid =  @parentsectionid
			
			BEGIN TRAN

			insert into dbo.ncisection
			(NCISectionID,
			--SectionHomeViewID,
			Name,
			URL,
			Description,
			UpdateDate,
			UpdateUserID,
			OrderLevel,
			TabImgName,
			parentsectionID,
			siteID)
			values 
			(@ncisectionid,  
			@sectionname, 
			'/templates/', 
			@sectionname, 
			getdate(), 
			@updateuserid,
			1,
			@TabImgName, 
			@parentsectionid, 
			'C5539960-31EA-4E5B-BCB6-819C13FAB2CF')
			if @@error <> 0
				begin
					rollback tran
					print 'insert into ncisection error'
					return 1
				end



			--2. GroupSectionMap GroupID 3 (CancerInfo)
			declare @r int
			exec  @r = dbo.usp_InsertGroupSectionMap @groupid  = @groupid , 
			@sectionid  = @NCIsectionid , @updateuserid = @updateuserid
			if @@error <> 0 and @r <> 0
				begin
					rollback tran
					print 'usp_InsertGroupSectionMap error'
					return 1
				end


			--3. Add directory

			INSERT INTO dbo.Directories  (DirectoryID, DirectoryName, CreateDate, updateUserID, UpdateDate)
			VALUES
			(@directoryid, @prettyURL, getdate(), @updateuserid, getdate())
			if @@error <> 0
				begin
					rollback tran
					print 'insert into directories error'
					return 1
				end


			INSERT INTO dbo.SectionDirectoryMap 
			(DirectoryID,
			SectionID, 
			UpdateDate, UpdateUserID) 
			VALUES 
			(@directoryid,
			@NCIsectionid, 
			GETDATE(),'zgao')

			if @@error <> 0
				begin
					rollback tran
					print 'insert into sectionDirectoryMap error'
					return 1
				end

			--5. LeftNav
			--5.1 Insert NCIView
			--5.2 Insert PrettyURL
			--5.3 Insert NCIObjects table parentObjectID = NCIsectiond


			insert into dbo.nciview
			(nciviewid,
			 ncitemplateid, 
			ncisectionid, 
			groupid, 
			title,
			shorttitle, 
			description,
			url, 
			urlarguments, 
			createdate,
			status,
			updateuserid)
			values
			(@leftNavID, 
			'D9C8A380-6A06-4AFA-86E9-EA52E50E0493', 
			@ncisectionid,
			 @groupid,
			@sectionName + 'LeftNav', 
			@sectionName + 'LeftNav', 
			@sectionName + 'LeftNav', 
			'/cancer_information/doc.aspx',
			 'viewid='+convert(varchar(100),@leftNavID),
			getdate(), 
			'SUBMIT',
			 @updateuserid)
			if @@error <> 0
				begin
					rollback tran
					print 'insert into nciView error'
					return 1
				end
			
			declare @LeftNavPrettyURL varchar(255)

			set @LeftNavPrettyURL  = @prettyURL+ '/LeftNav'

			exec @r = dbo.usp_CreatePrettyURL 
			@NCIviewID = @leftNavID, 
			@DirectoryID = @directoryid,
			@ProposedURL = @LeftNavPrettyURL, 
			@UpdateRedirectOrNot = 1, @IsPrimary = 1, 
			@UpdateUserID = @updateuserid
			if @@error <> 0 or @r <> 0
				begin
					rollback tran
					print 'usp_CreatePrettyURL  error'
					return 1
				end


			insert into dbo.nciobjects 
			(objectinstanceID, 
			nciobjectid, 
			parentnciobjectid, 
			objecttype, 
			priority)
			values 
			(@objectInstanceid,
			 @leftNavid, 
			@ncisectionid, 
			'LeftNav',
			1)
			if @@error <> 0
				begin
					rollback tran
					print 'insert into nciObjects error'
					return 1
				end

			exec @r = cancergovstaging.dbo.usp_pushNCIViewToProduction @leftNavid, @updateuserid
			if @@error <> 0 or @r <> 0
				begin
					rollback tran
					print 'usp_pushNCIViewToProduction  error'
					return 1
				end	
		
		commit tran
end

GO

grant execute on dbo.usp_createsection to webadminuser_role

