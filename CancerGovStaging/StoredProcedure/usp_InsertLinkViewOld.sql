IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_InsertLinkViewOld]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_InsertLinkViewOld]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** 	Object:  Stored Procedure dbo.usp_InsertLinkView
	Purpose: This script is used for creating a new link view and create a listitem. This will be a transactional script.
	Script Date: 1/30/2002 11:43:49 pM ******/

CREATE PROCEDURE dbo.usp_InsertLinkViewOld
(
	@Title           		VarChar(255),
	@ShortTitle     		VarChar(50),
	@Description    		VarChar(1500),
	@URL			VarChar(1000),
	@NCIViewID 		UniqueIdentifier,
	@IsLinkExternal		Bit,
	@Status		Char(10),
	@UpdateUserID		VarChar(40),
	@GroupID		Int,
	@NCISectionID		UniqueIdentifier,
	@ListID			UniqueIdentifier	
)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRAN Tran_InsertLinkView
	/*
	** STEP - A
	** Insert a new row into NCIView table
	** if not return a 70004 error
	*/		

	INSERT INTO NCIView 
	(Title,  ShortTitle,  Description,  URL,  NCIViewID, IsLinkExternal, Status, UpdateUserID, GroupID, NCISectionID)
	 VALUES 
	(@Title, @ShortTitle, @Description, @URL, @NCIViewID, @IsLinkExternal, @Status, @UpdateUserID, @GroupID, @NCISectionID)
			
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_InsertLinkView
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 

	/*
	** STEP - B
	** Add a list item for the above-created view 
	*/	

	INSERT INTO ListItem 
	(ListID, NCIViewID, UpdateUserId) 
	VALUES 
	(@ListID, @NCIViewID, @UpdateUserID)
	
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
