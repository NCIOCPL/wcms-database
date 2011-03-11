IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[PushDrugInfoSummaryToPreview]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[PushDrugInfoSummaryToPreview]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[PushDrugInfoSummaryToPreview]
@NCIViewID  UniqueIdentifier  output ,
@Section varchar(50) = 'DrugInfo',
@Group varchar(50)= 'Cancer Information',
@HeadListID uniqueidentifier = 'D9C12B16-3C19-44A6-AFA9-4D61D25B64DB',
@contentHeaderID uniqueidentifier = 'C04C67DA-1C31-4FCB-AFF8-6CABC0F4CBFF',
@Title varchar(255),
@ShortTitle varchar(64),
@description varchar(1500),
@data ntext,
@datasize int,
@Expirationdate datetime,
@posteddate datetime,
@Releasedate datetime,
@updateUserID varchar(50),
@DirectoryID uniqueidentifier = '218CC70F-3633-4C10-B66D-C05808B91E31',
@proposedURL varchar(500),
@updateDate datetime,
@DocumentID uniqueidentifier

as
begin
	SET NOCOUNT ON

	declare 
	@NCITemplateID	UniqueIdentifier,
	@TOC varchar(40) ,
	@DisplayDatemode varchar(20),
	@r int

    -- If the UpdateDate is null we only want to display the 
    -- PostedDate (a.k.a. DateFirstPublished)
    -- -----------------------------------------------------
	if @ReleaseDate is null	
		begin
			set @DisplayDateMode = '1'
			set @releaseDate = '1980-1-1'
		end
	else
		set @DisplayDateMode = '3'

    -- Setting the UpdateDate to the current date/time as the timestamp
    -- for the updated records
    -- ----------------------------------------------------------------
	set @UpdateDate = getDate()
	
	set @NCITemplateID = 'D9C8A380-6A06-4AFA-86E9-EA52E50E0493'
	set @TOC = null
		
	Declare 		
	@IsLinkExternal  	Bit,
 	@DataType 		char(10),
	@Type			Char(10),
	@Status        	Char(10),
	@URL			varchar(1000),
	@URLArguments	varchar(1000),
	@SectionURL		varchar(1000),
	@TemplateURL		varchar(1000),	
	@GroupID       		Int,
	@NCISectionID		UniqueIdentifier,
	@TemplateName		varchar(50),
	@Priority		Int,
	@PhysicalPath varchar(255)
	
	declare @DupDocID varchar(50), @DupNCIviewID uniqueidentifier
	
	SELECT @SectionURL= URL, @NCISectionID = NCIsectionID  FROM NCISection WHERE [Name] =@Section
	SELECT @NCIViewID= NCIViewID from dbo.viewObjects where objectid = @DocumentId and type = 'DOCUMENT'


	 SELECT @DupNCIviewid = nciviewid FROM dbo.prettyurl 
		where isnull(ProposedUrl,CurrentUrl)=@proposedURL and (@nciviewid is null or (nciviewid <> @nciviewid ))
	
	if @DupNCIViewid is not null
		begin
			select @DupDocID =convert(varchar(50), objectid) from dbo.viewobjects where nciviewid = @DupNCIViewid and type = 'Document'	
			RAISERROR ( 'Duplicate PrettyURL, the existing Document "%s" has the same prettyURL', 16, 1, @DupDocid)
			RETURN 70004
		END 

    -- This is a new record.  Populate all tables
    -- ------------------------------------------
	if @NCIViewID is null
		Begin
				set @nciviewid = newid()
				SELECT @GroupID = GroupID FROM dbo.Groups WHERE GroupName = @Group
				SELECT @TemplateURL = URL, @TemplateName =[Name]	 FROM dbo.NCITemplate WHERE NCITemplateID = @NCITemplateID	

				if ( len(@Section) =0)
				BEGIN
					select @URL = '/' + 	@TemplateURL
				END
				ELSE
				BEGIN
					select @URL = @SectionURL  + @TemplateURL
				END			

				select 	@Type ='DOCUMENT', 
					@Status ='EDIT', 	
					@IsLinkExternal  =0,  	
					@DataType 	='HTML',
					@URLArguments ='viewid=' + Convert(Varchar(36), @NCIViewID),
					@Priority =1

				begin tran
					INSERT INTO dbo.NCIView 
					( Title,  ShortTitle,  Description,  URL, URLArguments, NCIViewID, 
                      IsLinkExternal, Status, NCITemplateID, ExpirationDate, ReleaseDate, 
                      UpdateUSerID, GroupID, NCISectionID, PostedDate, DisplayDateMode, UpDateDate)
					VALUES 
					(@Title, @ShortTitle, @Description, @URL, @URLArguments, @NCIViewID, 
                     @IsLinkExternal, @Status, @NCITemplateID, @ExpirationDate, @ReleaseDate, 
                     @UpdateUserId, @GroupID, @NCISectionID, @PostedDate, @DisplayDateMode, @UpdateDate)
					IF (@@ERROR <> 0)
					BEGIN
						ROLLBACK TRAN 
						RAISERROR ( 70004, 16, 1)
						RETURN 70004
					END 

					if not exists (select * from dbo.document where documentid = @documentID)
						INSERT INTO dbo.[Document] 
						( DocumentID, Title, ShortTitle, Description, DataType, DataSize, TOC, Data, ExpirationDate, ReleaseDate, UpdateUSerID)
						VALUES 
						(@DocumentID, @Title, @ShortTitle, @Description, @DataType, @DataSize, @TOC, @Data, @ExpirationDate, @ReleaseDate, @UpdateUserId)
					ELSE
						UPDATE dbo.[Document] 
						set 	Title =@Title, 
							ShortTitle =@ShortTitle, 
							Description = @Description, 
							TOC = @TOC, 
							Data= @Data, 
							ExpirationDate =@ExpirationDate, 
							ReleaseDate= @ReleaseDate, 
							PostedDate = @PostedDate,
							DisplayDateMode = @DisplayDateMode,
							UpdateUserID= @UpdateUserID 
						where DocumentID = @DocumentID

					IF (@@ERROR <> 0)
						BEGIN
							Rollback tran 
							RAISERROR ( 70004, 16, 1)
							RETURN 70004
						END
					

					INSERT INTO dbo.ViewObjects 
					(NCIViewID, ObjectID, Type, Priority, UpdateUserID) 
					VALUES 
					(@NCIViewID, @DocumentID, @Type, @Priority, @UpdateUserID)
					IF (@@ERROR <> 0)
					BEGIN
						Rollback tran 
						RAISERROR ( 70004, 16, 1)
						RETURN 70004
					END

					INSERT INTO dbo.ViewObjects 
					(NCIViewID, ObjectID, Type, Priority, UpdateDate, UpdateUserID) 
					VALUES 
					(@NCIViewID, @HeadListID, 'HDRLIST', 2, @UpdateDate, @updateUserID) 
					IF (@@ERROR <> 0)
					BEGIN
						Rollback tran 
						RAISERROR ( 70004, 16, 1)
						RETURN 70004
					END
					
			
					INSERT INTO dbo.ViewObjects 
					(NCIViewID, ObjectID, Type, Priority, UpdateDate, UpdateUserID) 
					VALUES 
					(@NCIViewID, @ContentHeaderID, 'header', 3001, @UpdateDate, @updateUserID) 
					IF (@@ERROR <> 0)
					BEGIN
						Rollback tran 
						RAISERROR ( 70004, 16, 1)
						RETURN 70004
					END

					--COntentHeader Text 	 			
					INSERT INTO dbo.ViewObjects 
					(NCIViewID, ObjectID, Type, Priority, UpdateDate, UpdateUserID) 
					VALUES 
					(@NCIViewID, '76923929-0B70-4C77-94FC-D59A62038C50', 'header', 3002, @UpdateDate, @updateUserID) 
					IF (@@ERROR <> 0)
					BEGIN
						Rollback tran 
						RAISERROR ( 70004, 16, 1)
						RETURN 70004
					END


					select 	@PhysicalPath = '/Templates/' + T.URL + IsNull(NullIf( '?'+IsNull(N.URLArguments,''),'?'),'') 
						from dbo.NCITemplate T, dbo.NCIView N 
						where T.NCITemplateID=N.NCITemplateID and N.NCIViewID =@NCIviewID
					
					insert into dbo.PrettyURL
					(prettyurlID, nciviewID, RealURL, ProposedURL, UpdateRedirectOrNot, IsPrimary, IsRoot,DirectoryID,UpdateDate, UpdateUserID, CreateDate)
					values
					(newid(), @NCIviewID, @PhysicalPath, @ProposedURL, 1,1, 1, @DirectoryID, @UpdateDate, @UpdateUserID, getdate())
					IF (@@ERROR <> 0) 
					BEGIN
						Rollback tran 
						RAISERROR ( 70004, 16, 1)
						RETURN 70004
					END
					
					exec @r = dbo.usp_insertViewProperty
					@NCIViewID = @nciviewid, 
					@PropertyName = 'IsPrintAvailable', 
					@PropertyValue = 'YES', @UpdateUserID = @updateUserID
					IF (@@ERROR <> 0) or (@r <> 0)
					BEGIN
						if @@trancount >0 
							Rollback tran 
						RAISERROR ( 70004, 16, 1)
						RETURN 70004
					END
					
					exec @r = dbo.usp_insertViewProperty
					@NCIViewID = @nciviewid, 
					@PropertyName ='ShowExtractedGlossary', 
					@PropertyValue = 'YES', @UpdateUserID = @updateUserID
					IF (@@ERROR <> 0)or (@r <> 0)
					BEGIN
						if @@trancount >0 
							Rollback tran 
						RAISERROR ( 70004, 16, 1)
						RETURN 70004
					END
					
					exec @r = dbo.usp_insertViewProperty 
					@NCIViewID = @nciviewid, 
					@PropertyName = 'ShowExtractedLinks', 
					@PropertyValue = 'YES', @UpdateUserID = @updateUserID
					IF (@@ERROR <> 0)or (@r <> 0)
					BEGIN
						if @@trancount >0 
							Rollback tran 
						RAISERROR ( 70004, 16, 1)
						RETURN 70004
					END
					
				commit tran		
			end
        -- The record already exists.  Update the tables
        -- ---------------------------------------------
		else
			if not exists (select 1 from dbo.NCIView 
                            where nciviewid    = @nciviewid 
                              and NCISectionid = @NCISectionID)
				begin
					RAISERROR ( 70004, 16, 1)
					return 70004
				end
			
			begin tran
				
				 UPDATE dbo.NCIView 
					SET	Title           = @Title,  
						ShortTitle      = @ShortTitle,  
						Description     = @Description,  
						PostedDate      = @posteddate,
					    ReleaseDate     = @ReleaseDate, -- added to fix update of ReleaseDate. VE, 2007-01-10
						DisplayDateMode = @DisplayDateMode, 
						Status          = 'EDIT',
						UpdateUserID    = @UpdateUserId,
						UpdateDate      = @UpdateDate
				  WHERE NCIViewID = @NCIViewID
				
					IF (@@ERROR <> 0)
					BEGIN
						Rollback tran 
						RAISERROR ( 70004, 16, 1)
						RETURN 70004
					END
	
					UPDATE dbo.[Document] 
					   SET Title           = @Title, 
						   ShortTitle      = @ShortTitle, 
						   Description     = @Description, 
						   TOC             = @TOC, 
						   Data            = @Data, 
						   ExpirationDate  = @ExpirationDate, 
						   ReleaseDate     = @ReleaseDate, 
						   PostedDate      = @PostedDate,
						   DisplayDateMode = @DisplayDateMode,
						   UpdateUserID    = @UpdateUserID 
					 WHERE DocumentID = @DocumentID

						IF (@@ERROR <> 0)
						BEGIN
							ROLLBACK TRAN 
							RAISERROR ( 70004, 16, 1)
							RETURN 70004
						END 	

						UPDATE dbo.PrettyUrl 
						   SET ProposedURL  = @proposedURL,
						 	   UpdateDate   = @UpdateDate, 
 							   UpdateUserID = @UpdateUserID
						 WHERE NCIViewID = @NCIViewID 
						   AND IsPrimary = 1
						IF (@@ERROR <> 0)
							BEGIN
								Rollback tran
								RAISERROR ( 70004, 16, 1)
								RETURN 70004
							END 

		commit tran
	RETURN 0 
end


GO
GRANT EXECUTE ON [dbo].[PushDrugInfoSummaryToPreview] TO [gatekeeper_role]
GO
