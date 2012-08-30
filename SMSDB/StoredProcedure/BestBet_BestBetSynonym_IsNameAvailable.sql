IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[BestBet_BestBetSynonym_IsNameAvailable]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[BestBet_BestBetSynonym_IsNameAvailable]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************
* Purpose:	Check to see if a Best Bet's synonym name is available. 
*	A best bet synonym is available if a Category does not already
*   have a synonym with the same name.
* Author:	BryanP
* Date:		12/04/07
* Params: 
*	
********************************************************/
CREATE PROCEDURE [dbo].[BestBet_BestBetSynonym_IsNameAvailable] 
(
	@CatID uniqueidentifier,
	@SynID uniqueidentifier,
	@Name varchar(255),
	@IsAvailable bit output
)
AS
BEGIN
	SET @IsAvailable = 1
	IF (EXISTS(SELECT SynName FROM BestBetSynonym WHERE CategoryID = @CatID AND SynonymID != @SynID AND SynName = @Name) OR EXISTS(SELECT CatName FROM BestBetCategory WHERE CategoryID = @CatID AND CatName = @Name))	
		SET @IsAvailable = 0

END

GO
GRANT EXECUTE ON [dbo].[BestBet_BestBetSynonym_IsNameAvailable] TO [websiteuser_role]
GO
