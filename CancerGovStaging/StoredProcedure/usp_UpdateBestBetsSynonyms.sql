IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_UpdateBestBetsSynonyms]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_UpdateBestBetsSynonyms]
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

CREATE PROCEDURE dbo.usp_UpdateBestBetsSynonyms
(
	@SynonymID			UniqueIdentifier,
	@SynName 			varchar(255),
	@Notes 			varchar(2000),
	@IsNegated			bit,
	@IsExactMatch	bit,				
	@UpdateUserID  		VarChar(50)
)
AS
BEGIN

	Declare @CategoryID	UniqueIdentifier
	

	select @CategoryID=CategoryID from  BestBetSynonyms where SynonymID=@SynonymID


	BEGIN TRAN Tran_DeleteNCIView

	UPDATE  BestBetSynonyms
	set 	SynName	=	@SynName, 	
		Notes		= 	@Notes,
		IsNegated	=	@IsNegated,
		IsExactMatch 	= 	@IsExactMatch,
		UpdateUserID	=	@UpdateUserID
	where    SynonymID	 =@SynonymID	
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
GRANT EXECUTE ON [dbo].[usp_UpdateBestBetsSynonyms] TO [webadminuser_role]
GO
