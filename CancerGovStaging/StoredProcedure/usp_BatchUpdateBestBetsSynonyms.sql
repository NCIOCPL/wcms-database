IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_BatchUpdateBestBetsSynonyms]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_BatchUpdateBestBetsSynonyms]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** 	Object:  Stored Procedure dbo.usp_UpdateTopicSearch    
	Owner:	Jay He
	Script Date: 7/16/2003 14:43:49 pM 
******/

CREATE PROCEDURE dbo.usp_BatchUpdateBestBetsSynonyms
(
	@CategoryID			UniqueIdentifier,
	@Weight			Int,
	@UpdateUserID  		VarChar(50)
)
AS
BEGIN

	BEGIN TRAN Tran_DeleteNCIView

	Update  BestBetSynonyms 
	set 	Weight= @Weight, 
		updateuserID= updateuserID, 
		updatedate = getdate() 
	where CategoryID = @CategoryID
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN  Tran_DeleteNCIView
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 

	UPDATE BestBetCategories 
	set 	Status		=	'Edit',
		UpdateUserID	=	@UpdateUserID
	where CategoryID = @CategoryID
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN  Tran_DeleteNCIView
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 

	COMMIT TRAN Tran_DeleteNCIView
	RETURN 0 

END
GO
GRANT EXECUTE ON [dbo].[usp_BatchUpdateBestBetsSynonyms] TO [webadminuser_role]
GO
