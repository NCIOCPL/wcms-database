IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Workflow_WorkflowItem_Undo]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Workflow_WorkflowItem_Undo]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE [dbo].Workflow_WorkflowItem_Undo
	@workflowItemID uniqueidentifier
	,@Comment varchar(2048) =null
	,@UpdateUserID varchar(50)
AS
BEGIN
	BEGIN TRY
				
		Declare @Status int,
				@Action int
		
		select	@Action =6,	
				@Status = dbo.Core_Function_GetPreviousStatus(@workflowItemID)
          
		INSERT INTO [dbo].[WorkflowItemStatusHistory]
		   ([WorkflowItemID]
		   ,[Action]
		   ,PostActionStatus
		   ,ActionBy
		   ,[Date]
           ,[Comment])
		 VALUES
			(
			 @workflowItemID
			,@Action
			,@Status
			,@UpdateUserID
			,getdate()
			,@Comment
			)
		
		return 0

	END TRY

	BEGIN CATCH
		Print Error_Message()
		RETURN 126006
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[Workflow_WorkflowItem_Undo] TO [websiteuser_role]
GO
