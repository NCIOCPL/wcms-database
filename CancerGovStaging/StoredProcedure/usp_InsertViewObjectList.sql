IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_InsertViewObjectList]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_InsertViewObjectList]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** 	Object:  Stored Procedure dbo.usp_InsertViewObject    
	Purpose: This script can be used for  inserting viewobjects.	Script Date: 1/30/2002 11:43:49 pM ******/

CREATE PROCEDURE dbo.usp_InsertViewObjectList
(
	@NCIViewID       	UniqueIdentifier,
	@ListID			UniqueIdentifier,
	@ListName		varchar(255), 
	@ListDesc		varchar(255), 
	@DescDisplay		bit, 
	@ReleaseDateDisplay	bit, 
	@ReleaseDateDisplayLoc	bit, 
	@Priority		Int,
	@Type			char(10),
	@UpdateUserID		VarChar(40)
)
AS
BEGIN
	SET NOCOUNT ON;


	BEGIN TRAN Tran_InsertLinkView

	INSERT INTO List 
	(ListID, ListName, ListDesc,  DescDisplay, ReleaseDateDisplay, ReleaseDateDisplayLoc,UpdateDate, UpdateUserID) 
	 VALUES
 	(@ListID, @ListName, @ListDesc, @DescDisplay, @ReleaseDateDisplay, @ReleaseDateDisplayLoc, getdate(), @UpdateUserID)
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_InsertLinkView
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 	

	INSERT INTO ViewObjects 
	(NCIViewID, ObjectID, Type, Priority, UpdateDate, UpdateUserID) 
	VALUES 
	(@NCIViewID, @ListID, @Type, @Priority, getdate(), @UpdateUserID) 
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_InsertLinkView
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 

	Update NCIView
	set 	Status =		'EDIT',
		UpdateDate	= getdate(),  
		UpdateUserID  	=@UpdateUserID  
	where NCIViewID = @NCIViewID
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_InsertLinkView
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 

	COMMIT TRAN  Tran_InsertLinkView



	SET NOCOUNT OFF
	RETURN 0 

END
GO
GRANT EXECUTE ON [dbo].[usp_InsertViewObjectList] TO [webadminuser_role]
GO
