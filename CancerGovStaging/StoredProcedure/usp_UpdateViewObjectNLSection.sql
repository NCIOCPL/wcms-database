IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_UpdateViewObjectNLSection]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_UpdateViewObjectNLSection]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
/****** 	Object:  Stored Procedure dbo.usp_InsertViewObject    
	Purpose: This script can be used for  inserting view objects property value.	Script Date: 8/13/2003 11:43:49 pM ******/

CREATE PROCEDURE dbo.usp_UpdateViewObjectNLSection
(
	@ObjectID		UniqueIdentifier,
	@Title			varChar(255 ),
	@ShortTitle		varChar( 64 ),
	@Description		varChar(2000 ),
	@HTMLBody          	text,
	@PlainBody		text,
	@UpdateUserID		VarChar(40)
)
AS
BEGIN
	SET NOCOUNT ON;

	Update NLSection
	Set 	title 	=@Title, 
		shorttitle	= @ShortTitle, 
		Description =@Description, 
		HTMLBody =@HTMLBody, 
		PlainBody =@PlainBody, 
		UpdateDate =getdate(), 
		UpdateUserID = @UpdateUserID
	where NLSectionID = @ObjectID 
	IF (@@ERROR <> 0)
	BEGIN
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 

	SET NOCOUNT OFF
	RETURN 0 

END

GO
GRANT EXECUTE ON [dbo].[usp_UpdateViewObjectNLSection] TO [webadminuser_role]
GO
