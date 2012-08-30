IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Workflow_WorkflowItem_Approve]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Workflow_WorkflowItem_Approve]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE [dbo].Workflow_WorkflowItem_Approve
	@workflowItemID uniqueidentifier
	,@Comment varchar(2048) 
	,@UpdateUserID varchar(50)
AS
BEGIN
	BEGIN TRY
		
		Declare @Status int,
				@Action int
		
		select @Status= 8, -- live       
				@Action =3	

		INSERT INTO [dbo].[WorkflowItemStatusHistory]
           ([WorkflowItemID]
           ,[Action]
		   ,PostActionStatus
           ,[ActionBy]
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
		RETURN 126009
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[Workflow_WorkflowItem_Approve] TO [websiteuser_role]
GO
