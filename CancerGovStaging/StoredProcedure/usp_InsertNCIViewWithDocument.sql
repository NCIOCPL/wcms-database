IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_InsertNCIViewWithDocument]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_InsertNCIViewWithDocument]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



--***********************************************************************
-- Create New Object 
--************************************************************************

/****** Object:  Stored Procedure dbo.usp_RetrieveViewObject
   Owner:Jhe Purpose: For admin side Script Date: 1/15/2002 16:00:49 pm ******/

/****** 	Object:  Stored Procedure dbo.usp_InsertViewObject    
	Purpose: This script can be used for  inserting viewobjects.	Script Date: 1/30/2002 11:43:49 pM ******/

CREATE PROCEDURE dbo.usp_InsertNCIViewWithDocument
(
	@NCIViewID       	UniqueIdentifier,
	@Title              		VarChar(255),
	@ShortTitle      		VarChar(64),
	@Description    		VarChar(1500),
	@DataSize		int,
	@TOC			text,
	@Data			text,
	@ExpirationDate	datetime,
	@ReleaseDate		datetime,
	@PostedDate		datetime,
	@NCITemplateID	UniqueIdentifier,
	@Group		varchar(50),
	@Section		varchar(50),
	@DisplayDateMode	varchar(20),
	@UpdateUserID		VarChar(40)
)
AS
BEGIN
	SET NOCOUNT ON;

	Declare 		@ObjectID		UniqueIdentifier,
				@IsLinkExternal  	Bit,
			 	@DataType 		char(10),
				@Type			Char(10),
				@Status         	 	Char(10),
				@URL			varchar(1000),
				@URLArguments	varchar(1000),
				@SectionURL		varchar(1000),
				@TemplateURL		varchar(1000),	
				@GroupID       		Int,
				@NCISectionID		UniqueIdentifier,
				@TemplateName	varchar(50),
				@Priority		Int

	SELECT @TemplateURL = URL, @TemplateName =[Name]	 FROM NCITemplate WHERE NCITemplateID = @NCITemplateID	
	SELECT @SectionURL= URL, @NCISectionID = NCIsectionID  FROM NCISection WHERE [Name] =@Section
	SELECT @GroupID = GroupID FROM Groups WHERE GroupName = @Group

	if ( len(@Section) =0)
	BEGIN
		select @URL = '/' + 	@TemplateURL
	END
	ELSE
	BEGIN
		select @URL = '/templates/'  + @TemplateURL
	END			

	select 	@ObjectID = newid(), 
		@Type ='DOCUMENT', 
		@Status ='EDIT', 	
		@IsLinkExternal  =0,  	
		@DataType 	='HTML',
		@URLArguments ='viewid=' + Convert(Varchar(36), @NCIViewID),
		@Priority =1




	/*
	** Add a viewobject 
	*/	
	BEGIN  TRAN   Tran_Create

	INSERT INTO NCIView 
	( Title,  ShortTitle,  Description,  URL, URLArguments, NCIViewID, IsLinkExternal, Status, NCITemplateID, ExpirationDate, ReleaseDate, UpdateUSerID, GroupID, NCISectionID, PostedDate, DisplayDateMode)
	VALUES 
	(@Title, @ShortTitle, @Description, @URL, @URLArguments, @NCIViewID, @IsLinkExternal, @Status, @NCITemplateID, @ExpirationDate, @ReleaseDate, @UpdateUserId, @GroupID, @NCISectionID, @PostedDate, @DisplayDateMode)
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_Create
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 

	IF (@TemplateName != 'SUMMARY')
	BEGIN
		INSERT INTO Document 
		( DocumentID, Title, ShortTitle, Description, DataType, DataSize, TOC, Data, ExpirationDate, ReleaseDate, UpdateUSerID)
		VALUES 
		(@ObjectID, @Title, @ShortTitle, @Description, @DataType, @DataSize, @TOC, @Data, @ExpirationDate, @ReleaseDate, @UpdateUserId)
		IF (@@ERROR <> 0)
		BEGIN
			Rollback tran Tran_Create
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END

		INSERT INTO ViewObjects 
		(NCIViewID, ObjectID, Type, Priority, UpdateUserID) 
		VALUES 
		(@NCIViewID, @ObjectID, @Type, @Priority, @UpdateUserID)
		IF (@@ERROR <> 0)
		BEGIN
			Rollback tran Tran_Create
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END
	END
/*
	IF (@TemplateName != 'CONTENT_NAV' OR @TemplateName != 'CONTENT_DC' OR @TemplateName != 'DOC_OESI')
	BEGIN
		INSERT INTO Document 
		( DocumentID, Title, ShortTitle, Description, DataType, DataSize, TOC, Data, ExpirationDate, ReleaseDate, UpdateUSerID)
		VALUES 
		(@ObjectID, @Title, @ShortTitle, @Description, @DataType, @DataSize, @TOC, @Data, @ExpirationDate, @ReleaseDate, @UpdateUserId)
		IF (@@ERROR <> 0)
		BEGIN
			Rollback tran Tran_Create
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END
	END

	if (@TemplateName= 'DOC_IMG')
	BEGIN
		INSERT INTO ViewObjects 
		(NCIViewID, ObjectID, Type, Priority, UpdateUserID) 
		 VALUES 
		(@NCIViewID, @ObjectID, 'HDRDOC', 0 , @UpdateUserID)
	END
	else if (@TemplateName= 'CONTENT_NAV' OR @TemplateName= 'CONTENT_DC')
	BEGIN 
		-- a content_nav, no document is added, only title block is added.
		INSERT INTO ViewObjects (NCIViewID, ObjectID, Type, Priority, UpdateUserID) 
		VALUES 
		(@NCIViewID, @ObjectID, 'TITLEBLOCK', @Priority,@UpdateUserID)
	END
	ELSE if ( @TemplateName !='DOC_OESI')
	BEGIN	
		INSERT INTO ViewObjects 
		(NCIViewID, ObjectID, Type, Priority, UpdateUserID) 
		VALUES 
		(@NCIViewID, @ObjectID, @Type, @Priority, @UpdateUserID)
		IF (@@ERROR <> 0)
		BEGIN
			Rollback tran Tran_Create
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END
	END 
*/
	COMMIT tran Tran_Create

	SET NOCOUNT OFF
	RETURN 0 

END


GO
GRANT EXECUTE ON [dbo].[usp_InsertNCIViewWithDocument] TO [webadminuser_role]
GO
