IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Workflow_WorkflowItem_GetStatus]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Workflow_WorkflowItem_GetStatus]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE [dbo].Workflow_WorkflowItem_GetStatus
	@WorkflowItemID uniqueidentifier
AS
BEGIN
	BEGIN TRY
	
	declare @d datetime
	select @d = DBO.Core_Function_GetCurrentDate(@WorkflowItemID)  

	
		Select PostActionStatus
		from [dbo].[WorkflowItem] w
		join dbo.WorkflowItemStatusHistory H
			ON w.WorkflowItemID = H.WorkflowItemID
		Where w.WorkflowItemID = @WorkflowItemID and H.Date= @d
		
	END TRY

	BEGIN CATCH
		RETURN 126001
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[Workflow_WorkflowItem_GetStatus] TO [websiteuser_role]
GO
