IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Workflow_WorkflowItem_Create]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Workflow_WorkflowItem_Create]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE [dbo].Workflow_WorkflowItem_Create
	@workflowItemID uniqueidentifier
	,@UpdateUserID varchar(50)
AS
BEGIN
	BEGIN TRY
		Declare @URL varchar(512),
				@Title varchar(255),
				@Status int,
				@Action int
	

		select @URL = prettyURL  from dbo.PrettyUrl
		Where NodeID = @workflowItemID and IsPrimary =1

		select @Title = Title from dbo.Node
		Where NodeID = @workflowItemID 
	
		INSERT INTO [dbo].[WorkflowItem]
           ([WorkflowItemID]
           ,Title
           ,[URL])
		 VALUES
			(@workflowItemID
			,@Title
			,@URL
			)

		
		select	@Action =1,	
				@Status = 1
          
		INSERT INTO [dbo].[WorkflowItemStatusHistory]
		   ([WorkflowItemID]
		   ,[Action]
		   ,PostActionStatus
		   ,ActionBy
		   ,[Date]
		   )
		 VALUES
			(
			 @workflowItemID
			,@Action
			,@Status
			,@UpdateUserID
			,getdate()
			)
		
		return 0

	END TRY

	BEGIN CATCH
		Print Error_Message()
		RETURN 126006
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[Workflow_WorkflowItem_Create] TO [websiteuser_role]
GO
