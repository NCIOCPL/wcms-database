IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_UpdatePrettyURL]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_UpdatePrettyURL]
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
**  This procedure will update pretty url for document and summary
**
**  Author: Jay He 03-08-02
**  Revision History:
** 03-20-2002 Jay He 	Added new function to load usp_checkredirectmap
** 04-05-2002 Jay He      Derived from usp_checkorUpdatePrettyURL
11-18-2002	Jay He	Update pretty url with new cdr
**  Return Values
**  0         Success
**  70001     The guid argument was invalid
**  70004     Failed during execution 
**  70005     Failed to create
**  70006     Failed to update
**
*/
CREATE PROCEDURE [dbo].[usp_UpdatePrettyURL]
	(
	@PrettyURLID 		uniqueidentifier,   	-- this is the guid for PrettyURL to be Updated
	@NCIviewID 		uniqueidentifier,   	-- this is the guid for NCIView to be Updated
	@DirectoryID 		uniqueidentifier,   	-- this is the guid of directory for the pretty url 
	@ProposedURL 	varchar(2000),      	-- new proposed url
	@UpdateRedirectOrNot  bit, 			-- indicate whether update redirect table
	@IsPrimary		bit,			-- whether it is a default one or not
	@UpdateUserID 	varchar(50)   		-- This should be the username as it appears in NCIUsers table
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

	if(	
	  (@PrettyURLID IS NULL) OR (NOT EXISTS (SELECT PrettyURLID FROM   PrettyURL WHERE PrettyURLID= @PrettyURLID))
	  )	
	BEGIN
		RAISERROR ( 70001, 16, 1)
		RETURN 70001
	END

	if(	
	  NOT EXISTS (SELECT PrettyURLID FROM   PrettyURL WHERE PrettyURLID= @PrettyURLID and NCIViewID=@NCIviewID )
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
	DECLARE @UpdateDate 	datetime,
		@CreateDate 		datetime,
		@ObjectID 		uniqueidentifier,
		@ObjectType		char(10),
		@TemplateType		varchar(50),
		@docid 		varchar(60),
		@count 		int, 
		@PhysicalPath 		varchar(4000), 	
		@number 		int,
		@Type 			varchar(10),
		@DocNumber 		int,
		@Exist 			int,
		@ExistCurrent		int,
		@PrettyURL 		varchar(2000),
		@PropURL		varchar(2000) , -- Existing proposed url
		@CurrentURL		varchar(2000),  --Exisitng current url
		@sourceID 		varchar(50),
		@VOType		varchar(10),
		@RowNumber		int
	
	select @RowNumber=0

	SELECT @UpdateDate = GETDATE(), 
		@CreateDate=GETDATE()

	-- Need three special cases : Document, Summary, and PDF

	if (exists (select objectID from ViewObjects where nciviewID =@NCIviewID and Type like 'Summary%'))
	BEGIN
		select    @Type =  'SUMMARY'
	END
	ELse
	if (exists (select objectID from ViewObjects where nciviewID =@NCIviewID and Type ='PDF'))
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

	PRINT '--	Type=' + @Type


	select 	@CurrentURL= CurrentURL, @PropURL = ProposedURL from prettyurl where prettyURLID =@PrettyURLID 
	
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
	select  @TemplateType =UPPER(RTRIM(T.[ClassName])) from nciview N, NCITemplate T where T.NCITemplateID = N.NCITemplateID  and N.nciviewID =@NCIviewID  -- since 'Document' is the minimal type of all types we created. And 'Summary' is only type for pdq summary.
	

	BEGIN TRAN  Tran_CreateOrUpdatePrettyURL

	/* If IsPrimary is true, update other prettyurl for this nciview to false
	*/
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

	IF @TemplateType = 'MULTIPAGEDOCUMENT' or @TemplateType = 'MULTIPAGEDIGEST' or @TemplateType = 'BENCHMARK'  or @TemplateType = 'POWERPOINTPRESENTATION'
	BEGIN
		IF @PropURL is null
		BEGIN
			Update CancerGovStaging..PrettyURL
			set 	ProposedURL 	= @ProposedURL + '/AllPages' ,
				UpdateRedirectOrNot = @UpdateRedirectOrNot,
				IsPrimary	= @IsPrimary,
				DirectoryID 	= @DirectoryID,
				UpdateDate 	= @UpdateDate,
				UpdateUserID  	= @UpdateUserID 
			WHERE nciviewID= @NCIviewID AND CurrentURL =  @CurrentURL + '/AllPages'
			IF (@@ERROR <> 0)
			BEGIN
				ROLLBACK TRAN   Tran_CreateOrUpdatePrettyURL
				RAISERROR ( 70005, 16, 1)
				RETURN  70005
			END
		END
		ELSE
		BEGIN
			Update CancerGovStaging..PrettyURL
			set 	ProposedURL 	= @ProposedURL + '/AllPages' ,
				UpdateRedirectOrNot = @UpdateRedirectOrNot,
				IsPrimary	= @IsPrimary,
				DirectoryID 	= @DirectoryID,
				UpdateDate 	= @UpdateDate,
				UpdateUserID  	= @UpdateUserID 
			WHERE nciviewID= @NCIviewID AND ProposedURL =  @PropURL + '/AllPages'
			IF (@@ERROR <> 0)
			BEGIN
				ROLLBACK TRAN   Tran_CreateOrUpdatePrettyURL
				RAISERROR ( 70005, 16, 1)
				RETURN  70005
			END
		END
	END
	/*
	** STEP - C
	** Loop through all objects in the ViewObjectTable and update each documentid for prettyurl
	** if not return a 70004 error
	*/
	IF @PropURL is null
	BEGIN
		PRINT '--- PropURL is null'
		IF @TemplateType = 'MULTIPAGEDOCUMENT' or @TemplateType = 'MULTIPAGEDIGEST' or @TemplateType = 'BENCHMARK'
		BEGIN
			DECLARE ViewObject_Cursor CURSOR LOCAL FORWARD_ONLY  FOR
				SELECT 	ObjectID,  '&docid=' + Convert(varchar(36), ObjectID), Priority, Type
				FROM 		CancerGovStaging..ViewObjects 
				WHERE  	NCIViewID = @NCIviewID and Type ='DOCUMENT' 
				order by 	priority
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
				
					select  @Exist = Count(*) from CancerGovStaging..PrettyURL where  ObjectID=@ObjectID and NCIViewID = @NCIviewID and  CurrentURL= @CurrentURL +'/Page'+Convert(varchar(4), @number)

					select  @ExistCurrent = Count(*) from CancerGovStaging..PrettyURL where  ObjectID=@ObjectID and NCIViewID = @NCIviewID and  ProposedURL= @CurrentURL +'/Page'+Convert(varchar(4), @number)
										
					PRINT '-- 	Proposed URL is	--'
					if  @Exist =0  and @ExistCurrent =0 -- newly created pretty url
					BEGIN
						insert into CancerGovStaging..PrettyURL
						(prettyurlID, nciviewID, ObjectID, RealURL, ProposedURL, UpdateRedirectOrNot, IsPrimary, DirectoryID,UpdateDate, UpdateUserID, CreateDate)
						values
						(newid(), @NCIviewID, @ObjectID, @PhysicalPath + @docid, @ProposedURL+'/page'+Convert(varchar(4), @number), @UpdateRedirectOrNot, @IsPrimary,@DirectoryID, @UpdateDate, @UpdateUserID, @CreateDate)
						IF (@@ERROR <> 0)
						BEGIN
							CLOSE ViewObject_Cursor 
							DEALLOCATE ViewObject_Cursor 
							ROLLBACK TRAN   Tran_CreateOrUpdatePrettyURL
							RAISERROR ( 70006, 16, 1)
							RETURN  70006
						END 
					END  
					ELSE  -- Update existing 
					BEGIN
						Update CancerGovStaging..PrettyURL
						set 	ProposedURL 	= @ProposedURL + '/page' + Convert(varchar(4),@number),
							UpdateRedirectOrNot = @UpdateRedirectOrNot,
							IsPrimary	= @IsPrimary,
							DirectoryID 	= @DirectoryID,
							UpdateDate 	= @UpdateDate,
							UpdateUserID  	= @UpdateUserID 
						WHERE nciviewID= @NCIviewID AND ObjectID=@ObjectID 
							 AND CurrentURL =  @CurrentURL + '/page'+Convert(varchar(4), @number) 	 	
						IF (@@ERROR <> 0)
						BEGIN
							CLOSE ViewObject_Cursor 
							DEALLOCATE ViewObject_Cursor 
							ROLLBACK TRAN   Tran_CreateOrUpdatePrettyURL
							RAISERROR ( 70005, 16, 1)
							RETURN  70005
						END

						Update CancerGovStaging..PrettyURL
						set 	ProposedURL 	= @ProposedURL + '/page' + Convert(varchar(4),@number),
							UpdateRedirectOrNot = @UpdateRedirectOrNot,
							IsPrimary	= @IsPrimary,
							DirectoryID 	= @DirectoryID,
							UpdateDate 	= @UpdateDate,
							UpdateUserID  	= @UpdateUserID 
						WHERE nciviewID= @NCIviewID AND ObjectID=@ObjectID 
							 AND ProposedURL =  @CurrentURL + '/page'+Convert(varchar(4), @number) 		 	
						IF (@@ERROR <> 0)
						BEGIN
							CLOSE ViewObject_Cursor 
							DEALLOCATE ViewObject_Cursor 
							ROLLBACK TRAN   Tran_CreateOrUpdatePrettyURL
							RAISERROR ( 70005, 16, 1)
							RETURN  70005
						END
									
				END
				-- GET NEXT OBJECT
				PRINT '--get next'
				FETCH NEXT FROM ViewObject_Cursor
				INTO 	@ObjectID,  @docid, @number, @VOType	

			END -- End while
	
			-- CLOSE ViewObject_Cursor		
			CLOSE ViewObject_Cursor 
			DEALLOCATE ViewObject_Cursor 
		END  
		ELSE
		IF  	@Type = 'SUMMARY'       --- Summary 
		BEGIN
			Update CancerGovStaging..PrettyURL
			set 	ProposedURL = @ProposedURL + '/Patient',
						UpdateRedirectOrNot = @UpdateRedirectOrNot,
						IsPrimary	= @IsPrimary,
						DirectoryID =@DirectoryID,
						UpdateDate 	= @UpdateDate,
						UpdateUserID  	= @UpdateUserID 
			WHERE nciviewID= @NCIviewID 
				AND CurrentURL =  @CurrentURL + '/Patient' 	and isroot=0	
			IF (@@ERROR <> 0)
			BEGIN
					ROLLBACK TRAN   Tran_CreateOrUpdatePrettyURL
					RAISERROR ( 70005, 16, 1)
					RETURN  70005
			END 

			Update CancerGovStaging..PrettyURL
			set 	ProposedURL = @ProposedURL + '/HealthProfessional',
						UpdateRedirectOrNot = @UpdateRedirectOrNot,
						IsPrimary	= @IsPrimary,
						DirectoryID =@DirectoryID,
						UpdateDate 	= @UpdateDate,
						UpdateUserID  	= @UpdateUserID 
			WHERE nciviewID= @NCIviewID 
				AND CurrentURL =  @CurrentURL + '/HealthProfessional' and isroot=0	
			IF (@@ERROR <> 0)
			BEGIN
					ROLLBACK TRAN   Tran_CreateOrUpdatePrettyURL
					RAISERROR ( 70005, 16, 1)
					RETURN  70005
			END 
		END
		ELSE
		IF @TemplateType = 'POWERPOINTPRESENTATION'
		BEGIN
			DECLARE ViewObject_Cursor CURSOR LOCAL FORWARD_ONLY  FOR
				SELECT 	ObjectID,  '&docid=' + Convert(varchar(36), ObjectID), Priority, Type
				FROM 		CancerGovStaging..ViewObjects 
				WHERE  	NCIViewID = @NCIviewID and Type ='DOCUMENT' 
				order by 	priority
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
				
					select  @Exist = Count(*) from CancerGovStaging..PrettyURL where  ObjectID=@ObjectID and NCIViewID = @NCIviewID and  CurrentURL= @CurrentURL +'/Slide'+Convert(varchar(4), @number)

					select  @ExistCurrent = Count(*) from CancerGovStaging..PrettyURL where  ObjectID=@ObjectID and NCIViewID = @NCIviewID and  ProposedURL= @CurrentURL +'/Slide'+Convert(varchar(4), @number)
										
					PRINT '-- 	Proposed URL is	--'
					if  @Exist =0  and @ExistCurrent =0 -- newly created pretty url
					BEGIN
						insert into CancerGovStaging..PrettyURL
						(prettyurlID, nciviewID, ObjectID, RealURL, ProposedURL, UpdateRedirectOrNot, IsPrimary, DirectoryID,UpdateDate, UpdateUserID, CreateDate)
						values
						(newid(), @NCIviewID, @ObjectID, @PhysicalPath + @docid, @ProposedURL+'/Slide'+Convert(varchar(4), @number), @UpdateRedirectOrNot, @IsPrimary,@DirectoryID, @UpdateDate, @UpdateUserID, @CreateDate)
						IF (@@ERROR <> 0)
						BEGIN
							CLOSE ViewObject_Cursor 
							DEALLOCATE ViewObject_Cursor 
							ROLLBACK TRAN   Tran_CreateOrUpdatePrettyURL
							RAISERROR ( 70006, 16, 1)
							RETURN  70006
						END 
					END  
					ELSE  -- Update existing 
					BEGIN
						Update CancerGovStaging..PrettyURL
						set 	ProposedURL 	= @ProposedURL + '/Slide' + Convert(varchar(4),@number),
							UpdateRedirectOrNot = @UpdateRedirectOrNot,
							IsPrimary	= @IsPrimary,
							DirectoryID 	= @DirectoryID,
							UpdateDate 	= @UpdateDate,
							UpdateUserID  	= @UpdateUserID 
						WHERE nciviewID= @NCIviewID AND ObjectID=@ObjectID 
							 AND CurrentURL =  @CurrentURL + '/Slide'+Convert(varchar(4), @number) 	 	
						IF (@@ERROR <> 0)
						BEGIN
							CLOSE ViewObject_Cursor 
							DEALLOCATE ViewObject_Cursor 
							ROLLBACK TRAN   Tran_CreateOrUpdatePrettyURL
							RAISERROR ( 70005, 16, 1)
							RETURN  70005
						END

						Update CancerGovStaging..PrettyURL
						set 	ProposedURL 	= @ProposedURL + '/Slide' + Convert(varchar(4),@number),
							UpdateRedirectOrNot = @UpdateRedirectOrNot,
							IsPrimary	= @IsPrimary,
							DirectoryID 	= @DirectoryID,
							UpdateDate 	= @UpdateDate,
							UpdateUserID  	= @UpdateUserID 
						WHERE nciviewID= @NCIviewID AND ObjectID=@ObjectID 
							 AND ProposedURL =  @CurrentURL + '/Slide'+Convert(varchar(4), @number) 		 	
						IF (@@ERROR <> 0)
						BEGIN
							CLOSE ViewObject_Cursor 
							DEALLOCATE ViewObject_Cursor 
							ROLLBACK TRAN   Tran_CreateOrUpdatePrettyURL
							RAISERROR ( 70005, 16, 1)
							RETURN  70005
						END
									
				END
				-- GET NEXT OBJECT
				PRINT '--get next'
				FETCH NEXT FROM ViewObject_Cursor
				INTO 	@ObjectID,  @docid, @number, @VOType	

			END -- End while
	
			-- CLOSE ViewObject_Cursor		
			CLOSE ViewObject_Cursor 
			DEALLOCATE ViewObject_Cursor 
		END  

		/*
		** STEP - D
		** create/update each nciview for prettyurl
		** if not return a 70004 error
		*/
		BEGIN
			Update CancerGovStaging..PrettyURL
			set 	ProposedURL = @ProposedURL,
				UpdateRedirectOrNot = @UpdateRedirectOrNot,
				IsPrimary	= @IsPrimary,
				DirectoryID =@DirectoryID,
				UpdateDate 	= @UpdateDate,
				UpdateUserID  	= @UpdateUserID 
			WHERE nciviewID= @NCIviewID and PrettyURLID= @PrettyURLID 
			IF (@@ERROR <> 0)
			BEGIN
				ROLLBACK TRAN   Tran_CreateOrUpdatePrettyURL
				RAISERROR ( 70005, 16, 1)
				RETURN  70005
			END 
		END
	END
	ELSE     -- with proposed url exising, which means we need to search for existing proposed url match
	BEGIN
		IF @TemplateType = 'MULTIPAGEDOCUMENT' or @TemplateType = 'MULTIPAGEDIGEST' or @TemplateType = 'BENCHMARK'
		BEGIN
			DECLARE ViewObject_Cursor CURSOR LOCAL FORWARD_ONLY  FOR
				SELECT 	ObjectID,  '&docid=' + Convert(varchar(36), ObjectID), Priority, Type
				FROM 		CancerGovStaging..ViewObjects 
				WHERE  	NCIViewID = @NCIviewID and Type ='DOCUMENT' 
				order by 	priority
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
				select  @Exist = Count(*) from CancerGovStaging..PrettyURL where  ObjectID=@ObjectID and NCIViewID = @NCIviewID and  ProposedURL= @PropURL +'/Page'+Convert(varchar(4), @number)
		
				select  @ExistCurrent = Count(*) from CancerGovStaging..PrettyURL where  ObjectID=@ObjectID and NCIViewID = @NCIviewID and  ProposedURL= @CurrentURL +'/Page'+Convert(varchar(4), @number)
		
				if  @Exist =0  and @ExistCurrent=0  -- newly created pretty url
				BEGIN
					insert into CancerGovStaging..PrettyURL
					(prettyurlID, nciviewID, ObjectID, RealURL, ProposedURL, UpdateRedirectOrNot, IsPrimary, DirectoryID,UpdateDate, UpdateUserID, CreateDate)
					values
					(newid(), @NCIviewID, @ObjectID, @PhysicalPath + @docid, @ProposedURL+'/page'+Convert(varchar(4), @number), @UpdateRedirectOrNot, @IsPrimary,@DirectoryID, @UpdateDate, @UpdateUserID, @CreateDate)
					IF (@@ERROR <> 0)
					BEGIN
						CLOSE ViewObject_Cursor 
						DEALLOCATE ViewObject_Cursor 
						ROLLBACK TRAN   Tran_CreateOrUpdatePrettyURL
						RAISERROR ( 70006, 16, 1)
						RETURN  70006
					END 
				END  
				ELSE  -- Update existing 
				BEGIN
					Update CancerGovStaging..PrettyURL
					set 	ProposedURL 	= @ProposedURL + '/page' + Convert(varchar(4),@number),
						UpdateRedirectOrNot = @UpdateRedirectOrNot,
						IsPrimary	= @IsPrimary,
						DirectoryID 	= @DirectoryID,
						UpdateDate 	= @UpdateDate,
						UpdateUserID  	= @UpdateUserID 
					WHERE nciviewID= @NCIviewID AND ObjectID=@ObjectID 
						 AND  ProposedURL  =  @PropURL + '/page'+Convert(varchar(4), @number)		 	
					IF (@@ERROR <> 0)
					BEGIN
						CLOSE ViewObject_Cursor 
						DEALLOCATE ViewObject_Cursor 
						ROLLBACK TRAN   Tran_CreateOrUpdatePrettyURL
						RAISERROR ( 70005, 16, 1)
						RETURN  70005
					END
	
					Update CancerGovStaging..PrettyURL
					set 	ProposedURL 	= @ProposedURL + '/page' + Convert(varchar(4),@number),
						UpdateRedirectOrNot = @UpdateRedirectOrNot,
						IsPrimary	= @IsPrimary,
						DirectoryID 	= @DirectoryID,
						UpdateDate 	= @UpdateDate,
						UpdateUserID  	= @UpdateUserID 
					WHERE nciviewID= @NCIviewID AND ObjectID=@ObjectID 
						 AND  ProposedURL  =  @CurrentURL + '/page'+Convert(varchar(4), @number)		 	
					IF (@@ERROR <> 0)
					BEGIN
						CLOSE ViewObject_Cursor 
						DEALLOCATE ViewObject_Cursor 
						ROLLBACK TRAN   Tran_CreateOrUpdatePrettyURL
						RAISERROR ( 70005, 16, 1)
						RETURN  70005
					END
				END
				-- GET NEXT OBJECT
				PRINT '--get next'
				FETCH NEXT FROM ViewObject_Cursor
				INTO 	@ObjectID,  @docid, @number, @VOType	

			END -- End while
	
			-- CLOSE ViewObject_Cursor		
			CLOSE ViewObject_Cursor 
			DEALLOCATE ViewObject_Cursor 
		END  

		IF  	@Type = 'SUMMARY'       --- Summary 
		BEGIN
			Update CancerGovStaging..PrettyURL
			set 	ProposedURL = @ProposedURL + '/Patient',
						UpdateRedirectOrNot = @UpdateRedirectOrNot,
						IsPrimary	= @IsPrimary,
						DirectoryID =@DirectoryID,
						UpdateDate 	= @UpdateDate,
						UpdateUserID  	= @UpdateUserID 
			WHERE nciviewID= @NCIviewID 
				AND ProposedURL= @PropURL + '/Patient' 	
			IF (@@ERROR <> 0)
			BEGIN
					ROLLBACK TRAN   Tran_CreateOrUpdatePrettyURL
					RAISERROR ( 70005, 16, 1)
					RETURN  70005
			END 

			Update CancerGovStaging..PrettyURL
			set 	ProposedURL = @ProposedURL + '/HealthProfessional',
						UpdateRedirectOrNot = @UpdateRedirectOrNot,
						IsPrimary	= @IsPrimary,
						DirectoryID =@DirectoryID,
						UpdateDate 	= @UpdateDate,
						UpdateUserID  	= @UpdateUserID 
			WHERE nciviewID= @NCIviewID 
				AND  ProposedURL= @PropURL + '/HealthProfessional'
			IF (@@ERROR <> 0)
			BEGIN
					ROLLBACK TRAN   Tran_CreateOrUpdatePrettyURL
					RAISERROR ( 70005, 16, 1)
					RETURN  70005
			END 
		END

		IF @TemplateType = 'POWERPOINTPRESENTATION'
		BEGIN
			DECLARE ViewObject_Cursor CURSOR LOCAL FORWARD_ONLY  FOR
				SELECT 	ObjectID,  '&docid=' + Convert(varchar(36), ObjectID), Priority, Type
				FROM 		CancerGovStaging..ViewObjects 
				WHERE  	NCIViewID = @NCIviewID and Type ='DOCUMENT' 
				order by 	priority
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
				select  @Exist = Count(*) from CancerGovStaging..PrettyURL where  ObjectID=@ObjectID and NCIViewID = @NCIviewID and  ProposedURL= @PropURL +'/Slide'+Convert(varchar(4), @number)
		
				select  @ExistCurrent = Count(*) from CancerGovStaging..PrettyURL where  ObjectID=@ObjectID and NCIViewID = @NCIviewID and  ProposedURL= @CurrentURL +'/Slide'+Convert(varchar(4), @number)
		
				if  @Exist =0  and @ExistCurrent=0  -- newly created pretty url
				BEGIN
					insert into CancerGovStaging..PrettyURL
					(prettyurlID, nciviewID, ObjectID, RealURL, ProposedURL, UpdateRedirectOrNot, IsPrimary, DirectoryID,UpdateDate, UpdateUserID, CreateDate)
					values
					(newid(), @NCIviewID, @ObjectID, @PhysicalPath + @docid, @ProposedURL+'/Slide'+Convert(varchar(4), @number), @UpdateRedirectOrNot, @IsPrimary,@DirectoryID, @UpdateDate, @UpdateUserID, @CreateDate)
					IF (@@ERROR <> 0)
					BEGIN
						CLOSE ViewObject_Cursor 
						DEALLOCATE ViewObject_Cursor 
						ROLLBACK TRAN   Tran_CreateOrUpdatePrettyURL
						RAISERROR ( 70006, 16, 1)
						RETURN  70006
					END 
				END  
				ELSE  -- Update existing 
				BEGIN
					Update CancerGovStaging..PrettyURL
					set 	ProposedURL 	= @ProposedURL + '/Slide' + Convert(varchar(4),@number),
						UpdateRedirectOrNot = @UpdateRedirectOrNot,
						IsPrimary	= @IsPrimary,
						DirectoryID 	= @DirectoryID,
						UpdateDate 	= @UpdateDate,
						UpdateUserID  	= @UpdateUserID 
					WHERE nciviewID= @NCIviewID AND ObjectID=@ObjectID 
						 AND  ProposedURL  =  @PropURL + '/Slide'+Convert(varchar(4), @number)		 	
					IF (@@ERROR <> 0)
					BEGIN
						CLOSE ViewObject_Cursor 
						DEALLOCATE ViewObject_Cursor 
						ROLLBACK TRAN   Tran_CreateOrUpdatePrettyURL
						RAISERROR ( 70005, 16, 1)
						RETURN  70005
					END
	
					Update CancerGovStaging..PrettyURL
					set 	ProposedURL 	= @ProposedURL + '/Slide' + Convert(varchar(4),@number),
						UpdateRedirectOrNot = @UpdateRedirectOrNot,
						IsPrimary	= @IsPrimary,
						DirectoryID 	= @DirectoryID,
						UpdateDate 	= @UpdateDate,
						UpdateUserID  	= @UpdateUserID 
					WHERE nciviewID= @NCIviewID AND ObjectID=@ObjectID 
						 AND  ProposedURL  =  @CurrentURL + '/Slide'+Convert(varchar(4), @number)		 	
					IF (@@ERROR <> 0)
					BEGIN
						CLOSE ViewObject_Cursor 
						DEALLOCATE ViewObject_Cursor 
						ROLLBACK TRAN   Tran_CreateOrUpdatePrettyURL
						RAISERROR ( 70005, 16, 1)
						RETURN  70005
					END
				END
				-- GET NEXT OBJECT
				PRINT '--get next'
				FETCH NEXT FROM ViewObject_Cursor
				INTO 	@ObjectID,  @docid, @number, @VOType	

			END -- End while
	
			-- CLOSE ViewObject_Cursor		
			CLOSE ViewObject_Cursor 
			DEALLOCATE ViewObject_Cursor 
		END  

		/*
		** STEP - D
		** create/update each nciview for prettyurl
		** if not return a 70004 error
		*/
		BEGIN
			Update CancerGovStaging..PrettyURL
			set 	ProposedURL = @ProposedURL,
				UpdateRedirectOrNot = @UpdateRedirectOrNot,
				IsPrimary	= @IsPrimary,
				DirectoryID =@DirectoryID,
				UpdateDate 	= @UpdateDate,
				UpdateUserID  	= @UpdateUserID 
			WHERE nciviewID= @NCIviewID and PrettyURLID= @PrettyURLID 
			IF (@@ERROR <> 0)
			BEGIN
				ROLLBACK TRAN   Tran_CreateOrUpdatePrettyURL
				RAISERROR ( 70005, 16, 1)
				RETURN  70005
			END 
		END
	END
	

	/* Update existing prettyurl benchmark
	*/
	if (@TemplateType ='BENCHMARK')
	BEGIN
		IF @PropURL is not null
		BEGIN
			-- Update Audio
			Update CancerGovStaging..PrettyURL
			set 	ProposedURL 	= @ProposedURL + '/Audio' ,
				UpdateRedirectOrNot = @UpdateRedirectOrNot,
				IsPrimary	= @IsPrimary,
				DirectoryID 	= @DirectoryID,
				UpdateDate 	= @UpdateDate,
				UpdateUserID  	= @UpdateUserID 
			WHERE nciviewID= @NCIviewID
				 AND ProposedURL  =  @PropURL + '/Audio'		
			IF (@@ERROR <> 0)
			BEGIN
				ROLLBACK TRAN   Tran_CreateOrUpdatePrettyURL
				RAISERROR ( 70005, 16, 1)
				RETURN  70005
			END 

			-- Update Audio
			Update CancerGovStaging..PrettyURL
			set 	ProposedURL 	= @ProposedURL + '/Photo' ,
				UpdateRedirectOrNot = @UpdateRedirectOrNot,
				IsPrimary	= @IsPrimary,
				DirectoryID 	= @DirectoryID,
				UpdateDate 	= @UpdateDate,
				UpdateUserID  	= @UpdateUserID 
			WHERE nciviewID= @NCIviewID 
				 AND ProposedURL  =  @PropURL + '/Photo'		
			IF (@@ERROR <> 0)
			BEGIN
				ROLLBACK TRAN   Tran_CreateOrUpdatePrettyURL
				RAISERROR ( 70005, 16, 1)
				RETURN  70005
			END 

			-- Update Audio
			Update CancerGovStaging..PrettyURL
			set 	ProposedURL 	= @ProposedURL + '/Video' ,
				UpdateRedirectOrNot = @UpdateRedirectOrNot,
				IsPrimary	= @IsPrimary,
				DirectoryID 	= @DirectoryID,
				UpdateDate 	= @UpdateDate,
				UpdateUserID  	= @UpdateUserID 
			WHERE nciviewID= @NCIviewID 
				 AND ProposedURL  =  @PropURL + '/Video'		
			IF (@@ERROR <> 0)
			BEGIN
				ROLLBACK TRAN   Tran_CreateOrUpdatePrettyURL
				RAISERROR ( 70005, 16, 1)
				RETURN  70005
			END 

			-- Update audio transcript
			DECLARE ViewObject_Cursor CURSOR LOCAL FORWARD_ONLY  FOR
				SELECT 	ObjectID,  '&docid=' + Convert(varchar(36), ObjectID), Priority, Type
				FROM 		CancerGovStaging..ViewObjects 
				WHERE  	NCIViewID = @NCIviewID and Type ='Audio' order by priority
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
				select @RowNumber= @RowNumber +1
				
				select  @Exist = Count(*) from CancerGovStaging..PrettyURL where  ObjectID=@ObjectID and NCIViewID = @NCIviewID  AND ProposedURL  like  @PropURL +'/Audio/Transcript%' 

				select  @ExistCurrent = Count(*) from CancerGovStaging..PrettyURL where  ObjectID=@ObjectID and NCIViewID = @NCIviewID AND CurrentURL  like  @CurrentURL +'/Audio/Transcript%'

				if  @Exist =0 and @ExistCurrent =0 -- newly created pretty url
				BEGIN
					insert into CancerGovStaging..PrettyURL
					(prettyurlID, nciviewID, ObjectID, RealURL, ProposedURL, UpdateRedirectOrNot, IsPrimary, DirectoryID,UpdateDate, UpdateUserID, CreateDate)
					values
					(newid(), @NCIviewID, @ObjectID, @PhysicalPath + @docid +'&Page=Audio', @ProposedURL+'/Audio/Transcript'  + Convert(varchar(2), @RowNumber), @UpdateRedirectOrNot, @IsPrimary,@DirectoryID, @UpdateDate, @UpdateUserID, @CreateDate)
					IF (@@ERROR <> 0)
					BEGIN
						CLOSE ViewObject_Cursor 
						DEALLOCATE ViewObject_Cursor 
						ROLLBACK TRAN   Tran_CreateOrUpdatePrettyURL
						RAISERROR ( 70006, 16, 1)
						RETURN  70006
					END 
				END  
				ELSE if @ExistCurrent =0 and  @Exist <>0   -- Update existing proposed (no current) 
				BEGIN
					Update CancerGovStaging..PrettyURL
					set 	ProposedURL 	= @ProposedURL +'/Audio/Transcript' + Convert(varchar(2), @RowNumber), 
						UpdateRedirectOrNot = @UpdateRedirectOrNot,
						IsPrimary	= @IsPrimary,
						DirectoryID 	= @DirectoryID,
						UpdateDate 	= @UpdateDate,
						UpdateUserID  	= @UpdateUserID 
					WHERE nciviewID= @NCIviewID AND ObjectID=@ObjectID 
						 AND ProposedURL  like  @PropURL +'/Audio/Transcript%' 
					IF (@@ERROR <> 0)
					BEGIN
						CLOSE ViewObject_Cursor 
						DEALLOCATE ViewObject_Cursor 
						ROLLBACK TRAN   Tran_CreateOrUpdatePrettyURL
						RAISERROR ( 70005, 16, 1)
						RETURN  70005
					END
				END
				ELSE  -- on production, no proposed
				BEGIN
 					Update CancerGovStaging..PrettyURL
					set 	ProposedURL 	= @ProposedURL +'/Audio/Transcript' + Convert(varchar(2), @RowNumber), 
						UpdateRedirectOrNot = @UpdateRedirectOrNot,
						IsPrimary	= @IsPrimary,
						DirectoryID 	= @DirectoryID,
						UpdateDate 	= @UpdateDate,
						UpdateUserID  	= @UpdateUserID 
					WHERE nciviewID= @NCIviewID AND ObjectID=@ObjectID 
						 AND CurrentURL  like  @CurrentURL +'/Audio/Transcript%'  
					IF (@@ERROR <> 0)
					BEGIN
						CLOSE ViewObject_Cursor 
						DEALLOCATE ViewObject_Cursor 
						ROLLBACK TRAN   Tran_CreateOrUpdatePrettyURL
						RAISERROR ( 70005, 16, 1)
						RETURN  70005
					END
				END
				-- GET NEXT OBJECT
				PRINT '--get next'
				FETCH NEXT FROM ViewObject_Cursor
				INTO 	@ObjectID,  @docid, @number, @VOType	

			END -- End while
	
			-- CLOSE ViewObject_Cursor		
			CLOSE ViewObject_Cursor 
			DEALLOCATE ViewObject_Cursor 
		END
		ELSE
		BEGIN
			-- Update Audio
			Update CancerGovStaging..PrettyURL
			set 	ProposedURL 	= @ProposedURL + '/Audio' ,
				UpdateRedirectOrNot = @UpdateRedirectOrNot,
				IsPrimary	= @IsPrimary,
				DirectoryID 	= @DirectoryID,
				UpdateDate 	= @UpdateDate,
				UpdateUserID  	= @UpdateUserID 
			WHERE nciviewID= @NCIviewID
				 AND CurrentURL  =  @CurrentURL + '/Audio'		
			IF (@@ERROR <> 0)
			BEGIN
				ROLLBACK TRAN   Tran_CreateOrUpdatePrettyURL
				RAISERROR ( 70005, 16, 1)
				RETURN  70005
			END 

			-- Update Audio
			Update CancerGovStaging..PrettyURL
			set 	ProposedURL 	= @ProposedURL + '/Photo' ,
				UpdateRedirectOrNot = @UpdateRedirectOrNot,
				IsPrimary	= @IsPrimary,
				DirectoryID 	= @DirectoryID,
				UpdateDate 	= @UpdateDate,
				UpdateUserID  	= @UpdateUserID 
			WHERE nciviewID= @NCIviewID 
				 AND CurrentURL  =@CurrentURL + '/Photo'		
			IF (@@ERROR <> 0)
			BEGIN
				ROLLBACK TRAN   Tran_CreateOrUpdatePrettyURL
				RAISERROR ( 70005, 16, 1)
				RETURN  70005
			END 

			-- Update Audio
			Update CancerGovStaging..PrettyURL
			set 	ProposedURL 	= @ProposedURL + '/Video' ,
				UpdateRedirectOrNot = @UpdateRedirectOrNot,
				IsPrimary	= @IsPrimary,
				DirectoryID 	= @DirectoryID,
				UpdateDate 	= @UpdateDate,
				UpdateUserID  	= @UpdateUserID 
			WHERE nciviewID= @NCIviewID 
				 AND CurrentURL  =  @CurrentURL + '/Video'		
			IF (@@ERROR <> 0)
			BEGIN
				ROLLBACK TRAN   Tran_CreateOrUpdatePrettyURL
				RAISERROR ( 70005, 16, 1)
				RETURN  70005
			END 


			-- Update audio transcript
			DECLARE ViewObject_Cursor CURSOR LOCAL FORWARD_ONLY  FOR
				SELECT 	ObjectID,  '&docid=' + Convert(varchar(36), ObjectID), Priority, Type
				FROM 		CancerGovStaging..ViewObjects 
				WHERE  	NCIViewID = @NCIviewID and Type ='Audio' order by priority
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
				select @RowNumber= @RowNumber +1

				select  @Exist = Count(*) from CancerGovStaging..PrettyURL where  ObjectID=@ObjectID and NCIViewID = @NCIviewID  AND ProposedURL  like  @CurrentURL +'/Audio/Transcript%' 

				select  @ExistCurrent = Count(*) from CancerGovStaging..PrettyURL where  ObjectID=@ObjectID and NCIViewID = @NCIviewID AND CurrentURL  like  @CurrentURL +'/Audio/Transcript%' 

				if  @Exist =0 and @ExistCurrent =0 -- newly created pretty url
				BEGIN
					insert into CancerGovStaging..PrettyURL
					(prettyurlID, nciviewID, ObjectID, RealURL, ProposedURL, UpdateRedirectOrNot, IsPrimary, DirectoryID,UpdateDate, UpdateUserID, CreateDate)
					values
					(newid(), @NCIviewID, @ObjectID, @PhysicalPath + @docid +'&Page=Audio', @ProposedURL+'/Audio/Transcript'  + Convert(varchar(2), @RowNumber), @UpdateRedirectOrNot, @IsPrimary,@DirectoryID, @UpdateDate, @UpdateUserID, @CreateDate)
					IF (@@ERROR <> 0)
					BEGIN
						CLOSE ViewObject_Cursor 
						DEALLOCATE ViewObject_Cursor 
						ROLLBACK TRAN   Tran_CreateOrUpdatePrettyURL
						RAISERROR ( 70006, 16, 1)
						RETURN  70006
					END 
				END  
				ELSE if @ExistCurrent =0 and  @Exist <>0   -- Update existing proposed (no current) 
				BEGIN
					Update CancerGovStaging..PrettyURL
					set 	ProposedURL 	= @ProposedURL +'/Audio/Transcript' + Convert(varchar(2), @RowNumber), 
						UpdateRedirectOrNot = @UpdateRedirectOrNot,
						IsPrimary	= @IsPrimary,
						DirectoryID 	= @DirectoryID,
						UpdateDate 	= @UpdateDate,
						UpdateUserID  	= @UpdateUserID 
					WHERE nciviewID= @NCIviewID AND ObjectID=@ObjectID 
						 AND ProposedURL  like  @CurrentURL +'/Audio/Transcript%' 	
					IF (@@ERROR <> 0)
					BEGIN
						CLOSE ViewObject_Cursor 
						DEALLOCATE ViewObject_Cursor 
						ROLLBACK TRAN   Tran_CreateOrUpdatePrettyURL
						RAISERROR ( 70005, 16, 1)
						RETURN  70005
					END
				END
				ELSE  -- on production, no proposed
				BEGIN
 					Update CancerGovStaging..PrettyURL
					set 	ProposedURL 	= @ProposedURL +'/Audio/Transcript' + Convert(varchar(2), @RowNumber), 
						UpdateRedirectOrNot = @UpdateRedirectOrNot,
						IsPrimary	= @IsPrimary,
						DirectoryID 	= @DirectoryID,
						UpdateDate 	= @UpdateDate,
						UpdateUserID  	= @UpdateUserID 
					WHERE nciviewID= @NCIviewID AND ObjectID=@ObjectID 
						 AND CurrentURL  like  @CurrentURL +'/Audio/Transcript%'  	
					IF (@@ERROR <> 0)
					BEGIN
						CLOSE ViewObject_Cursor 
						DEALLOCATE ViewObject_Cursor 
						ROLLBACK TRAN   Tran_CreateOrUpdatePrettyURL
						RAISERROR ( 70005, 16, 1)
						RETURN  70005
					END
				END
				-- GET NEXT OBJECT
				PRINT '--get next'
				FETCH NEXT FROM ViewObject_Cursor
				INTO 	@ObjectID,  @docid, @number, @VOType	

			END -- End while
	
			-- CLOSE ViewObject_Cursor		
			CLOSE ViewObject_Cursor 
			DEALLOCATE ViewObject_Cursor 
		END
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
GRANT EXECUTE ON [dbo].[usp_UpdatePrettyURL] TO [webadminuser_role]
GO
