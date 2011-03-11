IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_UpdateBestBetsCategories]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_UpdateBestBetsCategories]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


/**********************************************************************************

	Object's name:	usp_UpdateBestBetsCategories  
	Object's type:	Stored Procedure
	Purpose:	Update Categories
	Change History:	7/16/2003	Jay He	
			11/04/2004	Lijia add ChangeComments

**********************************************************************************/

CREATE PROCEDURE dbo.usp_UpdateBestBetsCategories
(
	@CategoryID		UniqueIdentifier,
	@CatName		varchar(255),
	@CatProfile		varchar(2500), 
	@Weight			int,
	@IsSpanish		bit,
	@IsExactMatch		bit,
	@UpdateUserID  		VarChar(50),
	@ChangeComments		VarChar(2000)=NULL
)
AS
BEGIN

	UPDATE  BestBetCategories
	set 	CatName		=	@CatName, 	
		Weight		=	@Weight,	
		CatProfile	=	@CatProfile,
		Status		=	'Edit',
		IsSpanish 	= 	@IsSpanish,
		IsExactMatch 	= 	@IsExactMatch,
		UpdateUserID	=	@UpdateUserID,
		ChangeComments  =	@ChangeComments

	where CategoryID = @CategoryID
	IF (@@ERROR <> 0)
	BEGIN
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 

	RETURN 0 

END


GO
GRANT EXECUTE ON [dbo].[usp_UpdateBestBetsCategories] TO [webadminuser_role]
GO
