IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_UpdateInclude]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_UpdateInclude]
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

CREATE PROCEDURE dbo.usp_UpdateInclude
(
	@NCIViewID       	UniqueIdentifier,
	@NormalInclude		text,
	@TextInclude    		text,
	@UpdateUserID       	VarChar(40)
)
AS
BEGIN
	SET NOCOUNT ON;

	Declare @NDocumentID	 	UniqueIdentifier,
		@TDocumentID	 	UniqueIdentifier,
		@Title              		VarChar(255),
		@ShortTitle      		VarChar(50)

	SELECT @NDocumentID = ObjectID from ViewObjects where NCIViewID=@NCIViewID and Type='INCLUDE'

	SELECT @TDocumentID =  ObjectID from ViewObjects where NCIViewID=@NCIViewID and Type='TXTINCLUDE'
	
	SELECT @Title =Title, @ShortTitle=ShortTitle from NCIView where NCIViewID = @NCIViewID

	BEGIN TRAN Tran_InsertUploadFile
	/*
	** STEP - A
	** Insert a new row into NCIView table
	** if not return a 70004 error
	*/		

	if( NOT EXISTS (SELECT * from Document where DocumentID =  @NDocumentID) )	
	BEGIN
		INSERT INTO Document  (DocumentID, title, shorttitle, data, updateUserID, UpdateDate)
		VALUES
		(@NDocumentID, @Title, @ShortTitle ,@NormalInclude, @UpdateUserID, getdate())
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN Tran_InsertUploadFile
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 
	END
	ELSE
	BEGIN
		UPDATE Document
		set data =@NormalInclude,
		      updateUserID= @UpdateUserID, 
		      UpdateDate =getdate()
		Where   DocumentID = @NDocumentID
	END

	if( NOT EXISTS (SELECT * from Document where DocumentID =  @TDocumentID) )	
	BEGIN
		INSERT INTO Document  (DocumentID, title, shorttitle, data, updateUserID, UpdateDate)
		VALUES
		(@TDocumentID, @Title, @ShortTitle ,@TextInclude, @UpdateUserID, getdate())
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN Tran_InsertUploadFile
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 
	END
	ELSE
	BEGIN
		UPDATE Document
		set data =@TextInclude,
		      updateUserID= @UpdateUserID, 
		      UpdateDate =getdate()
		Where   DocumentID = @TDocumentID
	END
	
	COMMIT TRAN  Tran_InsertUploadFile
	SET NOCOUNT OFF
	RETURN 0 

END
GO
GRANT EXECUTE ON [dbo].[usp_UpdateInclude] TO [webadminuser_role]
GO
