IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_UpdateNLListItem]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_UpdateNLListItem]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
/****** 	Object:  Stored Procedure dbo.usp_InsertViewObject    
	Purpose: This script can be used for  inserting view objects property value.	Script Date: 8/13/2003 11:43:49 pM ******/

CREATE PROCEDURE dbo.usp_UpdateNLListItem
(
	@NCIViewID		UniqueIdentifier,
	@ListID			UniqueIdentifier,
	@Title			varChar(255 ),
	@ShortTitle		varChar( 64 ),
	@Description		varChar(2000 ),
	@UpdateUserID		VarChar(50)
)
AS
BEGIN
	SET NOCOUNT ON;

	Update NLListItem
	Set 	title 	=@Title, 
		shorttitle	= @ShortTitle, 
		Description =@Description, 
		UpdateDate =getdate(), 
		UpdateUserID = @UpdateUserID
	where NCIViewID= @NCIViewID and ListID = @ListID
	IF (@@ERROR <> 0)
	BEGIN
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 

	SET NOCOUNT OFF
	RETURN 0 

END

GO
GRANT EXECUTE ON [dbo].[usp_UpdateNLListItem] TO [webadminuser_role]
GO
