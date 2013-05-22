IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_UpdateFeature]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_UpdateFeature]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.usp_UpdateNCIView   Owner:Jhe Purpose: For admin side Script Date: 1/15/2002 16:00:49 pm ******/		
					
					
CREATE PROCEDURE dbo.usp_UpdateFeature
(
	@ListID		UniqueIdentifier,
	@NCIViewID	UniqueIdentifier,
	@Type		varchar(10)
)
AS
	SET NOCOUNT OFF;


	BEGIN TRAN Tran_DeleteList

	Update ListItem 
	Set 	IsFeatured = 0 
	WHERE ListID =@ListID						
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN  Tran_DeleteList
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 

	if (@Type ='FEATURE')
	BEGIN
		Update ListItem 
		SET 	IsFeatured =1 
		WHERE NCIViewID =@NCIViewID  AND ListID =@ListID	
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN  Tran_DeleteList
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 
	END

	Commit TRAN Tran_DeleteList
	RETURN 0
GO
GRANT EXECUTE ON [dbo].[usp_UpdateFeature] TO [webadminuser_role]
GO
