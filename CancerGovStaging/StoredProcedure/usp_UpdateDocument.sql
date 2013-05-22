IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_UpdateDocument]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_UpdateDocument]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



--***********************************************************************
-- Create New Object 
--************************************************************************
/****** Object:  Stored Procedure dbo.usp_UpdateNCIView   Owner:Jhe Purpose: For admin side Script Date: 1/15/2002 16:00:49 pm ******/		
					
					
CREATE PROCEDURE dbo.usp_UpdateDocument
(
	@DocumentID			UniqueIdentifier,
	@Title				VarChar(255),
	@ShortTitle			VarChar(64),
	@Description			VarChar(2000),
	@TOC				text,
	@Data				text,
	@ExpirationDate 		DateTime,
	@ReleaseDate			DateTime,
	@PostedDate			DateTime,
	@DisplayDateMode		VarChar(10),
	@UpdateUserID			VarChar(40), 
	@NCIViewID		UniqueIdentifier				
)
AS
	SET NOCOUNT OFF;

	BEGIN TRAN Tran_InsertLinkView
	



		UPDATE Document 
		set 	Title =@Title, 
			ShortTitle =@ShortTitle, 
			Description = @Description, 
			TOC = @TOC, 
			Data= @Data, 
			ExpirationDate =@ExpirationDate, 
			ReleaseDate= @ReleaseDate, 
			PostedDate = @PostedDate,
			DisplayDateMode = @DisplayDateMode,
			UpdateUserID= @UpdateUserID 
		where DocumentID = @DocumentID
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
GRANT EXECUTE ON [dbo].[usp_UpdateDocument] TO [webadminuser_role]
GO
