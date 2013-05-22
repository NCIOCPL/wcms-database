IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_InsertNLList]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_InsertNLList]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
/****** 	Object:  Stored Procedure dbo.usp_InsertBViewForList    not finished yet
	Purpose: This script is used for create a ncivew for list, list_cols and menu_multi, a list and a viewobject.This will be a transactional script, which creates a nciview and a viewobject.
	Script Date: 1/30/2002 11:43:49 pM ******/

CREATE PROCEDURE dbo.usp_InsertNLList
(
	@NCIViewID       	UniqueIdentifier,	
	@ListID			uniqueidentifier,
	@Title              		VarChar(255),
	@Description    		VarChar(1500),
	@Priority		int,
	@UpdateUserID		VarChar(40)
)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRAN Tran_InsertViewForList
	/*
	** STEP -  A
	** Insert a new row into List table
	** if not return a 70004 error
	*/	
	INSERT INTO List 
	(ListID, ListName, ListDesc, UpdateUserID) 
	VALUES 
	(@ListID, @Title, @Description, @UpdateUserID)
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_InsertViewForList
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 

	/*
	** STEP -  B
	** Insert a new row into ViewObjects table
	** if not return a 70004 error
	*/	
	INSERT INTO ViewObjects 
	(NCIViewID, ObjectID, Type, Priority, UpdateUserID) 
	 VALUES 
	(@NCIViewID, @ListID, 'NLList', @Priority, @UpdateUserID)		
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_InsertViewForList
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 

	COMMIT TRAN  Tran_InsertViewForList
	SET NOCOUNT OFF
	RETURN 0 

END
GO
GRANT EXECUTE ON [dbo].[usp_InsertNLList] TO [webadminuser_role]
GO
