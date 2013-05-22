IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_DeleteDigestDocListForProduction]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_DeleteDigestDocListForProduction]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** 	Object:  Stored Procedure dbo.usp_InsertViewObject    
	Purpose: This script can be used for  inserting view objects property value.	Script Date: 8/13/2003 11:43:49 pM 

*	EXEC sp_addmessage 80100, 16, N' CancerGov Error. Document Digest page property DigestRelatedList doesn't exist.'','us_english', true,replace
*	EXEC sp_addmessage 80106, 16, N' CancerGov Error. Unable to delete this DigestRelatedList list item on production'','us_english', true,replace
*	EXEC sp_addmessage 80107, 16, N' CancerGov Error. Unable to delete this DigestRelatedList list on production'','us_english', true,replace
*	EXEC sp_addmessage 80108, 16, N' CancerGov Error. Unable to delete this DigestRelatedList parent list on production'','us_english', true,replace
*	EXEC sp_addmessage 80109, 16, N' CancerGov Error. Unable to delete this DigestRelatedList viewobjectproperty DigestRelatedList on production'','us_english', true,replace
*
******/

CREATE PROCEDURE dbo.usp_DeleteDigestDocListForProduction
(
	@ObjectID		UniqueIdentifier
)
AS
BEGIN
	SET NOCOUNT ON;

	Declare @ListID UniqueIdentifier,
		@NVOID UniqueIdentifier,
		@PListID varchar(36)
	PRINT 'Begin usp_deleteDigestDocListForProduction' + Convert(varchar(36), @ObjectID) +'<br>'
	if(	
	  (@ObjectID IS NULL) OR (NOT EXISTS (Select V.NCIViewObjectID from CancerGov..ViewObjects V,  CancerGov..ViewObjectProperty P  Where V.ObjectID= @ObjectID and V.NCIViewObjectID = P.NCIViewObjectID and P.PropertyName ='DigestRelatedListID'))
	  )	
	BEGIN
		RAISERROR ( 80100, 16, 1)
		RETURN
	END

	Select @NVOID= V.NCIViewObjectID, @PListID = P.PropertyValue 
	from CancerGov..ViewObjects V,  CancerGov..ViewObjectProperty P  
	Where V.ObjectID= @ObjectID and V.NCIViewObjectID = P.NCIViewObjectID and P.PropertyName ='DigestRelatedListID'

	/*
	** Add a parentlist
	*/	
	--BEGIN  TRAN   Tran_CreateOrUpdatePrettyURL

	DECLARE ViewObject_Cursor CURSOR LOCAL FORWARD_ONLY  FOR
	SELECT 	ListID
	FROM 		CancerGov..List
	Where 		ParentListID = @PListID
	FOR READ ONLY 
	IF (@@ERROR <> 0)
	BEGIN
		--ROLLBACK TRAN Tran_CreateOrUpdatePrettyURL
		RAISERROR ( 70004, 16, 1)
		RETURN
	END 
		
	OPEN ViewObject_Cursor 
	IF (@@ERROR <> 0)
	BEGIN
		DEALLOCATE ViewObject_Cursor 
		--ROLLBACK TRAN Tran_CreateOrUpdatePrettyURL
		RAISERROR ( 70004, 16, 1)		
		RETURN
	END 
		
	FETCH NEXT FROM ViewObject_Cursor
	INTO 	@ListID

	WHILE @@FETCH_STATUS = 0
	BEGIN
		Print 'ListID =' + Convert(varchar(36), @ListID)
		Delete from CancerGov..Listitem where listid = @ListID
		IF (@@ERROR <> 0)
		BEGIN
			--Rollback tran Tran_CreateOrUpdatePrettyURL
			RAISERROR ( 80106, 16, 1)
			RETURN
		END 

		Delete from CancerGov..List where listid = @ListID
		IF (@@ERROR <> 0)
		BEGIN
			--Rollback tran Tran_CreateOrUpdatePrettyURL
			RAISERROR ( 80107, 16, 1)
			RETURN
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
	Delete from CancerGov..List where listid = @PListID
	IF (@@ERROR <> 0)
	BEGIN
		--Rollback tran Tran_CreateOrUpdatePrettyURL
		RAISERROR ( 80108, 16, 1)
		RETURN
	END 


	-- Delete viewobject property
	Delete from CancerGov..ViewObjectProperty where NCIViewObjectID= @NVOID
	IF (@@ERROR <> 0)
	BEGIN
		--Rollback tran Tran_CreateOrUpdatePrettyURL
		RAISERROR ( 80109, 16, 1)
		RETURN 
	END 

	--COMMIT tran  Tran_CreateOrUpdatePrettyURL

	SET NOCOUNT OFF
	RETURN 0 

END
GO
GRANT EXECUTE ON [dbo].[usp_DeleteDigestDocListForProduction] TO [webadminuser_role]
GO
