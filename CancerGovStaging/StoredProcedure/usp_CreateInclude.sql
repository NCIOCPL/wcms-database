IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_CreateInclude]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_CreateInclude]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** 	Object:  Stored Procedure dbo.dbo.usp_Createinclude 
	Purpose: This script can be used for include files,This will be a transactional script, which creates a nciview and a viewobject.
	Script Date: 1/6/2003 11:43:49 pM 
	Jay He
******/

CREATE PROCEDURE dbo.usp_CreateInclude
(
	@NCIViewID       	UniqueIdentifier,
	@Title              		VarChar(255),
	@ShortTitle      		VarChar(50),
	@Description    		VarChar(1500),
	@NormalInclude		text,
	@TextInclude    		text,
	@NCITemplateID	UniqueIdentifier,
	@NCISectionID		UniqueIdentifier,
	@GroupID       		Int,
	@UpdateUserID       	VarChar(40)
)
AS
BEGIN
	SET NOCOUNT ON;

	Declare @URL			varchar(1000),
		@URLArguments	varchar(1000),
		@NDocumentID	 	UniqueIdentifier,
		@TDocumentID	 	UniqueIdentifier

	SELECT @URL=S.URL + T.URL FROM  NCISection S, NCITemplate T WHERE T.NCITemplateID = @NCITemplateID and S.NCISectionID= @NCISectionID	

	SELECT @URLArguments= 'viewid=' + convert(varchar(36), @NCIViewID)

	SET @NDocumentID = newid()

	SET @TDocumentID = newid()
	
	BEGIN TRAN Tran_InsertUploadFile
	/*
	** STEP - A
	** Insert a new row into NCIView table
	** if not return a 70004 error
	*/		

	
	INSERT INTO NCIView 
	( Title,  ShortTitle,  [Description],  URL, URLArguments,   NCIViewID,  IsLinkExternal,  Status,  NCITemplateID, UpdateUSerID, GroupID, NCISectionID)
 	VALUES 
	(@Title, @ShortTitle, @Description, @URL, @URLArguments, @NCIViewID, 0, 'Edit', @NCITemplateID,  @UpdateUserID, @GroupID, @NCISectionID)			
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_InsertUploadFile
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 

	/*
	** STEP - B
	** Add Normal include and text include to document table
	*/	
	INSERT INTO Document  (DocumentID, title, shorttitle, data, updateUserID, UpdateDate)
	VALUES
	(@NDocumentID, @Title, @ShortTitle ,@NormalInclude, @UpdateUserID, getdate())
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_InsertUploadFile
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 

	INSERT INTO Document  (DocumentID, title, shorttitle, data, updateUserID, UpdateDate)
	VALUES
	(@TDocumentID, @Title, @ShortTitle ,@TextInclude, @UpdateUserID, getdate())
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_InsertUploadFile
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 

	/*
	** STEP - C
	** Add a viewobject for the above-created view 
	*/	

	INSERT INTO ViewObjects 
	(NCIViewID, ObjectID, Type, Priority) 
	VALUES 
	(@NCIViewID, @NDocumentID, 'INCLUDE', 999)
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_InsertUploadFile
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 

	INSERT INTO ViewObjects 
	(NCIViewID, ObjectID, Type, Priority) 
	VALUES 
	(@NCIViewID, @TDocumentID, 'TXTINCLUDE', 999)
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
GRANT EXECUTE ON [dbo].[usp_CreateInclude] TO [webadminuser_role]
GO
