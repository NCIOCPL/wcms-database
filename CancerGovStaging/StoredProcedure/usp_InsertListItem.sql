IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_InsertListItem]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_InsertListItem]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** 	Object:  Stored Procedure dbo.usp_InsertListitem
	Purpose: This script is used for create list item
	Script Date: 1/30/2002 11:43:49 pM ******/

CREATE PROCEDURE dbo.usp_InsertListItem
(
	@ListID			uniqueidentifier,
	@NCIViewID		uniqueidentifier,
	@Priority		int,
	@UpdateUserID		VarChar(50)
)
AS
BEGIN

	INSERT INTO ListItem (ListID, NCIViewID, Priority,UpdateDate, UpdateUserID )  
	VAlues
	(@ListID, @NCIViewID, @Priority, getdate(),  @UpdateUserID)	
	IF (@@ERROR <> 0)
	BEGIN
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 		

	RETURN 0 

END
GO
GRANT EXECUTE ON [dbo].[usp_InsertListItem] TO [webadminuser_role]
GO
