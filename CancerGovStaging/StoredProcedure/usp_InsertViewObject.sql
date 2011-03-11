IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_InsertViewObject]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_InsertViewObject]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/****** 	Object:  Stored Procedure dbo.usp_InsertViewObject    
	Purpose: This script can be used for  inserting viewobjects.	Script Date: 1/30/2002 11:43:49 pM ******/

CREATE PROCEDURE dbo.usp_InsertViewObject
(
	@NCIViewID       	UniqueIdentifier,
	@ObjectID		UniqueIdentifier,
	@Type			Char(10),
	@Priority		Int,
	@UpdateUserID		VarChar(40)
)
AS
BEGIN
	SET NOCOUNT ON;

	/*
	** Add a viewobject 
	*/	
	BEGIN tran Tran_CreateHotfixStudyContact


	if (@Type ='HEADER')
	BEGIN
		select @Priority = 3000 + @Priority
	END

	INSERT INTO ViewObjects 
	(NCIViewID, ObjectID, Type, Priority, UpdateUserID) 
	VALUES 
	(@NCIViewID, @ObjectID, @Type, @Priority, @UpdateUserID)
	IF (@@ERROR <> 0)
	BEGIN
		Rollback tran Tran_CreateHotfixStudyContact
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 

	UPDATE NCIView
	Set 	status	='EDIT',
		updateuserID = @UpdateUserID
	where nciviewid = @NCIViewID
	IF (@@ERROR <> 0)
	BEGIN
		Rollback tran Tran_CreateHotfixStudyContact
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 

	COMMIT tran Tran_CreateHotfixStudyContact

	SET NOCOUNT OFF
	RETURN 0 

END

GO
GRANT EXECUTE ON [dbo].[usp_InsertViewObject] TO [webadminuser_role]
GO
