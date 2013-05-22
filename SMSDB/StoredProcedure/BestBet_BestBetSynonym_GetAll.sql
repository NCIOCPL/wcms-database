IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[BestBet_BestBetSynonym_GetAll]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[BestBet_BestBetSynonym_GetAll]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].[BestBet_BestBetSynonym_GetAll]
	@categoryID uniqueidentifier
AS
BEGIN

	BEGIN TRY
		Select * from BestBetsynonym 
		WHERE categoryID = @categoryID
		ORder by SynName

	END TRY

	BEGIN CATCH
		
			RETURN 124002  
		
	END CATCH 
END



GO
GRANT EXECUTE ON [dbo].[BestBet_BestBetSynonym_GetAll] TO [websiteuser_role]
GO
