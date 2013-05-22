IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_DeleteDigestDocList]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_DeleteDigestDocList]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** 	Object:  Stored Procedure dbo.usp_InsertViewObject    
	Purpose: This script can be used for  inserting view objects property value.	Script Date: 8/13/2003 11:43:49 pM
*	EXEC sp_addmessage 80100, 16, N' CancerGov Error. Document Digest page property DigestRelatedList doesn't exist.'','us_english', true,replace
*	EXEC sp_addmessage 80116, 16, N' CancerGov Error. Unable to delete this DigestRelatedList list item on staging'','us_english', true,replace
*	EXEC sp_addmessage 80117, 16, N' CancerGov Error. Unable to delete this DigestRelatedList list on staging'','us_english', true,replace
*	EXEC sp_addmessage 80118, 16, N' CancerGov Error. Unable to delete this DigestRelatedList parent list on staging'','us_english', true,replace
*	EXEC sp_addmessage 80119, 16, N' CancerGov Error. Unable to delete this DigestRelatedList viewobjectproperty DigestRelatedList on staging'','us_english', true,replace
*
 ******/

CREATE PROCEDURE dbo.usp_DeleteDigestDocList
(
	@ObjectID		UniqueIdentifier
)
AS
BEGIN
	SET NOCOUNT ON;

	Declare @ListID UniqueIdentifier,
		@NVOID UniqueIdentifier,
		@PListID varchar(36)

	if(	
	  (@ObjectID IS NULL) OR (NOT EXISTS (Select V.NCIViewObjectID from .ViewObjects V,  ViewObjectProperty P  Where V.ObjectID= @ObjectID and V.NCIViewObjectID = P.NCIViewObjectID and P.PropertyName ='DigestRelatedListID'))
	  )	
	BEGIN
		RAISERROR ( 80100, 16, 1)
		RETURN 80100
	END

	Select @NVOID= V.NCIViewObjectID, @PListID = P.PropertyValue 
	from ViewObjects V, ViewObjectProperty P  
	Where V.ObjectID= @ObjectID and V.NCIViewObjectID = P.NCIViewObjectID and P.PropertyName ='DigestRelatedListID'

	/*
	** Add a parentlist
	*/	
	BEGIN  TRAN   Tran_CreateOrUpdatePrettyURL

	DECLARE ViewObject_Cursor CURSOR LOCAL FORWARD_ONLY  FOR
	SELECT 	ListID
	FROM 		CancerGovStaging..List
	Where 		ParentListID = @PListID
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
	INTO 	@ListID

	WHILE @@FETCH_STATUS = 0
	BEGIN
		Print 'ListID =' + Convert(varchar(36), @ListID)
		Delete from CancerGovStaging..Listitem where listid = @ListID
		IF (@@ERROR <> 0)
		BEGIN
			Rollback tran Tran_CreateOrUpdatePrettyURL
			RAISERROR ( 80116, 16, 1)
			RETURN 80116
		END 

		Delete from CancerGovStaging..List where listid = @ListID
		IF (@@ERROR <> 0)
		BEGIN
			Rollback tran Tran_CreateOrUpdatePrettyURL
			RAISERROR ( 80117, 16, 1)
			RETURN 80117
		END 

		-- GET NEXT OBJECT
		PRINT '--get next'
		FETCH NEXT FROM ViewObject_Cursor
		INTO 	@ListID

	END -- End while
	
	-- CLOSE ViewObject_Cursor		
	CLOSE ViewObject_Cursor 
	DEALLOCATE ViewObject_Cursor 

	-- Delete Parentlist
	Delete from CancerGovStaging..List where listid = @PListID
	IF (@@ERROR <> 0)
	BEGIN
		Rollback tran Tran_CreateOrUpdatePrettyURL
		RAISERROR ( 80118, 16, 1)
		RETURN 80118
	END 


	-- Delete viewobject property
	Delete from CancerGovStaging..ViewObjectProperty where NCIViewObjectID= @NVOID
	IF (@@ERROR <> 0)
	BEGIN
		Rollback tran Tran_CreateOrUpdatePrettyURL
		RAISERROR ( 80119, 16, 1)
		RETURN 80119
	END 

	COMMIT tran  Tran_CreateOrUpdatePrettyURL

	SET NOCOUNT OFF
	RETURN 0 

END
GO
GRANT EXECUTE ON [dbo].[usp_DeleteDigestDocList] TO [webadminuser_role]
GO
