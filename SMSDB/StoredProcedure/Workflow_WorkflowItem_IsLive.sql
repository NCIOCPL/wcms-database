IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Workflow_WorkflowItem_IsLive]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Workflow_WorkflowItem_IsLive]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE [dbo].Workflow_WorkflowItem_IsLive
	@WorkflowItemID uniqueidentifier
AS
BEGIN
	BEGIN TRY
		select count(*) 		
		from dbo.WorkflowItemStatusHistory
		Where WorkflowItemID = @WorkflowItemID  
			and PostActionStatus =8
		
	END TRY

	BEGIN CATCH
		RETURN 126001
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[Workflow_WorkflowItem_IsLive] TO [websiteuser_role]
GO
