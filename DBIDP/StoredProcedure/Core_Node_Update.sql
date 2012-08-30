IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_Node_Update]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_Node_Update]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE [dbo].Core_Node_Update
	@NodeID uniqueidentifier output
	,@layoutTemplateID uniqueidentifier = null
	,@contentAreaTemplateID uniqueidentifier = null
	,@Title		varchar(255)
    ,@ShortTitle varchar(50)
    ,@Description varchar(1500)
	,@showInNavigation	bit
	,@showInBreadCrumbs	bit
	,@UpdateUserID varchar(50)
	,@DisplayPostedDate datetime = '1/1/1980',
			@DisplayUpdateDate datetime = '1/1/1980',
			@DisplayReviewDate datetime = '1/1/1980',
			@DisplayExpirationDate datetime = '1/1/2100',
			@DisplayDateMode tinyint = 1
AS
BEGIN
	Declare @OldTitle varchar(255)

	select @OldTitle = Title from  [dbo].[Node]  
		 WHERE [NodeID] = @NodeID

	BEGIN TRY

		if (@OldTitle <>  @Title)
		BEGIN
			Update dbo.WorkflowItem
			Set Title = @Title
			WHERE WorkflowItemID = @NodeID
		END


		UPDATE [dbo].[Node]
		   SET [Title] =@Title
			  ,[ShortTitle] =@ShortTitle
			  ,[Description] = @Description
			  ,[ShowInNavigation] = @showInNavigation
			  ,[ShowInBreadCrumbs] = @showInBreadCrumbs
			  ,[status] = 1
			  ,[UpdateUserID] = @UpdateUserID
			  ,[UpdateDate] = getdate()
			,DisplayPostedDate = @DisplayPostedDate ,
			DisplayUpdateDate = @DisplayUpdateDate ,
			DisplayReviewDate = @DisplayReviewDate ,
			DisplayExpirationDate =@DisplayExpirationDate ,
			DisplayDateMode = @DisplayDateMode 
			
		 WHERE [NodeID] = @NodeID

		-- TodO: rebuild layoutdefinition
			Update	dbo.LayoutDefinition
			Set LayoutTemplateID = @layoutTemplateID
				,ContentAreaTemplateID = @contentAreaTemplateID
			  ,[UpdateUserID] = @UpdateUserID
			  ,[UpdateDate] = getdate()
		 WHERE [NodeID] = @NodeID

	END TRY

	BEGIN CATCH
		RETURN 12004
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[Core_Node_Update] TO [websiteuser_role]
GO
