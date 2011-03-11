IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_CreatePrettyURL]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_CreatePrettyURL]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



--***********************************************************************
-- Create New Object 
--************************************************************************


--***********************************************************************
-- Create New Object 
--************************************************************************
/*
**  This procedure will create pretty url for document or summary or update pretty url for document and summary
**
**  Author: Jay He 03-08-02
**  Revision History:
** 03-20-2002 Jay He 	Added new function to load usp_checkredirectmap
** 11-18-2002 Jay He 	Added new summary_hp and summary_p from CDR
**  Return Values
**  0         Success
**  70001     The guid argument was invalid
**  70004     Failed during execution 
**  70005     Failed to create
**  70006     Failed to update
**
*/
CREATE PROCEDURE [dbo].[usp_CreatePrettyURL]
	(
	@NCIviewID uniqueidentifier,   -- this is the guid for NCIView to be approved
	@DirectoryID uniqueidentifier,   -- this is the guid of directory for the pretty url 
	@ProposedURL varchar(2000),      -- This should be defined in web.config file
	@UpdateRedirectOrNot  bit, 	-- indicate whether update redirect table
	@IsPrimary	bit,
	@UpdateUserID varchar(50)   -- This should be the username as it appears in NCIUsers table
	)
AS
BEGIN	
	SET NOCOUNT ON
	/*
	** STEP - A
	** First Validate that the nciview guid and directoryid provided is valid
	** if not return a 70001 error
	*/		
	if(	
	  (@NCIviewID IS NULL) OR (NOT EXISTS (SELECT NCIViewID FROM nciview WHERE NCIViewID = @NCIviewID)) 
	  )	
	BEGIN
		RAISERROR ( 70001, 16, 1)
		RETURN 70001
	END

	if(	
	  (@DirectoryID IS NULL) OR (NOT EXISTS (SELECT DirectoryID FROM Directories WHERE DirectoryID = @DirectoryID)) 
	  )	
	BEGIN
		RAISERROR ( 70001, 16, 1)
		RETURN 70001
	END


	/*
	** STEP - B
	** Get nciview page physical path for insert
	** Get flag for create or update 
	** if not return a 70004 error
	*/	
	DECLARE @UpdateDate datetime,
		@CreateDate datetime,
		@ObjectID uniqueidentifier,
		@ObjectType	char(10),
		@docid varchar(60),
		@PhysicalPath varchar(4000), 	
		@number int,
		@Type varchar(10),
		@DocNumber int,
		@Exist int,
		@PrettyURL varchar(2000),
		@Template varchar(50),
		@RowNumber		int,
		@VOType varchar(10)

	SELECT @UpdateDate = GETDATE(), 
		@CreateDate=GETDATE(),
		@RowNumber =0

	-- Need 4 special cases : Document, Summary, TSTOPIC and PDF
	if (exists (select objectID from ViewObjects where nciviewID =@NCIviewID and Type like 'Summary%'))
	BEGIN
		select    @Type =  'SUMMARY'
	END
	ELse 	if (exists (select objectID from ViewObjects where nciviewID =@NCIviewID and Type ='PDF'))
	BEGIN
		select    @Type =  'PDF'
	END
	ELse 	if (exists (select objectID from ViewObjects where nciviewID =@NCIviewID and Type ='TSTOPIC'))
	BEGIN
		select    @Type =  'TOPIC'
	END
	ELSE
	BEGIN
		select    @Type =  'DOCUMENT'
	END

	--differ two template. TSTOPIC has no template
	
	if @Type = 'TOPIC'
	BEGIN
		select  @Template =''
	END
	
	if @Type != 'TOPIC'
	BEGIN
		select  @Template =RTRIM(T.[ClassName]) from nciview N, NCITemplate T where T.NCITemplateID = N.NCITemplateID  and N.nciviewID =@NCIviewID  -- since 'Document' is the minimal type of all types we created. And 'Summary' is only type for pdq summary.	
	END
		

	PRINT '-- Type=' + @Type

	IF @Type ='PDF'
	BEGIN
		select 	@PhysicalPath = URL from  NCIView  where  NCIViewID =@NCIviewID
	END
	ELSE 	IF @Type ='TOPIC'
	BEGIN
		select 	@PhysicalPath = URL + IsNull(NullIf( '?'+IsNull(URLArguments,''),'?'),'')  from  NCIView  where  NCIViewID =@NCIviewID
	END
	ELSE
	BEGIN
		select 	@PhysicalPath = '/Templates/' + T.URL + IsNull(NullIf( '?'+IsNull(N.URLArguments,''),'?'),'') from NCITemplate T, NCIView N where T.NCITemplateID=N.NCITemplateID and N.NCIViewID =@NCIviewID
		PRINT ' --	Physical=' + @PhysicalPath
	END

	select    @DocNumber = count(*) from ViewObjects where NCIViewID =@NCIviewID and Type = 'DOCUMENT'

	PRINT 'docnumber=' + Convert(varchar(5), @DocNumber)

	BEGIN TRAN  Tran_CreateOrUpdatePrettyURL

	if @IsPrimary = 1
	BEGIN
		Update CancerGovStaging..PrettyURL
		set IsPrimary =0 
		Where NCIViewID = @NCIviewID
	END
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_CreateOrUpdatePrettyURL
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 

	/*
	** STEP - C
	** Loop through all objects in the ViewObjectTable and create/update each documentid for prettyurl
	** if not return a 70004 error
	*/
	IF @Template = 'MULTIPAGEDOCUMENT'  OR @Template = 'BENCHMARK'      OR @Template = 'MULTIPAGEDIGEST'
	BEGIN
		PRINT 'multi doc page --- Create AllPage for multidoc page'

		insert into CancerGovStaging..PrettyURL
		(prettyurlID, nciviewID, RealURL, ProposedURL, IsPrimary, UpdateRedirectOrNot, DirectoryID,UpdateDate, UpdateUserID, CreateDate)
		values
		(newid(), @NCIviewID, @PhysicalPath + '&allpages=1', @ProposedURL+'/AllPages', @IsPrimary, @UpdateRedirectOrNot,@DirectoryID, @UpdateDate, @UpdateUserID, @CreateDate)
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN   Tran_CreateOrUpdatePrettyURL
			RAISERROR ( 70006, 16, 1)
			RETURN  70006
		END 

		DECLARE ViewObject_Cursor CURSOR LOCAL FORWARD_ONLY  FOR
			SELECT 	ObjectID,  '&docid=' + Convert(varchar(36), ObjectID), Priority, Type
			FROM 		CancerGovStaging..ViewObjects 
			WHERE  	NCIViewID = @NCIviewID and Type ='DOCUMENT' order by priority
		FOR READ ONLY 
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN Tran_CreateOrUpdatePrettyURL
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 
		
		OPEN ViewObject_Cursor 
		IF (@@ERROR <> 0)
		BEGIN
			DEALLOCATE ViewObject_Cursor 
			ROLLBACK TRAN Tran_CreateOrUpdatePrettyURL
			RAISERROR ( 70004, 16, 1)		
			RETURN 70004
		END 
		
		FETCH NEXT FROM ViewObject_Cursor
		INTO 	@ObjectID,  @docid, @number, @VOType	

		WHILE @@FETCH_STATUS = 0
		BEGIN
			insert into CancerGovStaging..PrettyURL
			(prettyurlID, nciviewID, ObjectID, RealURL, ProposedURL, IsPrimary, UpdateRedirectOrNot, DirectoryID,UpdateDate, UpdateUserID, CreateDate)
			values
			(newid(), @NCIviewID, @ObjectID, @PhysicalPath + @docid, @ProposedURL+'/page'+Convert(varchar(4), @number), @IsPrimary, @UpdateRedirectOrNot,@DirectoryID, @UpdateDate, @UpdateUserID, @CreateDate)
			IF (@@ERROR <> 0)
			BEGIN
				CLOSE ViewObject_Cursor 
				DEALLOCATE ViewObject_Cursor 
				ROLLBACK TRAN   Tran_CreateOrUpdatePrettyURL
				RAISERROR ( 70006, 16, 1)
				RETURN  70006
			END 
			PRINT '-- insert' +  @ProposedURL+'/Page'+Convert(varchar(4), @number)

			-- GET NEXT OBJECT
			PRINT '--get next'
			FETCH NEXT FROM ViewObject_Cursor
			INTO 	@ObjectID,  @docid, @number, @VOType	

		END -- End while
	
		-- CLOSE ViewObject_Cursor		
		CLOSE ViewObject_Cursor 
		DEALLOCATE ViewObject_Cursor 
	END  
	IF  	@Template = 'MULTIPAGESUMMARY'       --- Summary health professional version
	BEGIN
		if (exists (select  objectID from ViewObjects where nciviewID =@NCIviewID and Type ='Summary_P'))
		BEGIN
			select  @ObjectID =objectID from ViewObjects where nciviewID =@NCIviewID and Type ='Summary_P'

			insert into CancerGovStaging..PrettyURL
			(prettyurlID, nciviewID, ObjectID, RealURL, ProposedURL, UpdateRedirectOrNot, IsPrimary, DirectoryID, UpdateDate, UpdateUserID, CreateDate)
			values
			(newid(), @NCIviewID, @ObjectID,  '/Templates/doc.aspx?viewid=' + Convert(varchar(36), @NCIviewID) + '&version=0', @ProposedURL + '/Patient' , @UpdateRedirectOrNot, @IsPrimary, @DirectoryID, @UpdateDate, @UpdateUserID, @CreateDate)
			IF (@@ERROR <> 0)
			BEGIN
				ROLLBACK TRAN   Tran_CreateOrUpdatePrettyURL
				RAISERROR ( 70006, 16, 1)
				RETURN  70006
			END 
		END
	
		if (exists (select objectID from ViewObjects where nciviewID =@NCIviewID and Type ='Summary_HP'))
		BEGIN
			select  @ObjectID =objectID from ViewObjects where nciviewID =@NCIviewID and Type ='Summary_HP'

			insert into CancerGovStaging..PrettyURL
			(prettyurlID, nciviewID, ObjectID,  RealURL, ProposedURL, UpdateRedirectOrNot, IsPrimary,  DirectoryID,UpdateDate, UpdateUserID, CreateDate)
			values
			(newid(), @NCIviewID,@ObjectID, '/Templates/doc.aspx?viewid=' +Convert(varchar(36),@NCIviewID) + '&version=1', @ProposedURL + '/HealthProfessional' , @UpdateRedirectOrNot, @IsPrimary,@DirectoryID, @UpdateDate, @UpdateUserID, @CreateDate)
			IF (@@ERROR <> 0)
			BEGIN
				ROLLBACK TRAN   Tran_CreateOrUpdatePrettyURL
				RAISERROR ( 70006, 16, 1)
				RETURN  70006
			END 
		END
	END

	IF @Template = 'POWERPOINTPRESENTATION'
	BEGIN
		PRINT 'Powerpointpresentation--- Create AllPage for multidoc page'

		insert into CancerGovStaging..PrettyURL
		(prettyurlID, nciviewID, RealURL, ProposedURL, IsPrimary, UpdateRedirectOrNot, DirectoryID,UpdateDate, UpdateUserID, CreateDate)
		values
		(newid(), @NCIviewID, @PhysicalPath + '&allpages=1', @ProposedURL+'/AllPages', @IsPrimary, @UpdateRedirectOrNot,@DirectoryID, @UpdateDate, @UpdateUserID, @CreateDate)
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN   Tran_CreateOrUpdatePrettyURL
			RAISERROR ( 70006, 16, 1)
			RETURN  70006
		END 

		DECLARE ViewObject_Cursor CURSOR LOCAL FORWARD_ONLY  FOR
			SELECT 	ObjectID,  '&docid=' + Convert(varchar(36), ObjectID), Priority, Type
			FROM 		CancerGovStaging..ViewObjects 
			WHERE  	NCIViewID = @NCIviewID and Type ='DOCUMENT' order by priority
		FOR READ ONLY 
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN Tran_CreateOrUpdatePrettyURL
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 
		
		OPEN ViewObject_Cursor 
		IF (@@ERROR <> 0)
		BEGIN
			DEALLOCATE ViewObject_Cursor 
			ROLLBACK TRAN Tran_CreateOrUpdatePrettyURL
			RAISERROR ( 70004, 16, 1)		
			RETURN 70004
		END 
		
		FETCH NEXT FROM ViewObject_Cursor
		INTO 	@ObjectID,  @docid, @number, @VOType	

		WHILE @@FETCH_STATUS = 0
		BEGIN
			insert into CancerGovStaging..PrettyURL
			(prettyurlID, nciviewID, ObjectID, RealURL, ProposedURL, IsPrimary, UpdateRedirectOrNot, DirectoryID,UpdateDate, UpdateUserID, CreateDate)
			values
			(newid(), @NCIviewID, @ObjectID, @PhysicalPath + @docid, @ProposedURL+'/Slide'+Convert(varchar(4), @number), @IsPrimary, @UpdateRedirectOrNot,@DirectoryID, @UpdateDate, @UpdateUserID, @CreateDate)
			IF (@@ERROR <> 0)
			BEGIN
				CLOSE ViewObject_Cursor 
				DEALLOCATE ViewObject_Cursor 
				ROLLBACK TRAN   Tran_CreateOrUpdatePrettyURL
				RAISERROR ( 70006, 16, 1)
				RETURN  70006
			END 
			PRINT '-- insert' +  @ProposedURL+'/Slide'+Convert(varchar(4), @number)

			-- GET NEXT OBJECT
			PRINT '--get next'
			FETCH NEXT FROM ViewObject_Cursor
			INTO 	@ObjectID,  @docid, @number, @VOType	

		END -- End while
	
		-- CLOSE ViewObject_Cursor		
		CLOSE ViewObject_Cursor 
		DEALLOCATE ViewObject_Cursor 
	END  

	--- Create three pretty urls for benchmark no matter whether it has animation/audio/photo.

	IF  @Template = 'BENCHMARK'     
	BEGIN
		insert into CancerGovStaging..PrettyURL
		(prettyurlID, nciviewID,  RealURL, ProposedURL, IsPrimary, UpdateRedirectOrNot, DirectoryID,UpdateDate, UpdateUserID, CreateDate)
		values
		(newid(), @NCIviewID,  @PhysicalPath + '&Page=Video', @ProposedURL+'/Video', @IsPrimary, @UpdateRedirectOrNot,@DirectoryID, @UpdateDate, @UpdateUserID, @CreateDate)
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN   Tran_CreateOrUpdatePrettyURL
			RAISERROR ( 70006, 16, 1)
			RETURN  70006
		END 
		PRINT '-- insert' +  @ProposedURL+'/Video'

		insert into CancerGovStaging..PrettyURL
		(prettyurlID, nciviewID,  RealURL, ProposedURL, IsPrimary, UpdateRedirectOrNot, DirectoryID,UpdateDate, UpdateUserID, CreateDate)
		values
		(newid(), @NCIviewID,  @PhysicalPath + '&Page=Audio', @ProposedURL+'/Audio', @IsPrimary, @UpdateRedirectOrNot,@DirectoryID, @UpdateDate, @UpdateUserID, @CreateDate)
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN   Tran_CreateOrUpdatePrettyURL
			RAISERROR ( 70006, 16, 1)
			RETURN  70006
		END 
		PRINT '-- insert' +  @ProposedURL+'/Audio'

		insert into CancerGovStaging..PrettyURL
		(prettyurlID, nciviewID,  RealURL, ProposedURL, IsPrimary, UpdateRedirectOrNot, DirectoryID,UpdateDate, UpdateUserID, CreateDate)
		values
		(newid(), @NCIviewID,  @PhysicalPath + '&Page=Photo', @ProposedURL+'/Photo', @IsPrimary, @UpdateRedirectOrNot,@DirectoryID, @UpdateDate, @UpdateUserID, @CreateDate)
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN   Tran_CreateOrUpdatePrettyURL
			RAISERROR ( 70006, 16, 1)
			RETURN  70006
		END 
		PRINT '-- insert' +  @ProposedURL+'/Photo'

		-- Loop viewobject audio and create pretty url for transcript
		
		DECLARE VO_Cursor CURSOR LOCAL FORWARD_ONLY  FOR
			SELECT 	ObjectID,  '&docid=' + Convert(varchar(36), ObjectID), Priority 
			FROM 		CancerGovStaging..ViewObjects 
			WHERE  	NCIViewID = @NCIviewID and Type ='AUDIO' order by priority
		FOR READ ONLY 
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN Tran_CreateOrUpdatePrettyURL
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 
		
		OPEN VO_Cursor 
		IF (@@ERROR <> 0)
		BEGIN
			DEALLOCATE VO_Cursor 
			ROLLBACK TRAN Tran_CreateOrUpdatePrettyURL
			RAISERROR ( 70004, 16, 1)		
			RETURN 70004
		END 
		
		FETCH NEXT FROM VO_Cursor
		INTO 	@ObjectID,  @docid, @number

		WHILE @@FETCH_STATUS = 0
		BEGIN
			select @RowNumber= @RowNumber +1

			insert into CancerGovStaging..PrettyURL
			(prettyurlID, nciviewID, ObjectID, RealURL, ProposedURL, IsPrimary, UpdateRedirectOrNot, DirectoryID,UpdateDate, UpdateUserID, CreateDate)
			values
			(newid(), @NCIviewID, @ObjectID, @PhysicalPath + @docid + '&Page=Audio', @ProposedURL+'/Audio/Transcript'+Convert(varchar(4), @RowNumber), @IsPrimary, @UpdateRedirectOrNot,@DirectoryID, @UpdateDate, @UpdateUserID, @CreateDate)
			IF (@@ERROR <> 0)
			BEGIN
				CLOSE VO_Cursor 
				DEALLOCATE VO_Cursor 
				ROLLBACK TRAN   Tran_CreateOrUpdatePrettyURL
				RAISERROR ( 70006, 16, 1)
				RETURN  70006
			END 
			PRINT '-- insert' +  @ProposedURL+'/Audio/Transcript'+Convert(varchar(4), @number)
		
			-- GET NEXT OBJECT
			PRINT '--get next'
			FETCH NEXT FROM VO_Cursor
			INTO 	@ObjectID,  @docid, @number


		END -- End while
	
		-- CLOSE VO_Cursor		
		CLOSE VO_Cursor 
		DEALLOCATE VO_Cursor 
	END  
	-- End loop



	/*
	** STEP - D
	** create/update each nciview for root prettyurl
	** if not return a 70004 error
	*/



	PRINT 'test' + @ProposedURL + '--'+   @PhysicalPath
	insert into CancerGovStaging..PrettyURL
	(prettyurlID, nciviewID, RealURL, ProposedURL, UpdateRedirectOrNot, IsPrimary, IsRoot,DirectoryID,UpdateDate, UpdateUserID, CreateDate)
	values
	(newid(), @NCIviewID, @PhysicalPath, @ProposedURL, @UpdateRedirectOrNot,@IsPrimary, 1, @DirectoryID, @UpdateDate, @UpdateUserID, @CreateDate)
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN   Tran_CreateOrUpdatePrettyURL
		RAISERROR ( 70006, 16, 1)
		RETURN  70006
	END  

	/*
	** STEP - E
	** delete each prettyurl where its document id does not exist on viewobjects table for that nciview 
	** if not return a 70006 error
	*/
	Delete from PrettyURL where NCIviewID =@NCIviewID and ObjectID not in (select objectID from ViewObjects where NCIviewID =@NCIviewID)  and  ObjectID is not null
	IF (@@ERROR <> 0)
	BEGIN
		CLOSE ViewObject_Cursor 
		DEALLOCATE ViewObject_Cursor 
		ROLLBACK TRAN   Tran_CreateOrUpdatePrettyURL
		RAISERROR ( 70006, 16, 1)
		RETURN  70006
	END 

	COMMIT TRAN   Tran_CreateOrUpdatePrettyURL

	SET NOCOUNT OFF
	RETURN 0 


END

GO
GRANT EXECUTE ON [dbo].[usp_CreatePrettyURL] TO [webadminuser_role]
GO
