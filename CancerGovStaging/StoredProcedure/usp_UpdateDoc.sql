IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_UpdateDoc]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_UpdateDoc]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.usp_UpdateNCIView   Owner:Jhe Purpose: For admin side Script Date: 1/15/2002 16:00:49 pm ******/		
					
					
CREATE PROCEDURE dbo.usp_UpdateDoc(
	@DocumentID			UniqueIdentifier,
	@Title				VarChar(255),
	@ShortTitle			VarChar(64),
	@Description			VarChar(2000),
	@TOC				text,
	@Data				text,
	@UpdateUserID			varchar(40),
	@NCIViewID		UniqueIdentifier
				
)
AS
	SET NOCOUNT OFF;

	BEGIN TRAN Tran_InsertLinkView
	

		UPDATE Document 
		set 	Title =@Title, 
			ShortTitle =@ShortTitle, 
			Description = @Description, 
			TOC=@TOC, 
			Data= @Data, 
			UpdateUserID= @UpdateUserID
		where DocumentID =@DocumentID		
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
GRANT EXECUTE ON [dbo].[usp_UpdateDoc] TO [webadminuser_role]
GO
