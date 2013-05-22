IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[BestBet_BestBetSynonym_Get]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[BestBet_BestBetSynonym_Get]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].[BestBet_BestBetSynonym_Get]
	@SynonymID uniqueidentifier
AS
BEGIN

	BEGIN TRY
		Select * from BestBetsynonym 
		WHERE SynonymID = @SynonymID
		

	END TRY

	BEGIN CATCH
		
			RETURN 124001  
		
	END CATCH 
END


GO
GRANT EXECUTE ON [dbo].[BestBet_BestBetSynonym_Get] TO [websiteuser_role]
GO
