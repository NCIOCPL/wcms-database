IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_InsertDigestDocList]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_InsertDigestDocList]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** 	Object:  Stored Procedure dbo.usp_InsertViewObject    
	Purpose: This script can be used for  inserting view objects property value.	Script Date: 8/13/2003 11:43:49 pM ******/

CREATE PROCEDURE dbo.usp_InsertDigestDocList
(
	@ObjectID		UniqueIdentifier,
	@UpdateUserID		VarChar(40)
)
AS
BEGIN
	SET NOCOUNT ON;

	Declare @ListID UniqueIdentifier,
		@NCIViewID	UniqueIdentifier,
		@NVOID UniqueIdentifier,
		@Name	 varchar(50)


	Select @ListID = newid()

	Select @NVOID= NCIViewObjectID, @NCIViewID = NCIViewID from ViewObjects Where ObjectID= @ObjectID

	select @Name = 'DigestRelatedListID'

	/*
	** Add a parentlist
	*/	
	BEGIN  TRAN   Tran_CreateHotfixStudyContact

	INSERT INTO List 
	(ListID, ListName, ListDesc, Priority, UpdateUserID) 
	VALUES 
	(@ListID, 'Parent List', 'A view object property of ' + convert(varchar(36), @ObjectID), 1000, @UpdateUserID)
	IF (@@ERROR <> 0)
	BEGIN
		Rollback tran Tran_CreateHotfixStudyContact
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 

	INSERT INTO List 
	(ListID, ListName, ListDesc, ParentListID, Priority, UpdateUserID) 
	VALUES 
	(newid(), 'Child List', 'Child List', @ListID, 1, @UpdateUserID)
	IF (@@ERROR <> 0)
	BEGIN
		Rollback tran Tran_CreateHotfixStudyContact
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 

	INSERT INTO ViewObjectProperty
	(NCIViewObjectID, PropertyName, PropertyValue, UpdateUserID) 
	VALUES 
	(@NVOID, @Name,  convert(varchar(36), @ListID), @UpdateUserID)
	IF (@@ERROR <> 0)
	BEGIN
		Rollback tran Tran_CreateHotfixStudyContact
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 

	Update NCIView
	set 	status ='EDIT',
		updateUserID = @UpdateUserID
	where nciviewid =@NCIViewID

	COMMIT tran Tran_CreateHotfixStudyContact

	SET NOCOUNT OFF
	RETURN 0 

END
GO
GRANT EXECUTE ON [dbo].[usp_InsertDigestDocList] TO [webadminuser_role]
GO
