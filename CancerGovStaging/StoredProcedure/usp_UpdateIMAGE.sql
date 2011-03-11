IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_UpdateIMAGE]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_UpdateIMAGE]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.usp_UpdateNCIView   Owner:Jhe Purpose: For admin side Script Date: 1/15/2002 16:00:49 pm ******/		
					
					
CREATE PROCEDURE dbo.usp_UpdateIMAGE
(
	@ImageID			UniqueIdentifier,
	@ImageName			VarChar(200),
	@ImageSource			VarChar(200),
	@TextSource			VarChar(1000),
	@URL				VarChar(1000),
	@Width				Int,
	@Height				Int,
	@Border				Int,
	@ImageAltText			VarChar(200),
	@UpdateUserID			VarChar(50), 
	@NCIViewID		UniqueIdentifier					
)
AS
	SET NOCOUNT OFF;

	BEGIN TRAN Tran_InsertLinkView
	
	UPDATE [Image] 
	set 	ImageName =@ImageName, 
		ImageSource=@ImageSource, 
		TextSource= @TextSource,  
		URL= @URL, 
		Width=@Width, 
		Height= @Height, 
		Border=@Border,
		ImageAltText=@ImageAltText, 
		UpdateUserID=@UpdateUserID 
	where ImageID=@ImageID
						
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
GRANT EXECUTE ON [dbo].[usp_UpdateIMAGE] TO [webadminuser_role]
GO
