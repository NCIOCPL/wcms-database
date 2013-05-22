IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[BestBet_BestBetSynonym_Update]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[BestBet_BestBetSynonym_Update]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].[BestBet_BestBetSynonym_Update]
	@SynonymID uniqueidentifier,
	@SynName varchar(255),
	@IsNegated bit,
	@UpdateUserID varchar(50)
AS
BEGIN
	Declare @CategoryID uniqueidentifier

	Select @CategoryID = CategoryID from BestBetsynonym where SynonymID = @SynonymID

	BEGIN TRY
		UPDATE BestBetsynonym 
		SET SynName = @SynName ,
			IsNegated= @IsNegated,
				UpdateUserID =@UpdateUserID,
				UpdateDate =Getdate()
		WHERE SynonymID = @SynonymID
		
		-- we need to update the category's status
		Update BestBetcategory
		SET 	Status=1,
				UpdateUserID =@UpdateUserID,
				UpdateDate =Getdate()
		WHERE CategoryID = @CategoryID


	END TRY

	BEGIN CATCH
		
			RETURN 124004  
		
	END CATCH 
END


GO
GRANT EXECUTE ON [dbo].[BestBet_BestBetSynonym_Update] TO [websiteuser_role]
GO
