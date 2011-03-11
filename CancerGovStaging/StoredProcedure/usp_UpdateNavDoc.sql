IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_UpdateNavDoc]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_UpdateNavDoc]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.usp_UpdateNCIView   Owner:Jhe Purpose: For admin side Script Date: 1/15/2002 16:00:49 pm ******/		

-- 2/2/2003	Alex Pidlisnyy change parameter 	@Data	from VarChar(255) to VarChar(8000)
					
					
CREATE PROCEDURE dbo.usp_UpdateNavDoc
(
	@DocumentID			UniqueIdentifier,
	@Title		VarChar(255),											
	@Data		VarChar(8000),
	@UpdateUserID		varchar(40),
	@NCIViewID		UniqueIdentifier					
)
AS
	SET NOCOUNT OFF;

	BEGIN TRAN Tran_InsertLinkView
	
	UPDATE Document 
	set 	Title =@Title, Data=@Data, UpdateUserID=@UpdateUserID 
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
GRANT EXECUTE ON [dbo].[usp_UpdateNavDoc] TO [webadminuser_role]
GO
