IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_Temp_CreateFactSheet]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_Temp_CreateFactSheet]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/****** Object:  Stored Procedure dbo.usp_Temp_CreateFactSheet    Script Date: 8/12/2005 4:12:17 PM ******/
CREATE PROCEDURE dbo.usp_Temp_CreateFactSheet
(
	@FactSheetID		varchar(10),
	@IsSpanish		char(1),
	@Title              		varchar(255),
	@Description    		varchar(1500),
	@PrettyURL		varchar(180),
	@SecondPrettyURL	varchar(180),
	@Data			text,
	@DisplayDateMode	varchar(10),
	@DateUpdated		datetime,
	@DatePosted		datetime,
	@DateReviewed	datetime
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @NCIViewID	uniqueidentifier,
		@ObjectID	uniqueidentifier,
		@TitleBlockID	uniqueidentifier,
		@Now		datetime,
		@UpdateUserID	varchar(20),
		@ShortTitle	varchar(50)


	BEGIN TRAN Tran_InsertFactSheet

	-- get GUIDs
	SELECT @NCIViewID = newid(), @ObjectID = newid(), @TitleBlockID = newid(), @Now = getdate(), @UpdateUserID = 'ChenFactSheetLoader'
	SELECT @ShortTitle = SUBSTRING(@Title, 0, 50)

	IF (@DateUpdated IS NULL)
		SELECT @DateUpdated = @Now
	IF (@DatePosted IS NULL)
		SELECT @DatePosted = @Now
	IF (@DateReviewed IS NULL)
		SELECT @DateReviewed = @Now

	/*
	// insert NCIView
	//		NCIViewID = <nciViewID>
	//		NCITemplateID = D9C8A380-6A06-4AFA-86E9-EA52E50E0493
	//		NCISectionID = 934C1DB4-9CBF-4642-BDB3-0F90AD9326D2
	//		GroupID = 3
	//		Title = <title>
	//		ShortTitle = <title>
	//		Description = <description>
	//		URL = /templates/doc.aspx
	//		URLArguments = "viewid=<nciViewid>";
	//		CreateDate = now
	//		ReleaseDate = <dateUpdated>
	//		ExpirationDate = sometime in 2020
	//		Version = 0.18
	//		Status = EDIT
	//		IsOnProduction = 0
	//		IsMultiSourced = 0
	//		IsLinkExternal = 0
	//		SpiderDepth = 3
	//		UpdateDate = now
	//		UpdateUserID = ChenFactSheetLoader
	//		PostedDate = <datePosted>
	//		DisplayDateMode = <displayDateMode>
	//		ReviewedDate = <dateReviewed>
	*/
	INSERT INTO NCIView
		(NCIViewID, 
		NCITemplateID, 
		NCISectionID, 
		GroupID, 
		Title, 
		ShortTitle, 
		[Description], 
		URL, 
		URLArguments, 
		MetaTitle, 
		MetaDescription, 
		MetaKeyword, 
		CreateDate, 
		ReleaseDate, 
		ExpirationDate, 
		Version, 
		Status, 
		IsOnProduction, 
		IsMultiSourced, 
		IsLinkExternal, 
		SpiderDepth, 
		UpdateDate, 
		UpdateUserID, 
		PostedDate, 
		DisplayDateMode, 
		ReviewedDate, 
		ChangeComments)
	VALUES (
		@NCIViewID,
		'D9C8A380-6A06-4AFA-86E9-EA52E50E0493',
		'934C1DB4-9CBF-4642-BDB3-0F90AD9326D2',
		3,
		@Title,
		@ShortTitle,
		@Description,
		'/templates/doc.aspx',
		'viewid=' + cast(@NCIViewID as varchar(50)),
		'',
		'',
		'',
		@Now,
		@DateUpdated,
		'2020-01-01 00:00:00',
		'1',
		'EDIT',
		0,
		0,
		0,
		3,
		@Now,
		@UpdateUserID,
		@DatePosted,
		@DisplayDateMode,
		@DateReviewed,
		'')
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_InsertFactSheet
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 

	/*
	// insert ViewProperties
	//		IsPrintAvailable: YES
	//		SearchFilter: News,Factsheet
	//		ShowExtractedGlossary: YES
	//		ShowExtractedLinks: YES
	//		IsSpanishContent: YES/NO
	//		IsPDFAvailable: /PDF/FactSheet/fs1_2s.pdf
	*/
	INSERT INTO ViewProperty
		(NCIViewID, PropertyName, PropertyValue, UpdateDate, UpdateUserID)
	VALUES
		(@NCIViewID, 'IsPrintAvailable', 'YES', @Now, @UpdateUserID)
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_InsertFactSheet
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 
	INSERT INTO ViewProperty
		(NCIViewID, PropertyName, PropertyValue, UpdateDate, UpdateUserID)
	VALUES
		(@NCIViewID, 'SearchFilter', 'Factsheet', @Now, @UpdateUserID)
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_InsertFactSheet
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 
	INSERT INTO ViewProperty
		(NCIViewID, PropertyName, PropertyValue, UpdateDate, UpdateUserID)
	VALUES
		(@NCIViewID, 'ShowExtractedGlossary', 'YES', @Now, @UpdateUserID)
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_InsertFactSheet
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 
	INSERT INTO ViewProperty
		(NCIViewID, PropertyName, PropertyValue, UpdateDate, UpdateUserID)
	VALUES
		(@NCIViewID, 'ShowExtractedLinks', 'YES', @Now, @UpdateUserID)
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_InsertFactSheet
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 
	IF (@IsSpanish = 'Y')
	BEGIN
		INSERT INTO ViewProperty
			(NCIViewID, PropertyName, PropertyValue, UpdateDate, UpdateUserID)
		VALUES
			(@NCIViewID, 'IsSpanishContent', 'YES', @Now, @UpdateUserID)
	END
	ELSE
	BEGIN
		INSERT INTO ViewProperty
			(NCIViewID, PropertyName, PropertyValue, UpdateDate, UpdateUserID)
		VALUES
			(@NCIViewID, 'IsSpanishContent', 'NO', @Now, @UpdateUserID)
	END
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_InsertFactSheet
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 
	INSERT INTO ViewProperty
		(NCIViewID, PropertyName, PropertyValue, UpdateDate, UpdateUserID)
	VALUES
		(@NCIViewID, 'IsPDFAvailable', '/PDF/FactSheet/fs' + REPLACE(@FactSheetID, '.', '_') + '.pdf', @Now, @UpdateUserID)
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_InsertFactSheet
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 
	INSERT INTO ViewProperty
		(NCIViewID, PropertyName, PropertyValue, UpdateDate, UpdateUserID)
	VALUES
		(@NCIViewID, 'LoadedBy', @UpdateUserID, @Now, @UpdateUserID)
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_InsertFactSheet
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 
	
		
	/*
	// insert prettyURL
	//		/cancertopics/factsheet/FOO
	//		/cancertopics/factsheet/factsheetID (IsPrimary = 0)
	//		DirectoryName = /cancertopics/factsheet (5CEF9944-2AEC-4E4E-8290-7D6557C67928 - new)
	*/
	INSERT INTO PrettyURL
		(NCIViewID, DirectoryID, ObjectID, RealURL, CurrentURL, ProposedURL, UpdateRedirectOrNot, IsPrimary, CreateDate, UpdateUserID, UpdateDate, IsRoot)
	VALUES
		(@NCIViewID, '5CEF9944-2AEC-4E4E-8290-7D6557C67928', NULL, '/templates/doc.aspx?viewid=' + cast(@NCIViewID as varchar(50)), null, '/cancertopics/factsheet/' + @PrettyURL, 0, 1, @Now, @UpdateUserID, @Now, 1)
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_InsertFactSheet
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 
	IF (@SecondPrettyURL <> NULL)
	BEGIN
		INSERT INTO PrettyURL
			(NCIViewID, DirectoryID, ObjectID, RealURL, CurrentURL, ProposedURL, UpdateRedirectOrNot, IsPrimary, CreateDate, UpdateUserID, UpdateDate, IsRoot)
		VALUES
			(@NCIViewID, '5CEF9944-2AEC-4E4E-8290-7D6557C67928', NULL, '/templates/doc.aspx?viewid=' + cast(@NCIViewID as varchar(50)), null, '/cancertopics/factsheet/' + @SecondPrettyURL, 0, 0, @Now, @UpdateUserID, @Now, 1)
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN Tran_InsertFactSheet
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 
	END
	
	-- insert Document
	INSERT INTO Document
		(DocumentID, Title, ShortTitle, [Description], GroupID, DataType, DataSize, IsWirelessPage, TOC, Data, RunTimeOwnerID, CreateDate, ReleaseDate, ExpirationDate, UpdateDate, UpdateUserID, PostedDate, DisplayDateMode)
	VALUES
		(@ObjectID, @Title, @ShortTitle, @Description, NULL, NULL, NULL, 'N', '', @Data, NULL, @Now, @Now, '2020-01-01 00:00:00', @Now, @UpdateUserID, @Now, 'none')
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_InsertFactSheet
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 

	/*
	// insert ViewObjects
	//		DOCUMENT [3] (content)
	//		TITLEBLOCK [2]
	//		Header [3004] (A36034CC-7986-4289-9107-B2B35D203D07) -- Content Header
	//		Header [3004] (DDAA0302-A98C-42D6-9B49-DC1D482F8EA4) -- Content Header
	*/
	INSERT INTO ViewObjects
		(NCIViewID, ObjectID, Type, Priority, UpdateDate, UpdateUserID)
	VALUES
		(@NCIViewID, @ObjectID, 'DOCUMENT', 3, @Now, @UpdateUserID)
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_InsertFactSheet
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 
	INSERT INTO ViewObjects
		(NCIViewObjectID, NCIViewID, ObjectID, Type, Priority, UpdateDate, UpdateUserID)
	VALUES
		(@TitleBlockID, @NCIViewID, newid(), 'TITLEBLOCK', 2, @Now, @UpdateUserID)
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_InsertFactSheet
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 
	INSERT INTO ViewObjects
		(NCIViewID, ObjectID, Type, Priority, UpdateDate, UpdateUserID)
	VALUES
		(@NCIViewID, 'A36034CC-7986-4289-9107-B2B35D203D07', 'Header', 3004, @Now, @UpdateUserID)
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_InsertFactSheet
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 
	INSERT INTO ViewObjects
		(NCIViewID, ObjectID, Type, Priority, UpdateDate, UpdateUserID)
	VALUES
		(@NCIViewID, 'DDAA0302-A98C-42D6-9B49-DC1D482F8EA4', 'Header', 3004, @Now, @UpdateUserID)
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_InsertFactSheet
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 
	

	/*
	// insert ViewObjectProperties
	//		TITLEBLOCK - (Style, NEWSRELEASE)
	*/
	INSERT INTO ViewObjectProperty
		(NCIViewObjectID, PropertyName, PropertyValue, UpdateDate, UpdateUserID)
	VALUES
		(@TitleBlockID, 'Style', 'NEWSRELEASE', @Now, @UpdateUserID)
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_InsertFactSheet
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 

	COMMIT TRAN  Tran_InsertFactSheet
	SET NOCOUNT OFF
	RETURN 0 
END
GO
GRANT EXECUTE ON [dbo].[usp_Temp_CreateFactSheet] TO [gatekeeper_role]
GO
GRANT EXECUTE ON [dbo].[usp_Temp_CreateFactSheet] TO [webadminuser_role]
GO
