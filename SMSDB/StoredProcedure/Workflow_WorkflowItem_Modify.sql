IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Workflow_WorkflowItem_Modify]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Workflow_WorkflowItem_Modify]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE [dbo].Workflow_WorkflowItem_Modify
	 @workflowItemID uniqueidentifier
	,@UpdateUserID varchar(50)
AS
BEGIN
	BEGIN TRY

		Declare 
				@Status int,
				@Action int
		
		select	@Action =8, @Status =1

		--if (not exists (select 1 from [WorkflowItemStatusHistory]
		--	where PostActionStatus =1 
		--	and Date = DBO.Core_Function_GetCurrentDate(@workflowItemID)))
		BEGIN
			INSERT INTO [dbo].[WorkflowItemStatusHistory]
			   ([WorkflowItemID]
			   ,[Action]
			   ,[ActionBy]
			   ,[Date]
			   ,[PostActionStatus]
			)
			 VALUES
				(
				 @workflowItemID
				,@Action 
				,@UpdateUserID
				,getdate()
				,@Status
				)
		END

		return 0

	END TRY

	BEGIN CATCH
		Print Error_Message()
		RETURN 126010
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[Workflow_WorkflowItem_Modify] TO [websiteuser_role]
GO
