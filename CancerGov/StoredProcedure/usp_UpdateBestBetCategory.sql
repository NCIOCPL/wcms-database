IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_UpdateBestBetCategory]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_UpdateBestBetCategory]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/****** Object:  Stored Procedure dbo.usp_UpdateBestBetCategory    Script Date: 10/5/2001 10:45:49 AM ******/
CREATE PROCEDURE dbo.usp_UpdateBestBetCategory
	(
	@CategoryID uniqueidentifier,
	@CatName varchar(50),
	@CatProfile text,
	@ListID uniqueidentifier
	)
AS
BEGIN
	SET NOCOUNT OFF

	UPDATE BestBetCategories 
	SET 	CatName = @CatName, 
	        	CatProfile = @CatProfile,
		ListID  	= @ListID 
	 WHERE CategoryID = @CategoryID

	SELECT 
		CategoryID, 
		CatName, 
		CatProfile, 
		ListID 
	FROM 	BestBetCategories 
	WHERE CategoryID = @CategoryID

	SET NOCOUNT ON
END

GO
