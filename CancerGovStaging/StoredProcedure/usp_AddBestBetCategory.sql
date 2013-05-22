IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_AddBestBetCategory]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_AddBestBetCategory]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/****** Object:  Stored Procedure dbo.usp_AddBestBetCategory    Script Date: 10/5/2001 10:45:48 AM ******/
CREATE PROCEDURE dbo.usp_AddBestBetCategory
(
	@CategoryID uniqueidentifier,
	@CatName varchar(50),
	@CatProfile text,
	@ListID uniqueidentifier
)
AS
	SET NOCOUNT OFF;
INSERT INTO BestBetCategories
(CategoryID, CatName, CatProfile, ListID) 
VALUES 
(@CategoryID, @CatName, @CatProfile, @ListID);

SELECT CategoryID, CatName, CatProfile, ListID 
FROM BestBetCategories 
WHERE (CategoryID = @CategoryID)

GO
