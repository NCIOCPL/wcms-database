IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[BestBet_BestBetCategory_GetAll]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[BestBet_BestBetCategory_GetAll]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[BestBet_BestBetCategory_GetAll]
AS
BEGIN
	BEGIN TRY

		
		Select [CategoryID]
      ,[CatName]
      ,[ListID]
      ,[Status]
      ,[Weight]
	  ,OwnerID = (select top 1 NodeID from Node where parentNodeID is null)
      ,[CreateUserID]
      ,[CreateDate]
      ,[UpdateUserID]
      ,[UpdateDate]
		from BestBetcategory
		Order by CatName
		
	END TRY

	BEGIN CATCH
		
			RETURN 123002  
		
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[BestBet_BestBetCategory_GetAll] TO [websiteuser_role]
GO
