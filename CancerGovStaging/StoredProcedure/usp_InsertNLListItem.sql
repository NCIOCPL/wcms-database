IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_InsertNLListItem]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_InsertNLListItem]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
/****** 	Object:  Stored Procedure dbo.usp_InsertBViewForList    not finished yet
	Purpose: This script is used for create a ncivew for list, list_cols and menu_multi, a list and a viewobject.This will be a transactional script, which creates a nciview and a viewobject.
	Script Date: 1/30/2002 11:43:49 pM ******/

CREATE PROCEDURE dbo.usp_InsertNLListItem
(
	@NCIViewID       	UniqueIdentifier,	
	@ListID			uniqueidentifier,
	@Priority		int,
	@UpdateUserID		VarChar(50)
)
AS
BEGIN
	SET NOCOUNT ON;

	Declare		@Title              		VarChar(255),
			@ShortTitle              	VarChar(50),
			@Description    		VarChar(1500)

	select @Title = title, @ShortTitle = shortTitle, @Description = description from nciview where NCIViewid = @NCIViewID
	IF (@@ERROR <> 0)
	BEGIN
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 

	INSERT INTO NLListItem 
	(ListID, Title, ShortTitle, Description, NCIViewID, Priority, UpdateDate, UpdateUserID)  
	VALUES 
	(@ListID, @Title, @ShortTitle, @Description, @NCIViewID, @Priority, getdate(),  @UpdateUserID)	
	IF (@@ERROR <> 0)
	BEGIN
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 		

	SET NOCOUNT OFF
	RETURN 0 

END
GO
GRANT EXECUTE ON [dbo].[usp_InsertNLListItem] TO [webadminuser_role]
GO
