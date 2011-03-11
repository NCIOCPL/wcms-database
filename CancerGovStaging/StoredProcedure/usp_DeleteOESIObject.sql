IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_DeleteOESIObject]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_DeleteOESIObject]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** 	Object:  Stored Procedure dbo.usp_InsertViewObject    -- Jhe
	Purpose: This script can be used for deleting viewobjects/docparts down.	Script Date: 3/5/2003 11:43:49 pM ******/

CREATE PROCEDURE dbo.usp_DeleteOESIObject
(
	@NCIViewID       	UniqueIdentifier,
	@ObjectID		UniqueIdentifier,
	@Type			Char(10),
	@UpdateUserID		VarChar(40)
)
AS
BEGIN
	SET NOCOUNT ON;

	/*
	** A. Check info and Get  viewobject's info 
	*/	
	if(	
	  (@NCIViewID  IS NULL) OR (NOT EXISTS (SELECT NCIViewID FROM NCIview WHERE NCIViewID = @NCIViewID)) 
	  )	
	BEGIN
		RAISERROR ( 70001, 16, 1)
		RETURN 70001
	END

	if (@Type = 'DOC')
	BEGIN
		if(	
		  (@ObjectID	  IS NULL) OR (NOT EXISTS (SELECT ObjectID	 FROM viewobjects WHERE NCIViewID = @NCIViewID and objectID=@ObjectID)) 
		  )	
		BEGIN
			RAISERROR ( 70001, 16, 1)
			RETURN 70001
		END
	END
	ELSE
	BEGIN
		if(	
		  (@ObjectID	  IS NULL) OR (NOT EXISTS (SELECT docpartID	 FROM Docpart WHERE  docpartID=@ObjectID)) 
		  )	
		BEGIN
			RAISERROR ( 70001, 16, 1)
			RETURN 70001
		END
	END

	Declare 	
			@DocumentID		UniqueIdentifier

	BEGIN  TRAN   Tran_CreateHotfixStudyContact
	
	if (@Type = 'DOC')
	BEGIN
		-- delete view objects
			
		delete from viewobjects
		where objectID =@ObjectID and NCIViewID = @NCIViewID
		IF (@@ERROR <> 0)
		BEGIN
			Rollback tran Tran_CreateHotfixStudyContact
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 

		-- delete docpart						
		delete from docpart
		where documentID=@ObjectID
		IF (@@ERROR <> 0)
		BEGIN
			Rollback tran Tran_CreateHotfixStudyContact
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 

		-- delete document				
		delete from document
		where documentID=@ObjectID
		IF (@@ERROR <> 0)
		BEGIN
			Rollback tran Tran_CreateHotfixStudyContact
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 

	END
	ELSE
	BEGIN
		delete from docpart
		where docpartID =@ObjectID 
		IF (@@ERROR <> 0)
		BEGIN
			Rollback tran Tran_CreateHotfixStudyContact
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 
	END

	COMMIT tran Tran_CreateHotfixStudyContact

	SET NOCOUNT OFF
	RETURN 0 

END
GO
