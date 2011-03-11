IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_InsertNLIssue]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_InsertNLIssue]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
/****** 	Object:  Stored Procedure dbo.usp_InsertLinkView
	Purpose: This script is used for creating a new link view and create a listitem. This will be a transactional script.
	Script Date: 9/10/2003 11:43:49 pM ******/

CREATE PROCEDURE dbo.usp_InsertNLIssue
(
	@NewsletterID 		UniqueIdentifier,
	@NCIViewID 		UniqueIdentifier,
	@Title           		VarChar(255),
	@ShortTitle     		VarChar(64),
	@Description		VarChar(2000),
	@SendDate		Datetime,
	@UpdateUserID		VarChar(40),
	@IssueType			Int
)
AS
BEGIN
	SET NOCOUNT ON;

	Declare @NCISectionID UniqueIdentifier,
		@NCITemplateID UniqueIdentifier,
		@URL		varchar(1000),
		@SectionURL   varchar(200),
		@GroupID	int,
		@Priority	int,
		@TempObjID		UniqueIdentifier

	if (exists (select priority from NLIssue where newsletterID = @NewsletterID))
	BEGIN
		select @Priority = max(priority) + 1 from NLIssue where newsletterID = @NewsletterID
	END
	ELSE
	BEGIN	
		 select @Priority =1
	END
	
	Select  @NCISectionID = section, @GroupID = ownerGroupID from Newsletter where newsletterID = @NewsletterID
	IF (@@ERROR <> 0)
	BEGIN
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 

	Select @NCITemplateID = NCITemplateID,  @URL= URL from NCITemplate where [Name] ='Newsletter' 
	IF (@@ERROR <> 0)
	BEGIN
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 

	SELECT @SectionURL= URL FROM NCISection WHERE NCISectionID = @NCISectionID
	IF (@@ERROR <> 0)
	BEGIN
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 

	if (len(@SectionURL) =0)
	BEGIN
		select @URL ='/' + @URL
	END
	ELSE
	BEGIN
		select @URL ='/templates/' + @URL
	END


	BEGIN TRAN Tran_InsertLinkView
	/*
	** STEP - A
	** Insert a new row into NCIView table
	** if not return a 70004 error
	*/		

	INSERT INTO NCIView 
	(Title,  ShortTitle, [Description],  NCIViewID, URL, URLArguments, IsLinkExternal, Status, ExpirationDate, ReleaseDate, PostedDate,  UpdateUserID, GroupID, NCISectionID, NCITemplateID)
	 VALUES 
	(@Title, @ShortTitle,  @Description,  @NCIViewID, @URL,'viewid=' + Convert(varchar(36), @NCIViewID),  0, 'Edit', '1/1/2100', '1/1/1980', '1/1/1980', @UpdateUserID, @GroupID, @NCISectionID, @NCITemplateID)
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_InsertLinkView
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 

	/*
	** STEP - B
	** Add an entry of the nciview with NLIssue table
	*/	

	INSERT INTO NLIssue
	(NewsletterID, NCIViewID, Priority, SendDate, UpdateUserID, UpdateDate, IssueType)                                             
	values
	(@NewsletterID, @NCIViewID, @Priority, @SendDate, @UpdateUserID, getdate(), @IssueType)
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_InsertLinkView
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 

	IF (@ISSUETYPE = 2)
	BEGIN
		select @TempObjID = newid()

		EXECUTE usp_InsertViewObjectNLSection @NCIViewID ,  @TempObjID,
			 '',
			'',
			'',
			'',
			 '',
			 'NLSection',
			1,
			@UpdateUserID			

	END
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_InsertLinkView
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END

	COMMIT TRAN  Tran_InsertLinkView
	SET NOCOUNT OFF
	RETURN 0 


END

GO
GRANT EXECUTE ON [dbo].[usp_InsertNLIssue] TO [webadminuser_role]
GO
