IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[BestBet_BestBetSynonym_Delete]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[BestBet_BestBetSynonym_Delete]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].[BestBet_BestBetSynonym_Delete]
	@SynonymID uniqueidentifier,
	@UpdateUserID varchar(50)
AS
BEGIN
	Declare @CategoryID uniqueidentifier

	Select @CategoryID = CategoryID from BestBetsynonym where SynonymID = @SynonymID

	BEGIN TRY
		Delete from BestBetsynonym 
		WHERE SynonymID = @SynonymID
		
		-- we need to update the category's status
		Update BestBetcategory
		SET 	status =1,
				UpdateUserID =@UpdateUserID,
				UpdateDate =Getdate()
		WHERE CategoryID = @CategoryID


	END TRY

	BEGIN CATCH
		
			RETURN 124005  
		
	END CATCH 
END


GO
GRANT EXECUTE ON [dbo].[BestBet_BestBetSynonym_Delete] TO [websiteuser_role]
GO
