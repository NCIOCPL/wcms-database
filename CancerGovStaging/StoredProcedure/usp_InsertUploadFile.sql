IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_InsertUploadFile]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_InsertUploadFile]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** 	Object:  Stored Procedure dbo.dbo.usp_InsertUploadFile    
	Purpose: This script can be used for uploading files, including pdf, xml, include and image files. This will be a transactional script, which creates a nciview and a viewobject.
	Script Date: 1/30/2002 11:43:49 pM ******/

CREATE PROCEDURE dbo.usp_InsertUploadFile
(
	@Title              		VarChar(255),
	@ShortTitle      		VarChar(64),
	@Description    		VarChar(1500),
	@URL              		VarChar(1000 ),
	@URLArguments    	VarChar(1000 ),
	@NCIViewID       	UniqueIdentifier,
	@IsLinkExternal  	Bit,
	@Status         	 	Char(10),
	@NCITemplateID	UniqueIdentifier,
	@UpdateUserID		VarChar(40 ),
	@GroupID       		Int,
	@NCISectionID		UniqueIdentifier,
	@ObjectID		UniqueIdentifier,
	@Type			Char(10),
	@Priority		Int
)
AS
BEGIN
	SET NOCOUNT ON;

	Declare @TemplateURL varchar(1000),
		@SectionURL	varchar(1000)

	SELECT @TemplateURL =URL FROM NCITemplate WHERE NCITemplateID = @NCITemplateID 
			
	select @SectionURL =URL FROM NCISection WHERE NCISectionID =@NCISectionID
			

	if (len(@URL) =0)
	BEGIN
		SELECT @URL = '/templates/' + @TemplateURL 
	END

	BEGIN TRAN Tran_InsertUploadFile
	/*
	** STEP - A
	** Insert a new row into NCIView table
	** if not return a 70004 error
	*/		

	INSERT INTO NCIView 
	( Title,  ShortTitle,  [Description],  URL, URLArguments,   NCIViewID,  IsLinkExternal,  Status,  NCITemplateID, UpdateUSerID, GroupID, NCISectionID)
 	VALUES 
	(@Title, @ShortTitle, @Description, @URL, @URLArguments, @NCIViewID, @IsLinkExternal, @Status, @NCITemplateID,  @UpdateUSerID, @GroupID, @NCISectionID)			
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_InsertUploadFile
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 

	/*
	** STEP - B
	** Add a viewobject for the above-created view 
	*/	

	INSERT INTO ViewObjects 
	(NCIViewID, ObjectID, Type, Priority) 
	VALUES 
	(@NCIViewID, @ObjectID, @Type, @Priority)
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_InsertUploadFile
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 

	COMMIT TRAN  Tran_InsertUploadFile
	SET NOCOUNT OFF
	RETURN 0 

END

GO
GRANT EXECUTE ON [dbo].[usp_InsertUploadFile] TO [webadminuser_role]
GO
