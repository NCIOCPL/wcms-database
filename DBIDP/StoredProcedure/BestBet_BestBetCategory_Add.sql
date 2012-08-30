IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[BestBet_BestBetCategory_Add]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[BestBet_BestBetCategory_Add]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].[BestBet_BestBetCategory_Add]
	@CatName varchar(255),
	@Weight int,
	@UpdateUserID varchar(50),
	@CategoryID uniqueidentifier OUTPUT
AS
BEGIN
	Declare @ListID uniqueidentifier,
			@rtnVal int,
			@RootNodeID uniqueidentifier

	--Every site should only have 1 root node
	Select @RootNodeID = (select top 1 NodeID from Node where parentNodeID is null)

	if (@RootNodeID is null)
		return 124090  --no parent node

	BEGIN TRY

		-- Create List
		exec @rtnVal = [dbo].Core_Object_Add
			@objectTypeID = 1 --List Object Type
			,@OwnerID = @RootNodeID
			,@IsShared  = 0
			,@IsVirtual = 0
			,@Title = @CatName
			,@UpdateUserID = @UpdateUserID
			,@ObjectID = @ListID output

		if (@rtnVal >0)
				return @rtnVal

		-- create a list 
		exec @rtnVal = dbo.List_List_Add
			@ListID = @ListID
			, @Title = @CatName
			, @Description =  ''
			, @ShowLinkDescriptions =0
			, @ShowShortTitle  = 0
			, @CreateUserID = @UpdateUserID

		if (@rtnVal >0)
				return @rtnVal

		Set @CategoryID = newid()
		
		INSERT INTO BestBetCategory
		(CategoryID, CatName, ListID, Weight, status, UpdateUserID, UpdateDate, CreateUserID) 
		VALUES 
		(@CategoryID, @CatName, @ListID, @Weight, 1, @UpdateUserID, Getdate(), @UpdateUserID )

		RETURN 0

	END TRY
	BEGIN CATCH		
			RETURN 124003  -- BestBet_BestBetCategory_Add		
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[BestBet_BestBetCategory_Add] TO [websiteuser_role]
GO
