IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_InsertBestBetCategory]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_InsertBestBetCategory]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO

/**********************************************************************************

	Object's name:	usp_InsertBestBetCategory
	Object's type:	Stored Procedure
	Purpose:	Insert data
	Change History:	02-11-03	Jay He	
			11/04/2004	Lijia add ChangeComments

**********************************************************************************/
CREATE PROCEDURE dbo.usp_InsertBestBetCategory
(
	@CatName 	varchar(255),
	@CatProfile 	text,
	@Weight	int,
	@IsSpanish	bit,
	@IsExactMatch	bit,
	@ListID 	uniqueidentifier,
	@UpdateUserID  	VarChar(40),
	@ChangeComments	VARCHAR(2000)=NULL
)
AS
BEGIN
	SET NOCOUNT ON;

	/*
	** STEP - A
	** First Validate that the list ID(guid) provided is valid
	** if not return a 70001 error
	*/		
	if(	
	  (@ListID IS NULL) OR (EXISTS (SELECT ListID FROM List WHERE ListID = @ListID)) 
	  )	
	BEGIN
		RAISERROR ( 70001, 16, 1)
		RETURN 70001
	END

	BEGIN TRAN Tran_InsertBestBetCategory

	/*
	** STEP - B
	** Add List for category
	*/	

	INSERT INTO List (ListID, ListName, UpdateUserID) 
	VALUES 
	(@ListID, @CatName, @UpdateUserID)
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_InsertBestBetCategory
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 

	/*
	** STEP - C
	** Add category
	*/	

	INSERT INTO BestBetCategories
	(CatName, CatProfile, ListID, Weight, Status,  UpdateUserID, UpdateDate ,IsSpanish,ChangeComments, IsExactMatch) 
	VALUES 
	(@CatName, @CatProfile, @ListID, @Weight, 'Edit', @UpdateUserID, getdate(),@IsSpanish, @ChangeComments, @IsExactMatch)
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_InsertBestBetCategory
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 

	Print(str(@IsSpanish))

	COMMIT TRAN  Tran_InsertBestBetCategory
	SET NOCOUNT OFF
	RETURN 0 

END


GO
GRANT EXECUTE ON [dbo].[usp_InsertBestBetCategory] TO [webadminuser_role]
GO
