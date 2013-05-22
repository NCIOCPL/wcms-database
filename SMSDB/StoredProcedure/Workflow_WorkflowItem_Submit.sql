IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Workflow_WorkflowItem_Submit]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Workflow_WorkflowItem_Submit]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE [dbo].Workflow_WorkflowItem_Submit
	 @workflowItemID uniqueidentifier
	,@Purpose int
	,@Comment varchar(2048)
	,@UpdateUserID varchar(50)
AS
BEGIN
	BEGIN TRY

		Declare 
				@Status int,
				@Action int
		
		select	@Action =2

		if (@Purpose =1) --approval
		BEGIN
			select	@Status = 2
		END
		ELSE  -- deletion
		BEGIN
			select	@Status = 4
		END
	
		INSERT INTO [dbo].[WorkflowItemStatusHistory]
           ([WorkflowItemID]
           ,[Action]
           ,[ActionBy]
           ,[Date]
           ,[PostActionStatus]
			,Comment)
		 VALUES
			(
			 @workflowItemID
			,@Action --submit
			,@UpdateUserID
			,getdate()
			,@Status
			,@Comment
			)

		return 0

	END TRY

	BEGIN CATCH
		Print Error_Message()
		RETURN 126003
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[Workflow_WorkflowItem_Submit] TO [websiteuser_role]
GO
