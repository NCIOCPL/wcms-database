IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_UpdateOESIDoc]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_UpdateOESIDoc]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.usp_UpdateNCIView   Owner:Jhe Purpose: For admin side Script Date: 1/15/2002 16:00:49 pm ******/		
					
					
CREATE PROCEDURE dbo.usp_UpdateOESIDoc
(
	@NCIViewID		UniqueIdentifier,		
	@DocumentID			UniqueIdentifier,
	@Title		VarChar(255),											
	@ShortTitle	VarChar(50),
	@UpdateUserID		varchar(40)	
)
AS
	SET NOCOUNT OFF;

	BEGIN TRAN Tran_InsertLinkView
	
	UPDATE Document 
	set 	Title =@Title, 
		ShortTitle = @ShortTitle,
		UpdateUserID=@UpdateUserID 
	where documentID= @DocumentID				
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
GO
