IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[BestBet_BestBetCategory_Update]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[BestBet_BestBetCategory_Update]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].[BestBet_BestBetCategory_Update]
	@CategoryID uniqueidentifier,
	@CatName varchar(255),
	@Weight	int,
	@UpdateUserID varchar(50)
AS
BEGIN
	BEGIN TRY

		Update BestBetcategory
		SET 	CatName = @CatName, 
				Weight = @Weight,
				UpdateUserID =@UpdateUserID,
				UpdateDate =Getdate(),
				status = 1
		WHERE CategoryID = @CategoryID
		
	END TRY

	BEGIN CATCH
		
			RETURN 123004  -- BestBet_BestBetCategory_Update
		
	END CATCH 
END


GO
GRANT EXECUTE ON [dbo].[BestBet_BestBetCategory_Update] TO [websiteuser_role]
GO
