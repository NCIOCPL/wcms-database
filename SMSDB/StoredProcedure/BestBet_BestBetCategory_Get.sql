IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[BestBet_BestBetCategory_Get]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[BestBet_BestBetCategory_Get]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].[BestBet_BestBetCategory_Get]
	@CategoryID uniqueidentifier
AS
BEGIN
	BEGIN TRY

		Select [CategoryID]
      ,[CatName]
	  ,OwnerID = (select top 1 NodeID from Node where parentNodeID is null)
      ,ListID
      ,[Status]
      ,[Weight]
      ,[CreateUserID]
      ,[CreateDate]
      ,[UpdateUserID]
      ,[UpdateDate]
		from BestBetcategory
		WHERE CategoryID = @CategoryID


		SELECT [SynonymID]
      ,[CategoryID]
      ,[SynName]
      ,[IsNegated]
      ,[CreateUserID]
      ,[CreateDate]
      ,[UpdateUserID]
      ,[UpdateDate]
  FROM [dbo].[BestBetSynonym]
		WHERE CategoryID = @CategoryID
	
	
	END TRY

	BEGIN CATCH
		
			RETURN 123001  
		
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[BestBet_BestBetCategory_Get] TO [websiteuser_role]
GO
