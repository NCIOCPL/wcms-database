IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_UpdateNCIViewandViewObjectForSummary]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_UpdateNCIViewandViewObjectForSummary]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****** Object:  Stored Procedure dbo.usp_UpdateNCIViewandViewObjectForSummary    Script Date: 10/20/2005 4:54:55 PM ******/

/****** Object:  Stored Procedure dbo.usp_UpdateNCIViewandViewObjectForSummary    Script Date: 7/29/2005 2:49:15 PM ******/

/**********************************************************************************

	Object's name:	usp_UpdateNCIViewandViewObjectForSummary
	Object's type:	store proc
	Purpose:	Create a new NCIView, ViewObject ect. for the new summary
	Author:		11/01/2004	Lijia
	Change History:
	*	7/8/2005	Olga Rosenbaum	sets prettyURLs and description parameters
	*	10/20/2005	Chen Ling		updated new NCIViews to set IsMultiSourced=2
	*  11/20/2006   Min Gao			Short Title length from 50 to 100
	*  11/20/2006   Min Gao			Spanish Summary goes to Spanish Section

**********************************************************************************/	
CREATE PROCEDURE dbo.usp_UpdateNCIViewandViewObjectForSummary
(
	@DocumentGUID		UniqueIdentifier,
	@replacementforDocumentGUID	UniqueIdentifier=NULL,
	@RelatedDocumentGUID	UniqueIdentifier=NULL,
	@OtherLanguageDocumentGUID	UniqueIdentifier=NULL,
	@Title              	VarChar(255),
	@ShortTitle      	VarChar(64),
	@Description    	VarChar(1500),
	@Audience		VarChar(50),
	@Language		VarChar(50),
	@ExpirationDate		datetime,
	@ReleaseDate		datetime,
	@PostedDate		datetime,
	@DisplayDateMode	varchar(20),
	@UpdateUserID		VarChar(40),
	@BasePrettyUrl     VarChar(250)
)
AS
BEGIN

DECLARE	@NCIViewID	UniqueIdentifier,
	@RelatedViewID	UniqueIdentifier,
	@OtherLanguageViewID	UniqueIdentifier,
	@replacementforViewID	UniqueIdentifier,
	@ObjectID	UniqueIdentifier,
	@IsMultiSourced	Int,
	@IsLinkExternal Bit,
	@Status         Char(10),
	@URL		varchar(1000),
	@URLArguments	varchar(1000),
	@SectionURL	varchar(1000),
	@TemplateURL	varchar(1000),	
	@GroupID       	Int,
	@NCISectionID	UniqueIdentifier,
	@Priority	Int,
	@NCITemplateID	UniqueIdentifier,
	@Type		Char(10),
	@PropertyValue	varchar(7800),
	@TempUrl               varchar(250),
	@DirectoryID  UniqueIdentifier,
	@dupViewId   UniqueIdentifier,
	@TempStr	varchar(100)

SELECT	@Type= CASE WHEN @Audience='Patients' THEN 'SUMMARY_P'
			    WHEN @Audience='Health professionals' THEN 'SUMMARY_HP'
		END

PRINT	@Type 

SET	@RelatedViewID=NULL
SET	@replacementforViewID=NULL
SET	@NCIViewID=NULL

SELECT 	@RelatedViewID=NCIViewID FROM ViewObjects WHERE ObjectID=@RelatedDocumentGUID
SELECT 	@OtherLanguageViewID=NCIViewID FROM ViewObjects WHERE ObjectID=@OtherLanguageDocumentGUID
SELECT 	@replacementforViewID=NCIViewID FROM ViewObjects WHERE ObjectID=@replacementforDocumentGUID
SELECT	@TemplateURL = URL, @NCITemplateID =NCITemplateID FROM NCITemplate WHERE [Name]='Summary'

SELECT	@SectionURL= URL, @NCISectionID = NCIsectionID  FROM NCISection 
WHERE [Name] = case @language when 'SPANISH' then 'Spanish Support & Resources' else 'Cancerinfo' end 



SELECT	@GroupID = GroupID FROM Groups WHERE GroupName = 'PDQ Data'
SELECT	@URL = @SectionURL  + @TemplateURL

SET	@ObjectID=@DocumentGUID

PRINT '-- I was passed in ' + cast(@documentGUID as varchar(50)) + ' as the documentGUID'

SELECT @NCIViewID=NCIViewID 
FROM dbo.ViewObjects 
WHERE ObjectID=@ObjectID and nciviewid not in (select nciviewid from dbo.viewproperty where propertyname = 'redirectURL')

IF (@NCIViewID IS NOT NULL)
	PRINT '-- From which I got ' + cast(@NCIViewID as varchar(50)) + ' as the NCIViewID'

BEGIN  TRANSACTION   Tran_InsertForSummary


IF @NCIViewID IS NULL
BEGIN
	-- there are three cases where @NCIViewID IS NULL
	-- 	1) new summary (no prior version), then @RelatedViewID and @replacementforViewID are both NULL
	--	2) new version of a summary (usually patient), then @RelatedViewID is NOT NULL, but @replacementforViewID IS NULL
	--	3) replacement (remap) of an existing summary, then @replacementforViewID IS NOT NULL, and @RelatedViewID can be either one

	IF @RelatedViewID IS NULL AND @replacementforViewID IS NULL
	BEGIN
		-- so case (1), but why check for existing old NCIView?, ahh.....just in case (for a blank NCIView with no mappings to the summary documents)
		-- really should check for NCITemplateID as well FIXME

		--Check if NCIView exsits for old document
		IF @Title IS NOT NULL 
			AND EXISTS (SELECT 1 FROM NCIView WHERE title=@Title)
		BEGIN
			SELECT	@NCIViewID=NCIViewID FROM NCIView WHERE title=@Title
			PRINT '-- WARNING: using ' + cast(@NCIViewID as varchar(50)) + ' as the NCIViewID due to matched Title.  No matching ViewObject entry'

		END
		ELSE
		BEGIN
			--Create a new one
			SET 	@NCIViewID = newid()			

			SELECT 	@Status ='EDIT', 
				@IsMultiSourced = 2,	
				@IsLinkExternal  =0,  	
				@URLArguments ='viewid=' + Convert(Varchar(36), @NCIViewID)
	
			--Creat a new NCIView
			INSERT INTO NCIView 
			( 	Title,  
				ShortTitle,  
				Description,  
				URL, 
				URLArguments, 
				NCIViewID, 
				IsMultiSourced,
				IsLinkExternal, 
				Status, 
				NCITemplateID, 
				ExpirationDate, 
				ReleaseDate, 
				UpdateUSerID, 
				GroupID, 
				NCISectionID, 
				PostedDate, 
				DisplayDateMode)
			VALUES ( 
				@Title,
				@ShortTitle, 
				@Description, 
				@URL, 
				@URLArguments,
	 			@NCIViewID, 
				@IsMultiSourced,
				@IsLinkExternal, 
				@Status, 
				@NCITemplateID, 
				@ExpirationDate, 
				@ReleaseDate, 
				@UpdateUserId, 
				@GroupID, 
				@NCISectionID, 
				@PostedDate, 
				@DisplayDateMode)
			IF (@@ERROR <> 0)
			BEGIN
				ROLLBACK TRAN Tran_InsertForSummary
				RAISERROR ( 70004, 16, 1)
				RETURN 70004
			END 
		END  --  inserting new view, we now have @NCIViewID
	END -- end case(1)
	
	IF @replacementforViewID IS NULL
	BEGIN
		-- case (2) and case (1) -- new summary leaf.  create the viewobject mapping

		SET	@Priority =999

		IF	@RelatedViewID IS NOT NULL
			SET	@NCIViewID=@RelatedViewID

		--Creat a new ViewObject
		INSERT INTO ViewObjects 
			(NCIViewID, 
			ObjectID, 
			Type, 
			Priority, 
			UpdateUserID) 
		VALUES 
			(@NCIViewID, 
			@ObjectID, 
			@Type, 
			@Priority, 
			@UpdateUserID)

		IF (@@ERROR <> 0)
		BEGIN
			Rollback tran Tran_InsertForSummary
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END

		UPDATE	NCIView 
		SET	Title=@Title,  
			ShortTitle=@ShortTitle,  
			Description=@Description,  
			UpdateUserID=@UpdateUserId,
			UpdateDate = getdate()
		WHERE	NCIViewID=@RelatedViewID
	END
	ELSE
	BEGIN
		-- case (3) -- remapping of summary

		SET	@NCIViewID=@replacementforViewID

		UPDATE	ViewObjects
		SET	ObjectID=@ObjectID
		WHERE	NCIViewID=@replacementforViewID
		AND	ObjectID=@replacementforDocumentGUID

		UPDATE	PrettyURL
		SET	ObjectID=@ObjectID
		WHERE	NCIViewID=@NCIViewID
		AND	ObjectID=@replacementforDocumentGUID


		UPDATE	NCIView 
		SET	Title=@Title,  
			ShortTitle=@ShortTitle,  
			Description=@Description,  
			UpdateUserID=@UpdateUserId,
			UpdateDate = getdate()
		WHERE	NCIViewID=@replacementforViewID
	END	-- end inserting/updating of viewobject mapping
END
ELSE
BEGIN
	-- for the case where there is already an NCIViewID with a proper ViewObject mapping
	-- so not for summary remap
	UPDATE	NCIView 
	SET	Description = @Description,  
		UpdateUserID = @UpdateUserId,
		Title = @Title,
		ShortTitle = @ShortTitle,
		UpdateDate = getdate()
	WHERE	NCIViewID=@NCIViewID
END

--Set IsSpanishContent viewproperty 
SELECT	@PropertyValue= CASE WHEN @Language='English' THEN 'NO'
			    WHEN @Language='Spanish' THEN 'YES'
		       END

IF NOT EXISTS (SELECT 1 FROM viewproperty WHERE nciviewid= @NCIViewID and PropertyName = 'IsSpanishContent')
BEGIN
	INSERT INTO ViewProperty
	(NCIViewID, PropertyName, PropertyValue, UpdateDate, UpdateUserID)
	VALUES
	(@NCIViewID, 'IsSpanishContent', @PropertyValue, getdate(),@UpdateUserID)
	IF (@@ERROR <> 0)
	BEGIN
		Rollback tran Tran_InsertForSummary
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END
END
ELSE
BEGIN
	UPDATE ViewProperty
	SET 	PropertyValue	=@PropertyValue, 
		UpdateDate	= getdate(),
		UpdateUserID	=@UpdateUserID
	WHERE 	NCIViewID= @NCIViewID and PropertyName= 'IsSpanishContent'
	IF (@@ERROR <> 0)
	BEGIN
		Rollback tran Tran_InsertForSummary
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END
END

--Set OtherLanguageViewID viewproperty 

IF @OtherLanguageViewID IS NOT NULL
BEGIN

	SET	@PropertyValue=@OtherLanguageViewID

	IF NOT EXISTS (SELECT 1 FROM viewproperty WHERE nciviewid= @NCIViewID and PropertyName = 'OtherLanguageViewID')
	BEGIN
		INSERT INTO ViewProperty
		(NCIViewID, PropertyName, PropertyValue, UpdateDate, UpdateUserID)
		VALUES
		(@NCIViewID, 'OtherLanguageViewID', @PropertyValue, getdate(),@UpdateUserID)
		IF (@@ERROR <> 0)
		BEGIN
			Rollback tran Tran_InsertForSummary
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END
	END
	ELSE
	BEGIN
		UPDATE ViewProperty
		SET 	PropertyValue	=@PropertyValue, 
			UpdateDate	= getdate(),
			UpdateUserID	=@UpdateUserID
		WHERE 	NCIViewID= @NCIViewID and PropertyName= 'OtherLanguageViewID'
		IF (@@ERROR <> 0)
		BEGIN
			Rollback tran Tran_InsertForSummary
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END
	END
	


	SET	@PropertyValue=@NCIViewID

	IF NOT EXISTS (SELECT 1 FROM viewproperty WHERE nciviewid= @OtherLanguageViewID and PropertyName = 'OtherLanguageViewID')
	BEGIN
		INSERT INTO ViewProperty
		(NCIViewID, PropertyName, PropertyValue, UpdateDate, UpdateUserID)
		VALUES
		(@OtherLanguageViewID, 'OtherLanguageViewID', @PropertyValue, getdate(),@UpdateUserID)
		IF (@@ERROR <> 0)
		BEGIN
			Rollback tran Tran_InsertForSummary
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END
	END
	ELSE
	BEGIN
		UPDATE ViewProperty
		SET 	PropertyValue	=@PropertyValue, 
			UpdateDate	= getdate(),
			UpdateUserID	=@UpdateUserID
		WHERE 	NCIViewID= @OtherLanguageViewID and PropertyName= 'OtherLanguageViewID'
		IF (@@ERROR <> 0)
		BEGIN
			Rollback tran Tran_InsertForSummary
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END
	END
END

--Set IsPrintAvailable viewproperty 
SET	@PropertyValue='YES'
IF NOT EXISTS (SELECT 1 FROM viewproperty WHERE nciviewid= @NCIViewID and PropertyName = 'IsPrintAvailable')
BEGIN
	INSERT INTO ViewProperty
	(NCIViewID, PropertyName, PropertyValue, UpdateDate, UpdateUserID)
	VALUES
	(@NCIViewID, 'IsPrintAvailable', @PropertyValue, getdate(),@UpdateUserID)
	IF (@@ERROR <> 0)
	BEGIN
		Rollback tran Tran_InsertForSummary
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END
END
ELSE
BEGIN
	UPDATE 	ViewProperty
	SET 	PropertyValue	=@PropertyValue, 
		UpdateDate	= getdate(),
		UpdateUserID	=@UpdateUserID
	WHERE 	NCIViewID= @NCIViewID and PropertyName= 'IsPrintAvailable'
	IF (@@ERROR <> 0)
	BEGIN
		Rollback tran Tran_InsertForSummary
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END
END


--Set ForSeeSurveyParam viewproperty 

if exists 
	(select 1 from viewproperty 
		where nciviewid= @NCIViewID and 
			propertyname = 'IsSpanishContent' and  propertyvalue = 'YES')
	SET	@PropertyValue='sp_oeTriggerParams'
else
	SET	@PropertyValue='oeTriggerParams'

IF NOT EXISTS (SELECT 1 FROM viewproperty WHERE nciviewid= @NCIViewID and PropertyName = 'ForSeeSurveyParam')
BEGIN
	INSERT INTO ViewProperty
	(NCIViewID, PropertyName, PropertyValue, UpdateDate, UpdateUserID)
	VALUES
	(@NCIViewID, 'ForSeeSurveyParam', @PropertyValue, getdate(),@UpdateUserID)
	IF (@@ERROR <> 0)
	BEGIN
		Rollback tran Tran_InsertForSummary
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END
END
ELSE
BEGIN
	UPDATE 	ViewProperty
	SET 	PropertyValue	=@PropertyValue, 
		UpdateDate	= getdate(),
		UpdateUserID	=@UpdateUserID
	WHERE 	NCIViewID= @NCIViewID and PropertyName= 'ForSeeSurveyParam'
	IF (@@ERROR <> 0)
	BEGIN
		Rollback tran Tran_InsertForSummary
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END
END


--Set ShowExtractedGlossary viewproperty 
SET	@PropertyValue='YES'
IF NOT EXISTS (SELECT 1 FROM viewproperty WHERE nciviewid= @NCIViewID and PropertyName = 'ShowExtractedGlossary')
BEGIN
	INSERT INTO ViewProperty
	(NCIViewID, PropertyName, PropertyValue, UpdateDate, UpdateUserID)
	VALUES
	(@NCIViewID, 'ShowExtractedGlossary', @PropertyValue, getdate(),@UpdateUserID)
	IF (@@ERROR <> 0)
	BEGIN
		Rollback tran Tran_InsertForSummary
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END
END
ELSE
BEGIN
	UPDATE 	ViewProperty
	SET 	PropertyValue	=@PropertyValue, 
		UpdateDate	= getdate(),
		UpdateUserID	=@UpdateUserID
	WHERE 	NCIViewID= @NCIViewID and PropertyName= 'ShowExtractedGlossary'
	IF (@@ERROR <> 0)
	BEGIN
		Rollback tran Tran_InsertForSummary
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END
END


--Update PrettyURL
--Modified 07/07/2005 PrettyUrl is now passed in as a parameter
--update the base url 

IF (@URLArguments IS NULL)
BEGIN
	SELECT @URLArguments = URLArguments FROM NCIView WHERE NCIViewID = @NCIviewID
END

--SELECT  @TempUrl = @URL + '?' +  @URLArguments
SELECT  @TempUrl = '/templates/doc.aspx?' +  @URLArguments

-- make sure this base url is not used by any other views

IF EXISTS (SELECT 1 FROM prettyurl where ISNULL(ProposedUrl,CurrentUrl)=@BasePrettyUrl and NCIViewID<>@NCIViewID)
BEGIN
	PRINT '--   Error: The base url must be unique! Some other view has the same pretty url: ' + @BasePrettyURL
	PRINT '-- my NCIViewID: ' + cast(@NCIViewID as varchar(50))
	SELECT @TempStr = cast(NCIViewID as varchar(50)) FROM prettyurl where ISNULL(ProposedUrl,CurrentUrl)=@BasePrettyUrl and NCIViewID<>@NCIViewID
	PRINT '-- conflicting NCIViewID: ' + @TempStr
	
	
	Rollback tran Tran_InsertForSummary
	RAISERROR ( 70004, 16, 1)
	RETURN 70004
END 

IF @Language='Spanish'
BEGIN
	SELECT  @DirectoryID =  DirectoryID from directories where directoryname='/espanol/pdq/'
END
ELSE
BEGIN
	SELECT  @DirectoryID =  DirectoryID from directories where directoryname='/cancertopics/pdq/'
END

IF NOT  EXISTS (SELECT 1 FROM PrettyURL WHERE NCIViewID=@NCIViewID AND objectID IS NULL)
BEGIN
	INSERT	INTO PrettyURL
	(	NCIViewID,
		DirectoryID,
		ObjectID,
		RealURL,
		CurrentURL,
		ProposedURL,
		UpdateRedirectOrNot,
		IsPrimary,
		CreateDate ,
		UpdateUserID,
		UpdateDate,
		IsRoot 
	)
	VALUES(
	@NCIViewID,
	@DirectoryID,     
	NULL,
	@TempUrl,
	NULL,
	@BasePrettyUrl,
	1,
	1,
	Getdate() ,
	@UpdateUserID,
	Getdate(),
	1) 			

	IF (@@ERROR <> 0)
	BEGIN
		Rollback tran Tran_InsertForSummary
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 
END
ELSE
BEGIN

	UPDATE PrettyUrl
	SET ProposedURL = @BasePrettyUrl, UpdateDate = getDate(), UpdateUserID = @UpdateUserID
	WHERE NCIViewID=@NCIViewID 
		 AND objectID IS NULL 
		 AND IsPrimary=1

	IF (@@ERROR <> 0)
	BEGIN
		Rollback tran Tran_InsertForSummary
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 
END


IF NOT  EXISTS (SELECT 1 FROM PrettyURL WHERE NCIViewID=@NCIViewID AND objectID=@ObjectID)
BEGIN
	INSERT	INTO PrettyURL
		(	NCIViewID,
			DirectoryID,
			ObjectID,
			RealURL,
			CurrentURL,
			ProposedURL,
			UpdateRedirectOrNot,
			IsPrimary,
			CreateDate ,
			UpdateUserID,
			UpdateDate,
			IsRoot 
		)
	VALUES(
	 	@NCIViewID,
		@DirectoryID,
		@ObjectID,
		CASE WHEN @Audience='Patients' THEN 	@TempUrl+'&version=0'
		     WHEN @Audience='Health professionals' THEN @TempUrl+'&version=1'
		END,
		NULL,
		CASE WHEN @Audience='Patients' THEN @BasePrettyUrl+'/Patient'
		     WHEN @Audience='Health professionals' THEN @BasePrettyUrl+'/HealthProfessional'
		END,
		1,
		1,
		Getdate() ,
		@UpdateUserID,
		Getdate(),
		0) 	

	IF (@@ERROR <> 0)
	BEGIN
		Rollback tran Tran_InsertForSummary
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 
END
ELSE
BEGIN
	PRINT '--- Step 520: Updating leaf entry in prettyURL table ---'

	UPDATE PrettyUrl 
	SET ProposedURL =  CASE WHEN @Audience='Patients' THEN @BasePrettyUrl+'/Patient'
		     		     WHEN @Audience='Health professionals' THEN @BasePrettyUrl+'/HealthProfessional'
			        END,

	        UpdateDate = getDate(), 
 	        UpdateUserID = @UpdateUserID
	WHERE NCIViewID=@NCIViewID 
		 AND objectID = @ObjectID
		 AND IsPrimary=1

	IF (@@ERROR <> 0)
	BEGIN
		Rollback tran Tran_InsertForSummary
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 
END

--end of pretty url changes

UPDATE 	NCIView
SET 	Status ='EDIT',
	UpdateDate= getdate()
WHERE	NCIViewID = @NCIViewID
	
IF (@@ERROR <> 0)
BEGIN
	Rollback tran Tran_InsertForSummary
	RAISERROR ( 70004, 16, 1)
	RETURN 70004
END 

COMMIT tran Tran_InsertForSummary

	
RETURN 0 

END


GO
GRANT EXECUTE ON [dbo].[usp_UpdateNCIViewandViewObjectForSummary] TO [gatekeeper_role]
GO
