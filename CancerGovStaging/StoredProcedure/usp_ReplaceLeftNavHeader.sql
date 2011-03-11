IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_ReplaceLeftNavHeader]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_ReplaceLeftNavHeader]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** 	Object:  Stored Procedure dbo.usp_InsertViewObject    
	Purpose: This script can be used for  inserting viewobjects.	Script Date: 12/15/2003 11:43:49 pM ******/

CREATE PROCEDURE dbo.usp_ReplaceLeftNavHeader
(
	@NCIViewID       	UniqueIdentifier,
	@ObjectID		UniqueIdentifier,
	@UpdateUserID		VarChar(40),
	@OldObjectID		UniqueIdentifier
)
AS
BEGIN
	SET NOCOUNT ON;


	/*
	** Add a viewobject 
	*/	
	BEGIN  TRAN   Tran_Create

	UPDATE ViewObjects 
	Set  	ObjectID = @ObjectID,
		UpdateUserID = @UpdateUserID
	where NCIViewID = @NCIViewID  and  ObjectID = @OldObjectID
	IF (@@ERROR <> 0)
	BEGIN
		Rollback tran Tran_Create
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 

	UPDATE NCIView
		set status ='EDIT',
		      updatedate = getdate(),
		      UpdateUserID = @UpdateUserID
	WHERE NCIViewID = @NCIViewID			
	IF (@@ERROR <> 0)
	BEGIN
		Rollback tran Tran_Create
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 


	COMMIT tran Tran_Create

	SET NOCOUNT OFF
	RETURN 0 

END
GO
GRANT EXECUTE ON [dbo].[usp_ReplaceLeftNavHeader] TO [webadminuser_role]
GO
