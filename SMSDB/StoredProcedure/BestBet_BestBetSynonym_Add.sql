IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[BestBet_BestBetSynonym_Add]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[BestBet_BestBetSynonym_Add]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].[BestBet_BestBetSynonym_Add]
	@SynName varchar(255),
	@CategoryID uniqueidentifier,
	@IsNegated bit,
	@UpdateUserID varchar(50)
AS
BEGIN
	
	BEGIN TRY
		INSERT INTO BestBetsynonym
		(SynonymID, CategoryID, SynName, IsNegated, CreateUserID, updateUserID) 
		VALUES 
		(newid(), @CategoryID, @SynName, @IsNegated,@UpdateUserID ,@UpdateUserID);

		-- we need to update the category's status
		Update BestBetcategory
		SET 	UpdateUserID =@UpdateUserID,
				UpdateDate =Getdate()
		WHERE CategoryID = @CategoryID

	END TRY

	BEGIN CATCH
		
			RETURN 124003  -- BestBet_BestBetSynonym_Add
		
	END CATCH 
END


GO
GRANT EXECUTE ON [dbo].[BestBet_BestBetSynonym_Add] TO [websiteuser_role]
GO
