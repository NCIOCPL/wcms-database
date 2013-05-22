IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_InsertBestBetsSynonyms]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_InsertBestBetsSynonyms]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--***********************************************************************
-- Create New Object 
--************************************************************************
/****** 	Object:  Stored Procedure dbo.usp_UpdateTopicSearch    
	Owner:	Jay He
	Script Date: 7/16/2003 14:43:49 pM 
******/

CREATE PROCEDURE dbo.usp_InsertBestBetsSynonyms
(
	@SynonymID			UniqueIdentifier,
	@SynName			VarChar (255 ),
	@CategoryID			UniqueIdentifier,
	@Notes				VarChar (2000),
	@IsNegated			Bit, 		
	@IsExactMatch	bit,							
	@UpdateUserID  		VarChar(50)
)
AS
BEGIN

	BEGIN TRAN Tran_DeleteNCIView

	INSERT INTO BestBetSynonyms 
	(SynonymID, SynName, CategoryID,  Notes, IsNegated, updateuserID, updatedate, IsExactMatch) 
	 VALUES 
	(@SynonymID, @SynName, @CategoryID,  @Notes, @IsNegated, @UpdateUserID, getdate(), @IsExactMatch)
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
GRANT EXECUTE ON [dbo].[usp_InsertBestBetsSynonyms] TO [webadminuser_role]
GO
