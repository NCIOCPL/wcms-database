IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_UpdateSearchDoc]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_UpdateSearchDoc]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



--***********************************************************************
-- Create New Object 
--************************************************************************


		
CREATE PROCEDURE dbo.usp_UpdateSearchDoc(
	@DocumentID			UniqueIdentifier,
	@Data				text,
	@UpdateUserID			varchar(40),
	@NCIViewID		UniqueIdentifier
				
)
AS
	SET NOCOUNT OFF;

	BEGIN TRAN Tran_InsertLinkView
	

		UPDATE Document 
		set 	Data= @Data, 
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
GRANT EXECUTE ON [dbo].[usp_UpdateSearchDoc] TO [webadminuser_role]
GO
