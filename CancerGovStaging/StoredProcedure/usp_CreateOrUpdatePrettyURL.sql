IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_CreateOrUpdatePrettyURL]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_CreateOrUpdatePrettyURL]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



--***********************************************************************
-- Create New Object 
--************************************************************************


/****** Object:  Stored Procedure dbo.usp_RetrieveNCIView  
* Owner:Jhe 
* Purpose: For admin side Script Date: 10/07/2003 16:00:49 pm ******/

/*
**  This procedure will create pretty url for document or summary or update pretty url for document and summary
**
**  Author: Jay He 03-08-02
**  Revision History:
** 03-20-2002 Jay He 	Added new function to load usp_checkredirectmap
** 11-18-2202 Jay He      Added new prettyurl update/create function for new CDR summary (summary_hp and summary_p)
**  Return Values
**  0         Success
**  70001     The guid argument was invalid
**  70004     Failed during execution 
**  70005     Failed to create
**  70006     Failed to update
**
**   12/12/2008  1 --> @isPrimary SCR30305
*/
CREATE PROCEDURE [dbo].[usp_CreateOrUpdatePrettyURL]
	(
	@NCIviewID uniqueidentifier,   -- this is the guid for NCIView to be approved
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
	PRINT 'start'		
	if(	
	  (@NCIviewID IS NULL) OR (NOT EXISTS (SELECT NCIViewID FROM nciview WHERE NCIViewID = @NCIviewID)) 
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
	DECLARE @DirectoryID uniqueidentifier,
		@ObjectID uniqueidentifier,
		@ObjectType	char(10),
		@docid varchar(60),
		@PhysicalPath varchar(4000), 	
		@number int,
		@RowNumber int,
		@Type varchar(30),
		@DocNumber int,
		@Exist int,
		@ExistNext int,
		@ExistThird int,
		@UpdateDate datetime,
		@CreateDate datetime,
		@ProposedURL varchar(2000),      -- This should be defined in web.config file
		@UpdateRedirectOrNot  bit, 	-- indicate whether update redirect table
		@IsPrimary	bit,
		@PrettyURL varchar(2000),
		@DetailTOCID	uniqueidentifier,	--OESI
		@TOCID	uniqueidentifier	--OESI
	

	SELECT  @UpdateDate = GETDATE(), 
		@CreateDate=GETDATE(),
		@RowNumber=0

	-- Get Page's Physical Path
	select 	@PhysicalPath = '/Templates/' + T.URL + IsNull(NullIf( '?'+IsNull(N.URLArguments,''),'?'),'') 
	from NCITemplate T, NCIView N where T.NCITemplateID=N.NCITemplateID and N.NCIViewID =@NCIviewID

	-- The types (template classname) allows to distinguish single/mulitdoc.

	select  @Type =UPPER(RTRIM(T.[ClassName])) from nciview N, NCITemplate T where T.NCITemplateID = N.NCITemplateID  and N.nciviewID =@NCIviewID  -- since 'Document' is the minimal type of all types we created. And 'Summary' is only type for pdq summary.
	
	PRINT 'type= ' + @Type + ' -- path== ' + @PhysicalPath
	
	BEGIN TRAN  Tran_CreateOrUpdatePrettyURL
	/*
	** STEP - A
	** Loop through all objects in the ViewObjectTable and create  new prettyurl for each new added  documentid 
	** if not return a 70004 error
	*/
	if (@type ='MULTIPAGESUMMARY') -- PDQ
	BEGIN
		--Check pretty url for each PRIMARY PRETTY URL 
		DECLARE ViewObject_Cursor CURSOR LOCAL FORWARD_ONLY  FOR
			SELECT 	DirectoryID, IsPrimary, UpdateRedirectOrNot, CurrentURL, ProposedURL 
			FROM 	CancerGovStaging..PrettyURL
			WHERE  	NCIViewID = @NCIviewID and ObjectID is null
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
		INTO 	@DirectoryID,  @IsPrimary, @UpdateRedirectOrNot, @PrettyURL, @ProposedURL

		WHILE @@FETCH_STATUS = 0
		BEGIN		
			PRINT 'ProposedURL=' + @ProposedURL
			IF  @ProposedURL is not null
			BEGIN
				select  @Exist = Count(*) from CancerGovStaging..PrettyURL U,  CancerGovStaging..ViewObjects V
				where  U.ObjectID=V.ObjectID and U.NCIViewID = V.NCIViewID and U.NCIViewID = @NCIviewID 
						and V.Type='SUMMARY_P' and ProposedURL = @ProposedURL+'/Patient' and U.isroot=0	

				select  @ExistNext = Count(*) from CancerGovStaging..ViewObjects
				where  NCIViewID = @NCIviewID and Type='SUMMARY_P' 

				select  @ObjectID= ObjectID from CancerGovStaging..ViewObjects
				where  NCIViewID = @NCIviewID and Type='SUMMARY_P'

				PRINT 'Exist = ' + convert(varchar(2), @Exist)	+'ExistNext = ' + convert(varchar(2), @ExistNext)	
				if @ExistNext !=0   -- Exists Summary_p VO
				BEGIN		
					if  @Exist =0   -- Newly created summary_p VO without prettyurl
					BEGIN
						PRINT 'insert summary_h'
						insert into CancerGovStaging..PrettyURL
						(prettyurlID, nciviewID, ObjectID, RealURL, ProposedURL, UpdateRedirectOrNot, IsPrimary, DirectoryID,UpdateDate, UpdateUserID, CreateDate)
						values
						(newid(), @NCIviewID, @ObjectID, @PhysicalPath + '&version=0', @ProposedURL+'/Patient', @UpdateRedirectOrNot, @isPrimary,@DirectoryID, @UpdateDate, @UpdateUserID, @CreateDate)
						--SCR30305
						
						IF (@@ERROR <> 0)
						BEGIN
							DEALLOCATE ViewObject_Cursor 
							ROLLBACK TRAN Tran_CreateOrUpdatePrettyURL
							RAISERROR ( 70006, 16, 1)
							RETURN  70006
						END	
					END 
					ELSE  -- Update existing proposedurl in case user updates priority
					BEGIN
						PRINT 'Update summary_p'
						Update CancerGovStaging..PrettyURL
						set 	ProposedURL = @ProposedURL + '/Patient',
								UpdateRedirectOrNot = @UpdateRedirectOrNot,
								IsPrimary	= @IsPrimary,
								DirectoryID 	=@DirectoryID,
								UpdateDate 	= @UpdateDate,
								UpdateUserID  	= @UpdateUserID 
						WHERE nciviewID= @NCIviewID AND ObjectID=@ObjectID and  ProposedURL = @ProposedURL+'/Patient%'	and isroot=0	 	
						IF (@@ERROR <> 0)
						BEGIN
							DEALLOCATE ViewObject_Cursor 
							ROLLBACK TRAN Tran_CreateOrUpdatePrettyURL
							RAISERROR ( 70005, 16, 1)
							RETURN  70005
						END
					END
				END

				--Summary_HP
				select  @Exist = Count(*) from CancerGovStaging..PrettyURL U,  CancerGovStaging..ViewObjects V
				where  U.ObjectID=V.ObjectID and U.NCIViewID = V.NCIViewID and U.NCIViewID = @NCIviewID 
					and V.Type='SUMMARY_HP' and ProposedURL= @ProposedURL+'/HealthProfessional' and U.isroot=0	
	
				select  @ExistNext = Count(*) from CancerGovStaging..ViewObjects
				where  NCIViewID = @NCIviewID and Type='SUMMARY_HP'

				select  @ObjectID= ObjectID from CancerGovStaging..ViewObjects
				where  NCIViewID = @NCIviewID and Type='SUMMARY_HP'

				PRINT 'Exist = ' + convert(varchar(2), @Exist)	+'ExistNext = ' + convert(varchar(2), @ExistNext)	
				if @ExistNext !=0   -- exists summary_hp VO
				BEGIN
					if  @Exist =0   -- newly created summary_hp 
					BEGIN
						PRINT 'insert summary_hp'
						insert into CancerGovStaging..PrettyURL
						(prettyurlID, nciviewID, ObjectID, RealURL, ProposedURL, UpdateRedirectOrNot, IsPrimary, DirectoryID,UpdateDate, UpdateUserID, CreateDate)
						values
						(newid(), @NCIviewID, @ObjectID, @PhysicalPath + '&version=1', @ProposedURL+'/HealthProfessional', @UpdateRedirectOrNot, @isPrimary,@DirectoryID, @UpdateDate, @UpdateUserID, @CreateDate)
						IF (@@ERROR <> 0)
						BEGIN
							DEALLOCATE ViewObject_Cursor 
							ROLLBACK TRAN Tran_CreateOrUpdatePrettyURL
							RAISERROR ( 70006, 16, 1)
							RETURN  70006
						END
					END 
					ELSE  -- Update existing proposedurl in case user updates priority
					BEGIN
						PRINT 'Update summary_hp'
						Update CancerGovStaging..PrettyURL
						set 	ProposedURL = @ProposedURL + '/HealthProfessional',
								UpdateRedirectOrNot = @UpdateRedirectOrNot,
								IsPrimary	= @IsPrimary,
								DirectoryID 	=@DirectoryID,
								UpdateDate 	= @UpdateDate,
								UpdateUserID  	= @UpdateUserID 
						WHERE nciviewID= @NCIviewID AND ObjectID=@ObjectID and  ProposedURL = @ProposedURL+'/HealthProfessional%'	and isroot=0	 	
						IF (@@ERROR <> 0)
						BEGIN
							DEALLOCATE ViewObject_Cursor 
							ROLLBACK TRAN Tran_CreateOrUpdatePrettyURL
							RAISERROR ( 70005, 16, 1)
							RETURN  70005
						END
					END
				END
			END 
			ELSE 	-- @ProposedURL is null.  Thus we will use currenturl to create new one for newly-created VO
			BEGIN
				PRINT 'ProposedURL is null, use currentURL '
				select  @Exist = Count(*) from  CancerGovStaging..PrettyURL U,  CancerGovStaging..ViewObjects V
				where  U.ObjectID=V.ObjectID and U.NCIViewID = V.NCIViewID and U.NCIViewID = @NCIviewID 
					and V.Type='SUMMARY_P' and CurrentURL = @PrettyURL+'/Patient' and U.isroot=0			

				select  @ExistThird = Count(*) from  CancerGovStaging..PrettyURL U,  CancerGovStaging..ViewObjects V
				where  U.ObjectID=V.ObjectID and U.NCIViewID = V.NCIViewID and U.NCIViewID = @NCIviewID 
					and V.Type='SUMMARY_P' and ProposedURL = @PrettyURL+'/Patient'	and U.isroot=0	

				select  @ExistNext = Count(*) from CancerGovStaging..ViewObjects
				where  NCIViewID = @NCIviewID and Type='SUMMARY_P'

				select  @ObjectID= ObjectID from CancerGovStaging..ViewObjects
				where  NCIViewID = @NCIviewID and Type='SUMMARY_P'

				PRINT 'Exist = ' + convert(varchar(2), @Exist)	+'ExistNext = ' + convert(varchar(2), @ExistNext)	
				if @ExistNext !=0   -- Exists Summary_P
				BEGIN
					if ( @Exist=0 and @ExistThird=0 )-- newly created summary_p without new pretty url
					BEGIN
						PRINT 'Exist =0, no summary patient PU'
						insert into CancerGovStaging..PrettyURL
						(prettyurlID, nciviewID, ObjectID, RealURL, ProposedURL, UpdateRedirectOrNot, IsPrimary, DirectoryID,UpdateDate, UpdateUserID, CreateDate)
						values
						(newid(), @NCIviewID, @ObjectID, @PhysicalPath + '&version=0', @PrettyURL+'/Patient', @UpdateRedirectOrNot, @IsPrimary,@DirectoryID, @UpdateDate, @UpdateUserID, @CreateDate)
						IF (@@ERROR <> 0)
						BEGIN
							DEALLOCATE ViewObject_Cursor 
							ROLLBACK TRAN Tran_CreateOrUpdatePrettyURL
							RAISERROR ( 70006, 16, 1)
							RETURN  70006
						END
					END 
					ELSE if ( @Exist=0 and @ExistThird > 0)-- newly created summary_p with  new pretty url as ProposedURL
					BEGIN
						PRINT 'Existing summary patient PU'
						Update CancerGovStaging..PrettyURL
						set 	ProposedURL = @PrettyURL + '/Patient',
							UpdateRedirectOrNot = @UpdateRedirectOrNot,
							IsPrimary	= @IsPrimary,
							DirectoryID 	=@DirectoryID,
							UpdateDate 	= @UpdateDate,
							UpdateUserID  	= @UpdateUserID 
						WHERE nciviewID= @NCIviewID AND ObjectID=@ObjectID and ProposedURL = @PrettyURL+'/Patient%' and isroot=0	
						IF (@@ERROR <> 0)
						BEGIN
							DEALLOCATE ViewObject_Cursor 
							ROLLBACK TRAN Tran_CreateOrUpdatePrettyURL
							RAISERROR ( 70005, 16, 1)
							RETURN  70005
						END
					END
					ELSE if ( @Exist > 0 and @ExistThird = 0)
					BEGIN
						PRINT 'Existing summary patient PU'
						Update CancerGovStaging..PrettyURL
						set 	ProposedURL = @PrettyURL + '/Patient',
							UpdateRedirectOrNot = @UpdateRedirectOrNot,
							IsPrimary	= @IsPrimary,
							DirectoryID 	=@DirectoryID,
							UpdateDate 	= @UpdateDate,
							UpdateUserID  	= @UpdateUserID 
						WHERE nciviewID= @NCIviewID AND ObjectID=@ObjectID and CurrentURL = @PrettyURL+'/Patient%'	 and isroot=0	
						IF (@@ERROR <> 0)
						BEGIN
							DEALLOCATE ViewObject_Cursor 
							ROLLBACK TRAN Tran_CreateOrUpdatePrettyURL
							RAISERROR ( 70005, 16, 1)
							RETURN  70005
						END
					END
					ELSE if ( @Exist > 0 and @ExistThird > 0)
					BEGIN
						PRINT 'Existing summary patient PU'
						Update CancerGovStaging..PrettyURL
						set 	ProposedURL = @PrettyURL + '/Patient',
							UpdateRedirectOrNot = @UpdateRedirectOrNot,
							IsPrimary	= @IsPrimary,
							DirectoryID 	=@DirectoryID,
							UpdateDate 	= @UpdateDate,
							UpdateUserID  	= @UpdateUserID 
						WHERE nciviewID= @NCIviewID AND ObjectID=@ObjectID and CurrentURL = @PrettyURL+'/Patient%'	and ProposedURL = @PrettyURL+'/Patient%' and isroot=0	
						IF (@@ERROR <> 0)
						BEGIN
							DEALLOCATE ViewObject_Cursor 
							ROLLBACK TRAN Tran_CreateOrUpdatePrettyURL
							RAISERROR ( 70005, 16, 1)
							RETURN  70005
						END
					END
				END
			
				select  @Exist = Count(*) from  CancerGovStaging..PrettyURL U,  CancerGovStaging..ViewObjects V
				where  U.ObjectID=V.ObjectID and U.NCIViewID = V.NCIViewID and U.NCIViewID = @NCIviewID 
					and V.Type='SUMMARY_HP' and CurrentURL = @PrettyURL+'/HealthProfessional'		and U.isroot=0	

				select  @ExistThird = Count(*) from  CancerGovStaging..PrettyURL U,  CancerGovStaging..ViewObjects V
				where  U.ObjectID=V.ObjectID and U.NCIViewID = V.NCIViewID and U.NCIViewID = @NCIviewID 
					and V.Type='SUMMARY_HP' and ProposedURL = @PrettyURL+'/HealthProfessional'	and U.isroot=0	

				select  @ExistNext = Count(*) from CancerGovStaging..ViewObjects
				where  NCIViewID = @NCIviewID and Type='SUMMARY_HP'

				select  @ObjectID= ObjectID from CancerGovStaging..ViewObjects
				where  NCIViewID = @NCIviewID and Type='SUMMARY_HP'

				PRINT 'Exist = ' + convert(varchar(2), @Exist)	+'ExistNext = ' + convert(varchar(2), @ExistNext)	
				if @ExistNext !=0
				BEGIN
					if  (@Exist =0 and @ExistThird=0 )-- newly created summary_hp 
					BEGIN
						PRINT 'Exist =0'
						insert into CancerGovStaging..PrettyURL
						(prettyurlID, nciviewID, ObjectID, RealURL, ProposedURL, UpdateRedirectOrNot, IsPrimary, DirectoryID,UpdateDate, UpdateUserID, CreateDate)
						values
						(newid(), @NCIviewID, @ObjectID, @PhysicalPath + '&version=1', @PrettyURL+'/HealthProfessional', @UpdateRedirectOrNot, @IsPrimary,@DirectoryID, @UpdateDate, @UpdateUserID, @CreateDate)
						IF (@@ERROR <> 0)
						BEGIN
							DEALLOCATE ViewObject_Cursor 
							ROLLBACK TRAN Tran_CreateOrUpdatePrettyURL
							RAISERROR ( 70006, 16, 1)
							RETURN  70006
						END
					END 
					ELSE  if (@Exist =0 and @ExistThird >0 )-- newly created summary_hp 
					BEGIN
						PRINT 'Existing hp '
						Update CancerGovStaging..PrettyURL
						set 	ProposedURL = @PrettyURL +'/HealthProfessional',
							UpdateRedirectOrNot = @UpdateRedirectOrNot,
							IsPrimary	= @IsPrimary,
							DirectoryID 	=@DirectoryID,
							UpdateDate 	= @UpdateDate,
							UpdateUserID  	= @UpdateUserID 
						WHERE nciviewID= @NCIviewID AND ObjectID=@ObjectID and ProposedURL = @PrettyURL+'/HealthProfessional%'	 	and isroot=0	
						IF (@@ERROR <> 0)
						BEGIN
							DEALLOCATE ViewObject_Cursor 
							ROLLBACK TRAN Tran_CreateOrUpdatePrettyURL
							RAISERROR ( 70005, 16, 1)
							RETURN  70005
						END
					END
					ELSE  if (@Exist >0 and @ExistThird =0 )-- newly created summary_hp 
					BEGIN
						PRINT 'Existing hp '
						Update CancerGovStaging..PrettyURL
						set 	ProposedURL = @PrettyURL +'/HealthProfessional',
							UpdateRedirectOrNot = @UpdateRedirectOrNot,
							IsPrimary	= @IsPrimary,
							DirectoryID 	=@DirectoryID,
							UpdateDate 	= @UpdateDate,
							UpdateUserID  	= @UpdateUserID 
						WHERE nciviewID= @NCIviewID AND ObjectID=@ObjectID and CurrentURL = @PrettyURL+'/HealthProfessional%'	 	and isroot=0	
						IF (@@ERROR <> 0)
						BEGIN
							DEALLOCATE ViewObject_Cursor 
							ROLLBACK TRAN Tran_CreateOrUpdatePrettyURL
							RAISERROR ( 70005, 16, 1)
							RETURN  70005
						END
					END
					ELSE if (@Exist >0 and @ExistThird >0 )-- newly created summary_hp 
					BEGIN
						PRINT 'Existing hp '
						Update CancerGovStaging..PrettyURL
						set 	ProposedURL = @PrettyURL +'/HealthProfessional',
							UpdateRedirectOrNot = @UpdateRedirectOrNot,
							IsPrimary	= @IsPrimary,
							DirectoryID 	=@DirectoryID,
							UpdateDate 	= @UpdateDate,
							UpdateUserID  	= @UpdateUserID 
						WHERE nciviewID= @NCIviewID AND ObjectID=@ObjectID and CurrentURL = @PrettyURL+'/HealthProfessional%'	
							and ProposedURL = @PrettyURL+'/HealthProfessional%'	 	and isroot=0	
						IF (@@ERROR <> 0)
						BEGIN
							DEALLOCATE ViewObject_Cursor 
							ROLLBACK TRAN Tran_CreateOrUpdatePrettyURL
							RAISERROR ( 70005, 16, 1)
							RETURN  70005
						END
					END
				END
			END
			
		
			FETCH NEXT FROM ViewObject_Cursor
			INTO 	@DirectoryID,  @IsPrimary, @UpdateRedirectOrNot, @PrettyURL, @ProposedURL
		END
		
		CLOSE ViewObject_Cursor 
		DEALLOCATE ViewObject_Cursor 

		/*
		** STEP - B
		** delete each prettyurl where its summary id does not exist on viewobjects table for that nciview 
		** if not return a 70006 error
		*/
		Delete from PrettyURL where NCIviewID =@NCIviewID and ObjectID not in (select objectID from ViewObjects where NCIviewID =@NCIviewID)  and  ObjectID is not null
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN   Tran_CreateOrUpdatePrettyURL
			RAISERROR ( 70006, 16, 1)
			RETURN  70006
		END 	
	END
	ELSE if (@type ='POWERPOINTPRESENTATION' ) -- all other document pretty urls
	BEGIN
		DECLARE ViewObject_Cursor CURSOR LOCAL FORWARD_ONLY  FOR
			SELECT 	ObjectID,  '&docid=' + Convert(varchar(36), ObjectID), Priority
			FROM 	CancerGovStaging..ViewObjects 
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
		INTO 	@ObjectID,  @docid, @number	

		WHILE @@FETCH_STATUS = 0
		BEGIN
			--create another cursor for distinguished prettyurl-- update  -- check viewobjects id first. If exists, update pretty url table. Otherwise, create new row for that viewobject'
			PRINT 'start within viewobject_cursor with objectid =' + convert(varchar(40), @ObjectID) + '         docid= ' + convert(varchar(40), @docid) 

			DECLARE PrettyURL_Cursor CURSOR LOCAL FORWARD_ONLY  FOR
			SELECT 	DirectoryID,  IsPrimary, UpdateRedirectOrNot, CurrentURL, ProposedURL 
			FROM 		CancerGovStaging..PrettyURL
			WHERE  	NCIViewID = @NCIviewID and ObjectID is null and isroot=1
			FOR READ ONLY 
			IF (@@ERROR <> 0)
			BEGIN
				ROLLBACK TRAN Tran_CreateOrUpdatePrettyURL
				RAISERROR ( 70004, 16, 1)
				RETURN 70004
			END 
		
			OPEN  PrettyURL_Cursor
			IF (@@ERROR <> 0)
			BEGIN
				DEALLOCATE PrettyURL_Cursor
				ROLLBACK TRAN Tran_CreateOrUpdatePrettyURL
				RAISERROR ( 70004, 16, 1)		
				RETURN 70004
			END 
		
			FETCH NEXT FROM PrettyURL_Cursor
			INTO 	@DirectoryID, 	@IsPrimary,   @UpdateRedirectOrNot, @PrettyURL, @ProposedURL 

			WHILE @@FETCH_STATUS = 0
			BEGIN
				PRINT '1ProposedURL=' + @ProposedURL + 'objectid=' + Convert(varchar(36), @ObjectID)
				IF  @ProposedURL is not null
				BEGIN

					select  @Exist = Count(*) from CancerGovStaging..PrettyURL where  ObjectID=@ObjectID and NCIViewID = @NCIviewID and ProposedURL like  @ProposedURL+'/Slide%'
					PRINT '2proposedurl is not null  --Exist = ' + convert(varchar(2), @Exist)	
					if  @Exist =0   -- newly created doc id 
					BEGIN
						PRINT '3insert'
						insert into CancerGovStaging..PrettyURL
						(prettyurlID, nciviewID, ObjectID, RealURL, ProposedURL, UpdateRedirectOrNot, IsPrimary, DirectoryID,UpdateDate, UpdateUserID, CreateDate)
						values
						(newid(), @NCIviewID, @ObjectID, @PhysicalPath + @docid, @ProposedURL+'/Slide'+Convert(varchar(4), @number), @UpdateRedirectOrNot, @isPrimary,@DirectoryID, @UpdateDate, @UpdateUserID, @CreateDate)
						IF (@@ERROR <> 0)
						BEGIN

							CLOSE ViewObject_Cursor 
							DEALLOCATE ViewObject_Cursor 
							ROLLBACK TRAN   Tran_CreateOrUpdatePrettyURL
							RAISERROR ( 70006, 16, 1)
							RETURN  70006
						END
						
					END 
					ELSE  -- Update existing proposedurl in case user updates priority
					BEGIN
						PRINT '4update'
						Update CancerGovStaging..PrettyURL
						set 	ProposedURL = @ProposedURL + '/Slide' + Convert(varchar(4),@number),
							UpdateRedirectOrNot = @UpdateRedirectOrNot,
							IsPrimary	= @IsPrimary,
							DirectoryID 	=@DirectoryID,
							UpdateDate 	= @UpdateDate,
							UpdateUserID  	= @UpdateUserID 
						WHERE nciviewID= @NCIviewID AND ObjectID=@ObjectID and  ProposedURL like @ProposedURL+'/Slide%'	 	
						IF (@@ERROR <> 0)
						BEGIN
							CLOSE ViewObject_Cursor 
							DEALLOCATE ViewObject_Cursor 
							ROLLBACK TRAN   Tran_CreateOrUpdatePrettyURL
							RAISERROR ( 70005, 16, 1)
							RETURN  70005
						END
					END
				END 
				ELSE 	-- @ProposedURL is null  Thus we will use currenturl to create new one for newly-created doc
				BEGIN
					PRINT '5ProposedURL is null '
					select  @Exist = Count(*) from CancerGovStaging..PrettyURL where  ObjectID=@ObjectID and NCIViewID = @NCIviewID and CurrentURL like @PrettyURL+'/Slide%' 
					select  @ExistNext = Count(*) from CancerGovStaging..PrettyURL where  ObjectID=@ObjectID and NCIViewID = @NCIviewID and ProposedURL like @PrettyURL+'/Slide%' 				

					if  @Exist =0  and @ExistNext=0  -- newly created doc id 
					BEGIN
						PRINT '6Exist =0 0'
						insert into CancerGovStaging..PrettyURL
						(prettyurlID, nciviewID, ObjectID, RealURL, ProposedURL, UpdateRedirectOrNot, IsPrimary, DirectoryID,UpdateDate, UpdateUserID, CreateDate)
						values
						(newid(), @NCIviewID, @ObjectID, @PhysicalPath + @docid, @PrettyURL+'/Slide'+Convert(varchar(4), @number), @UpdateRedirectOrNot, @IsPrimary,@DirectoryID, @UpdateDate, @UpdateUserID, @CreateDate)
						IF (@@ERROR <> 0)
						BEGIN
							CLOSE ViewObject_Cursor 
							DEALLOCATE ViewObject_Cursor 
							ROLLBACK TRAN   Tran_CreateOrUpdatePrettyURL
							RAISERROR ( 70006, 16, 1)
							RETURN  70006
						END
					END 
					ELSE  
					if @Exist <> 0 and @ExistNext =0 -- Update existing proposedurl in case user updates priority
					BEGIN
						PRINT '7Existing on <>0 0 '
						Update CancerGovStaging..PrettyURL
						set 	ProposedURL = @PrettyURL + '/Slide' + Convert(varchar(4),@number),
							UpdateRedirectOrNot = @UpdateRedirectOrNot,
							IsPrimary	= @IsPrimary,
							DirectoryID 	=@DirectoryID,
							UpdateDate 	= @UpdateDate,
							UpdateUserID  	= @UpdateUserID 
						WHERE nciviewID= @NCIviewID AND ObjectID=@ObjectID and CurrentURL like @PrettyURL+'/Slide%'	 	
						IF (@@ERROR <> 0)
						BEGIN
							CLOSE ViewObject_Cursor 
							DEALLOCATE ViewObject_Cursor 
							ROLLBACK TRAN   Tran_CreateOrUpdatePrettyURL
							RAISERROR ( 70005, 16, 1)
							RETURN  70005
						END
					END
					ELSE  
					if @Exist = 0 and @ExistNext  <> 0 -- Update existing proposedurl in case user updates priority
					BEGIN
						PRINT '8Existing on 0 <>0 '
						Update CancerGovStaging..PrettyURL
						set 	ProposedURL = @PrettyURL + '/Slide' + Convert(varchar(4),@number),
							UpdateRedirectOrNot = @UpdateRedirectOrNot,
							IsPrimary	= @IsPrimary,
							DirectoryID 	=@DirectoryID,
							UpdateDate 	= @UpdateDate,
							UpdateUserID  	= @UpdateUserID 
						WHERE nciviewID= @NCIviewID AND ObjectID=@ObjectID and ProposedURL like @PrettyURL+'/Slide%'	 	
						IF (@@ERROR <> 0)
						BEGIN
							CLOSE ViewObject_Cursor 
							DEALLOCATE ViewObject_Cursor 
							ROLLBACK TRAN   Tran_CreateOrUpdatePrettyURL
							RAISERROR ( 70005, 16, 1)
							RETURN  70005
						END
					END
					ELSE
					if @Exist <> 0 and @ExistNext  <> 0 -- Update existing proposedurl in case user updates priority
					BEGIN
						PRINT '9Existing on 0<>0<>0'
						Update CancerGovStaging..PrettyURL
						set 	ProposedURL = @PrettyURL + '/Slide' + Convert(varchar(4),@number),
							UpdateRedirectOrNot = @UpdateRedirectOrNot,
							IsPrimary	= @IsPrimary,
							DirectoryID 	=@DirectoryID,
							UpdateDate 	= @UpdateDate,
							UpdateUserID  	= @UpdateUserID 
						WHERE nciviewID= @NCIviewID AND ObjectID=@ObjectID and ProposedURL like @PrettyURL+'/Slide%'	 and CurrentURL like @PrettyURL+'/Slide%'
						IF (@@ERROR <> 0)
						BEGIN
							CLOSE ViewObject_Cursor 
							DEALLOCATE ViewObject_Cursor 
							ROLLBACK TRAN   Tran_CreateOrUpdatePrettyURL
							RAISERROR ( 70005, 16, 1)
							RETURN  70005
						END
					END
				END 
			
				FETCH NEXT FROM PrettyURL_Cursor
				INTO 	@DirectoryID, 	@IsPrimary,   @UpdateRedirectOrNot, @PrettyURL, @ProposedURL 
			END -- End while
	
			-- CLOSE ViewObject_Cursor		
			CLOSE PrettyURL_Cursor
			DEALLOCATE PrettyURL_Cursor

			-- GET NEXT OBJECT
			PRINT '10--get next'
			FETCH NEXT FROM ViewObject_Cursor
			INTO 	@ObjectID,  @docid, @number	

		END -- End while
	
		-- CLOSE ViewObject_Cursor		
		CLOSE ViewObject_Cursor 
		DEALLOCATE ViewObject_Cursor 

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
	END
	ELSE  -- all other document pretty urls
	BEGIN
		DECLARE ViewObject_Cursor CURSOR LOCAL FORWARD_ONLY  FOR
			SELECT 	ObjectID,  '&docid=' + Convert(varchar(36), ObjectID), Priority
			FROM 	CancerGovStaging..ViewObjects 
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
		INTO 	@ObjectID,  @docid, @number	

		WHILE @@FETCH_STATUS = 0
		BEGIN
			--create another cursor for distinguished prettyurl-- update  -- check viewobjects id first. If exists, update pretty url table. Otherwise, create new row for that viewobject'
			PRINT 'start within viewobject_cursor with objectid =' + convert(varchar(40), @ObjectID) + '         docid= ' + convert(varchar(40), @docid) 

			DECLARE PrettyURL_Cursor CURSOR LOCAL FORWARD_ONLY  FOR
			SELECT 	DirectoryID,  IsPrimary, UpdateRedirectOrNot, CurrentURL, ProposedURL 
			FROM 		CancerGovStaging..PrettyURL
			WHERE  	NCIViewID = @NCIviewID and ObjectID is null and isroot=1
			FOR READ ONLY 
			IF (@@ERROR <> 0)
			BEGIN
				ROLLBACK TRAN Tran_CreateOrUpdatePrettyURL
				RAISERROR ( 70004, 16, 1)
				RETURN 70004
			END 
		
			OPEN  PrettyURL_Cursor
			IF (@@ERROR <> 0)
			BEGIN
				DEALLOCATE PrettyURL_Cursor
				ROLLBACK TRAN Tran_CreateOrUpdatePrettyURL
				RAISERROR ( 70004, 16, 1)		
				RETURN 70004
			END 
		
			FETCH NEXT FROM PrettyURL_Cursor
			INTO 	@DirectoryID, 	@IsPrimary,   @UpdateRedirectOrNot, @PrettyURL, @ProposedURL 

			WHILE @@FETCH_STATUS = 0
			BEGIN
				PRINT 'ProposedURL=' + @ProposedURL + 'objectid=' + Convert(varchar(36), @ObjectID)
				IF  @ProposedURL is not null
				BEGIN

					select  @Exist = Count(*) from CancerGovStaging..PrettyURL where  ObjectID=@ObjectID and NCIViewID = @NCIviewID and ProposedURL like @ProposedURL+'/Page%'
					PRINT 'Exist = ' + convert(varchar(2), @Exist)	
					if  @Exist =0   -- newly created doc id 
					BEGIN
						insert into CancerGovStaging..PrettyURL
						(prettyurlID, nciviewID, ObjectID, RealURL, ProposedURL, UpdateRedirectOrNot, IsPrimary, DirectoryID,UpdateDate, UpdateUserID, CreateDate)
						values
						(newid(), @NCIviewID, @ObjectID, @PhysicalPath + @docid, @ProposedURL+'/page'+Convert(varchar(4), @number), @UpdateRedirectOrNot, @isPrimary,@DirectoryID, @UpdateDate, @UpdateUserID, @CreateDate)
						IF (@@ERROR <> 0)
						BEGIN
							CLOSE ViewObject_Cursor 
							DEALLOCATE ViewObject_Cursor 
							ROLLBACK TRAN   Tran_CreateOrUpdatePrettyURL
							RAISERROR ( 70006, 16, 1)
							RETURN  70006
						END
						PRINT 'insert'
					END 
					ELSE  -- Update existing proposedurl in case user updates priority
					BEGIN
						Update CancerGovStaging..PrettyURL
						set 	ProposedURL = @ProposedURL + '/page' + Convert(varchar(4),@number),
							UpdateRedirectOrNot = @UpdateRedirectOrNot,
							IsPrimary	= @IsPrimary,
							DirectoryID 	=@DirectoryID,
							UpdateDate 	= @UpdateDate,
							UpdateUserID  	= @UpdateUserID 
						WHERE nciviewID= @NCIviewID AND ObjectID=@ObjectID and  ProposedURL like @ProposedURL+'/page%'	 	
						IF (@@ERROR <> 0)
						BEGIN
							CLOSE ViewObject_Cursor 
							DEALLOCATE ViewObject_Cursor 
							ROLLBACK TRAN   Tran_CreateOrUpdatePrettyURL
							RAISERROR ( 70005, 16, 1)
							RETURN  70005
						END
					END
				END 
				ELSE 	-- @ProposedURL is null  Thus we will use currenturl to create new one for newly-created doc
				BEGIN
					PRINT 'ProposedURL is null '
					select  @Exist = Count(*) from CancerGovStaging..PrettyURL where  ObjectID=@ObjectID and NCIViewID = @NCIviewID and CurrentURL like @PrettyURL+'/Page%' 
					select  @ExistNext = Count(*) from CancerGovStaging..PrettyURL where  ObjectID=@ObjectID and NCIViewID = @NCIviewID and ProposedURL like @PrettyURL+'/Page%' 				

					if  @Exist =0  and @ExistNext=0  -- newly created doc id 
					BEGIN
						PRINT 'Exist =0'
						insert into CancerGovStaging..PrettyURL
						(prettyurlID, nciviewID, ObjectID, RealURL, ProposedURL, UpdateRedirectOrNot, IsPrimary, DirectoryID,UpdateDate, UpdateUserID, CreateDate)
						values
						(newid(), @NCIviewID, @ObjectID, @PhysicalPath + @docid, @PrettyURL+'/page'+Convert(varchar(4), @number), @UpdateRedirectOrNot, @IsPrimary,@DirectoryID, @UpdateDate, @UpdateUserID, @CreateDate)
						IF (@@ERROR <> 0)
						BEGIN
							CLOSE ViewObject_Cursor 
							DEALLOCATE ViewObject_Cursor 
							ROLLBACK TRAN   Tran_CreateOrUpdatePrettyURL
							RAISERROR ( 70006, 16, 1)
							RETURN  70006
						END
					END 
					ELSE  
					if @Exist <> 0 and @ExistNext =0 -- Update existing proposedurl in case user updates priority
					BEGIN
						PRINT 'Existing on '
						Update CancerGovStaging..PrettyURL
						set 	ProposedURL = @PrettyURL + '/page' + Convert(varchar(4),@number),
							UpdateRedirectOrNot = @UpdateRedirectOrNot,
							IsPrimary	= @IsPrimary,
							DirectoryID 	=@DirectoryID,
							UpdateDate 	= @UpdateDate,
							UpdateUserID  	= @UpdateUserID 
						WHERE nciviewID= @NCIviewID AND ObjectID=@ObjectID and CurrentURL like @PrettyURL+'/page%'	 	
						IF (@@ERROR <> 0)
						BEGIN
							CLOSE ViewObject_Cursor 
							DEALLOCATE ViewObject_Cursor 
							ROLLBACK TRAN   Tran_CreateOrUpdatePrettyURL
							RAISERROR ( 70005, 16, 1)
							RETURN  70005
						END
					END
					ELSE  
					if @Exist = 0 and @ExistNext  <> 0 -- Update existing proposedurl in case user updates priority
					BEGIN
						PRINT 'Existing on '
						Update CancerGovStaging..PrettyURL
						set 	ProposedURL = @PrettyURL + '/page' + Convert(varchar(4),@number),
							UpdateRedirectOrNot = @UpdateRedirectOrNot,
							IsPrimary	= @IsPrimary,
							DirectoryID 	=@DirectoryID,
							UpdateDate 	= @UpdateDate,
							UpdateUserID  	= @UpdateUserID 
						WHERE nciviewID= @NCIviewID AND ObjectID=@ObjectID and ProposedURL like @PrettyURL+'/page%'	 	
						IF (@@ERROR <> 0)
						BEGIN
							CLOSE ViewObject_Cursor 
							DEALLOCATE ViewObject_Cursor 
							ROLLBACK TRAN   Tran_CreateOrUpdatePrettyURL
							RAISERROR ( 70005, 16, 1)
							RETURN  70005
						END
					END
					ELSE
					if @Exist <> 0 and @ExistNext  <> 0 -- Update existing proposedurl in case user updates priority
					BEGIN
						PRINT 'Existing on '
						Update CancerGovStaging..PrettyURL
						set 	ProposedURL = @PrettyURL + '/page' + Convert(varchar(4),@number),
							UpdateRedirectOrNot = @UpdateRedirectOrNot,
							IsPrimary	= @IsPrimary,
							DirectoryID 	=@DirectoryID,
							UpdateDate 	= @UpdateDate,
							UpdateUserID  	= @UpdateUserID 
						WHERE nciviewID= @NCIviewID AND ObjectID=@ObjectID and ProposedURL like @PrettyURL+'/page%'	 and CurrentURL like @PrettyURL+'/Page%'
						IF (@@ERROR <> 0)
						BEGIN
							CLOSE ViewObject_Cursor 
							DEALLOCATE ViewObject_Cursor 
							ROLLBACK TRAN   Tran_CreateOrUpdatePrettyURL
							RAISERROR ( 70005, 16, 1)
							RETURN  70005
						END
					END
				END 
			
				FETCH NEXT FROM PrettyURL_Cursor
				INTO 	@DirectoryID, 	@IsPrimary,   @UpdateRedirectOrNot, @PrettyURL, @ProposedURL 
			END -- End while
	
			-- CLOSE ViewObject_Cursor		
			CLOSE PrettyURL_Cursor
			DEALLOCATE PrettyURL_Cursor

			-- GET NEXT OBJECT
			PRINT '--get next'
			FETCH NEXT FROM ViewObject_Cursor
			INTO 	@ObjectID,  @docid, @number	

		END -- End while
	
		-- CLOSE ViewObject_Cursor		
		CLOSE ViewObject_Cursor 
		DEALLOCATE ViewObject_Cursor 

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
	END

	PRINT 'end of doc'

	-- Begin updating audio transcript pretty url
	if (@type ='BENCHMARK')
	BEGIN
		DECLARE ViewObject_Cursor CURSOR LOCAL FORWARD_ONLY  FOR
			SELECT 	ObjectID,  '&docid=' + Convert(varchar(36), ObjectID), Priority
			FROM 	CancerGovStaging..ViewObjects 
			WHERE  	NCIViewID = @NCIviewID and Type ='AUDIO' order by priority
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
		INTO 	@ObjectID,  @docid, @number	

		WHILE @@FETCH_STATUS = 0
		BEGIN
			select @RowNumber= @RowNumber +1

			--create another cursor for distinguished prettyurl-- update  -- check viewobjects id first. If exists, update pretty url table. Otherwise, create new row for that viewobject'
			PRINT 'start within viewobject_cursor with objectid =' + convert(varchar(40), @ObjectID) + '         docid= ' + convert(varchar(40), @docid) 

			DECLARE PrettyURL_Cursor CURSOR LOCAL FORWARD_ONLY  FOR
			SELECT 	DirectoryID,  IsPrimary, UpdateRedirectOrNot, CurrentURL, ProposedURL 
			FROM 		CancerGovStaging..PrettyURL
			WHERE  	NCIViewID = @NCIviewID and ObjectID is null and isroot=1
			FOR READ ONLY 
			IF (@@ERROR <> 0)
			BEGIN
				ROLLBACK TRAN Tran_CreateOrUpdatePrettyURL
				RAISERROR ( 70004, 16, 1)
				RETURN 70004
			END 
		
			OPEN  PrettyURL_Cursor
			IF (@@ERROR <> 0)
			BEGIN
				DEALLOCATE PrettyURL_Cursor
				ROLLBACK TRAN Tran_CreateOrUpdatePrettyURL
				RAISERROR ( 70004, 16, 1)		
				RETURN 70004
			END 
		
			FETCH NEXT FROM PrettyURL_Cursor
			INTO 	@DirectoryID, 	@IsPrimary,   @UpdateRedirectOrNot, @PrettyURL, @ProposedURL 

			WHILE @@FETCH_STATUS = 0
			BEGIN
				PRINT 'ProposedURL=' + @ProposedURL + 'objectid=' + Convert(varchar(36), @ObjectID)
				IF  @ProposedURL is not null

				BEGIN
					select  @Exist = Count(*) from CancerGovStaging..PrettyURL where  ObjectID=@ObjectID 
					and NCIViewID = @NCIviewID and ProposedURL like @ProposedURL+'/Audio/Transcript%'
				
					PRINT 'Exist = ' + convert(varchar(2), @Exist)	
					if  @Exist =0   -- newly created doc id 
					BEGIN
						insert into CancerGovStaging..PrettyURL
						(prettyurlID, nciviewID, ObjectID, RealURL, ProposedURL, UpdateRedirectOrNot, IsPrimary, DirectoryID,UpdateDate, UpdateUserID, CreateDate)
						values
						(newid(), @NCIviewID, @ObjectID, @PhysicalPath + @docid +'&Page=Audio', @ProposedURL+'/Audio/Transcript'+Convert(varchar(4), @RowNumber), @UpdateRedirectOrNot, @isPrimary,@DirectoryID, @UpdateDate, @UpdateUserID, @CreateDate)
						IF (@@ERROR <> 0)
						BEGIN
							CLOSE ViewObject_Cursor 
							DEALLOCATE ViewObject_Cursor 
							ROLLBACK TRAN   Tran_CreateOrUpdatePrettyURL
							RAISERROR ( 70006, 16, 1)
							RETURN  70006
						END
						PRINT 'insert'
					END 
					ELSE  -- Update existing proposedurl in case user updates priority
					BEGIN
						Update CancerGovStaging..PrettyURL
						set 	ProposedURL = @ProposedURL + '/Audio/Transcript' + Convert(varchar(4),@RowNumber),
							UpdateRedirectOrNot = @UpdateRedirectOrNot,
							IsPrimary	= @IsPrimary,
							DirectoryID 	=@DirectoryID,
							UpdateDate 	= @UpdateDate,
							UpdateUserID  	= @UpdateUserID 
						WHERE nciviewID= @NCIviewID AND ObjectID=@ObjectID and  ProposedURL like @ProposedURL+'/Audio/Transcript%'	 	
						IF (@@ERROR <> 0)
						BEGIN
							CLOSE ViewObject_Cursor 
							DEALLOCATE ViewObject_Cursor 
							ROLLBACK TRAN   Tran_CreateOrUpdatePrettyURL
							RAISERROR ( 70005, 16, 1)
							RETURN  70005
						END
					END
				END 
				ELSE 	-- @ProposedURL is null  Thus we will use currenturl to create new one for newly-created doc
				BEGIN
					PRINT 'ProposedURL is null '
					select  @Exist = Count(*) from CancerGovStaging..PrettyURL where  ObjectID=@ObjectID and NCIViewID = @NCIviewID and CurrentURL like @PrettyURL+'/Audio/Transcript%' 
					select  @ExistNext = Count(*) from CancerGovStaging..PrettyURL where  ObjectID=@ObjectID and NCIViewID = @NCIviewID and ProposedURL like @PrettyURL+'/Audio/Transcript%' 				

					if  @Exist =0  and @ExistNext=0  -- newly created doc id 
					BEGIN
						PRINT 'Exist =0'
						insert into CancerGovStaging..PrettyURL
						(prettyurlID, nciviewID, ObjectID, RealURL, ProposedURL, UpdateRedirectOrNot, IsPrimary, DirectoryID,UpdateDate, UpdateUserID, CreateDate)
						values
						(newid(), @NCIviewID, @ObjectID, @PhysicalPath + @docid +'&Page=Audio', @PrettyURL+'/Audio/Transcript'+Convert(varchar(4), @RowNumber), @UpdateRedirectOrNot, @IsPrimary,@DirectoryID, @UpdateDate, @UpdateUserID, @CreateDate)
						IF (@@ERROR <> 0)
						BEGIN
							CLOSE ViewObject_Cursor 
							DEALLOCATE ViewObject_Cursor 
							ROLLBACK TRAN   Tran_CreateOrUpdatePrettyURL
							RAISERROR ( 70006, 16, 1)
							RETURN  70006
						END
					END 
					ELSE  
					if @Exist <> 0 and @ExistNext =0 -- Update existing proposedurl in case user updates priority
					BEGIN
						PRINT 'Existing on '
						Update CancerGovStaging..PrettyURL
						set 	ProposedURL = @PrettyURL + '/Audio/Transcript' + Convert(varchar(4),@RowNumber),
							UpdateRedirectOrNot = @UpdateRedirectOrNot,
							IsPrimary	= @IsPrimary,
							DirectoryID 	=@DirectoryID,
							UpdateDate 	= @UpdateDate,
							UpdateUserID  	= @UpdateUserID 
						WHERE nciviewID= @NCIviewID AND ObjectID=@ObjectID and CurrentURL like @PrettyURL+'/Audio/Transcript%'	 	
						IF (@@ERROR <> 0)
						BEGIN
							CLOSE ViewObject_Cursor 
							DEALLOCATE ViewObject_Cursor 
							ROLLBACK TRAN   Tran_CreateOrUpdatePrettyURL
							RAISERROR ( 70005, 16, 1)
							RETURN  70005
						END
					END
					ELSE  
					if @Exist = 0 and @ExistNext  <> 0 -- Update existing proposedurl in case user updates priority
					BEGIN
						PRINT 'Existing on '
						Update CancerGovStaging..PrettyURL
						set 	ProposedURL = @PrettyURL + '/Audio/Transcript' + Convert(varchar(4),@RowNumber),
							UpdateRedirectOrNot = @UpdateRedirectOrNot,
							IsPrimary	= @IsPrimary,
							DirectoryID 	=@DirectoryID,
							UpdateDate 	= @UpdateDate,
							UpdateUserID  	= @UpdateUserID 
						WHERE nciviewID= @NCIviewID AND ObjectID=@ObjectID and ProposedURL like @PrettyURL+'/Audio/Transcript%'	 	
						IF (@@ERROR <> 0)
						BEGIN
							CLOSE ViewObject_Cursor 
							DEALLOCATE ViewObject_Cursor 
							ROLLBACK TRAN   Tran_CreateOrUpdatePrettyURL
							RAISERROR ( 70005, 16, 1)
							RETURN  70005
						END
					END
					ELSE
					if @Exist <> 0 and @ExistNext  <> 0 -- Update existing proposedurl in case user updates priority
					BEGIN
						PRINT 'Existing on '
						Update CancerGovStaging..PrettyURL
						set 	ProposedURL = @PrettyURL + '/Audio/Transcript' + Convert(varchar(4),@RowNumber),
							UpdateRedirectOrNot = @UpdateRedirectOrNot,
							IsPrimary	= @IsPrimary,
							DirectoryID 	=@DirectoryID,
							UpdateDate 	= @UpdateDate,
							UpdateUserID  	= @UpdateUserID 
						WHERE nciviewID= @NCIviewID AND ObjectID=@ObjectID and ProposedURL like @PrettyURL+'/Audio/Transcript%'	 and CurrentURL like @PrettyURL+'/Audio/Transcript%'	
						IF (@@ERROR <> 0)
						BEGIN
							CLOSE ViewObject_Cursor 
							DEALLOCATE ViewObject_Cursor 
							ROLLBACK TRAN   Tran_CreateOrUpdatePrettyURL
							RAISERROR ( 70005, 16, 1)
							RETURN  70005
						END
					END
				END 
			
				FETCH NEXT FROM PrettyURL_Cursor
				INTO 	@DirectoryID, 	@IsPrimary,   @UpdateRedirectOrNot, @PrettyURL, @ProposedURL 
			END -- End while
	
			-- CLOSE ViewObject_Cursor		
			CLOSE PrettyURL_Cursor
			DEALLOCATE PrettyURL_Cursor

			-- GET NEXT OBJECT
			PRINT '--get next'
			FETCH NEXT FROM ViewObject_Cursor
			INTO 	@ObjectID,  @docid, @number	

		END -- End while
	
		-- CLOSE ViewObject_Cursor		
		CLOSE ViewObject_Cursor 
		DEALLOCATE ViewObject_Cursor 

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
	END


	COMMIT TRAN   Tran_CreateOrUpdatePrettyURL

	SET NOCOUNT OFF
	RETURN 0 

END

GO
GRANT EXECUTE ON [dbo].[usp_CreateOrUpdatePrettyURL] TO [webadminuser_role]
GO
