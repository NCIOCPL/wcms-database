IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_UpdateList]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_UpdateList]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.usp_UpdateNCIView   Owner:Jhe Purpose: For admin side Script Date: 1/15/2002 16:00:49 pm ******/		
					
					
CREATE PROCEDURE dbo.usp_UpdateList
(
	@ListID			UniqueIdentifier,
	@ListName 		VarChar(255),											
	@ListDesc     		VarChar(255),
	@DescDisplay     		bit,
	@ReleaseDateDisplay		bit,
	@ReleaseDateDisplayLoc 	bit,
	@UpdateUserID		varchar(40),
	@NCIViewID		UniqueIdentifier					
)
AS
	SET NOCOUNT OFF;

	Declare @ViewID	UniqueIdentifier

	select  @ViewID = NCIViewID from viewobjects where objectid=@ListID

	BEGIN TRAN Tran_InsertLinkView
	
	UPDATE List 
	SET 	ListName = @ListName ,  
		ListDesc =@ListDesc, 
		DescDisplay=@DescDisplay, 
		ReleaseDateDisplay=@ReleaseDateDisplay, 
		ReleaseDateDisplayLoc= @ReleaseDateDisplayLoc, 
		UpdateUserID= @UpdateUserID, 
		NCIViewID =@NCIViewID 
	WHERE ListID = @ListID
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_InsertLinkView
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 	




	COMMIT TRAN  Tran_InsertLinkView
	SET NOCOUNT OFF

	RETURN 0
GO
GRANT EXECUTE ON [dbo].[usp_UpdateList] TO [webadminuser_role]
GO
