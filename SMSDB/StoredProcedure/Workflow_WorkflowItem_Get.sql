IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Workflow_WorkflowItem_Get]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Workflow_WorkflowItem_Get]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE [dbo].Workflow_WorkflowItem_Get
	@WorkflowItemID uniqueidentifier
AS
BEGIN
	BEGIN TRY
		Select w.WorkflowItemID, 
				P.PrettyURL as URL, 
				Title
			  ,H.ActionBy
			  ,H.Date
			  ,H.[Action]
			  ,H.Comment
			,PostActionStatus
		from [dbo].[WorkflowItem] w
			join dbo.PrettyUrl P on w.WorkflowItemID = P.NodeID and P.IsPrimary=1
		join dbo.WorkflowItemStatusHistory H
			ON w.WorkflowItemID = H.WorkflowItemID
		Where w.WorkflowItemID = @WorkflowItemID and H.Date= DBO.Core_Function_GetCurrentDate(@WorkflowItemID)

		SELECT [WorkflowItemID]
			  ,Date
			  ,PostActionStatus 
			  ,[Action]
			  ,ActionBy 
			  ,Comment
		  FROM dbo.WorkflowItemStatusHistory 
		Where [WorkflowItemID]= @WorkflowItemID
		order by Date Desc
		
	END TRY

	BEGIN CATCH
		RETURN 126001
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[Workflow_WorkflowItem_Get] TO [websiteuser_role]
GO
