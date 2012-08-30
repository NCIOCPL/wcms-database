IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Workflow_WorkflowItem_GetAll]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Workflow_WorkflowItem_GetAll]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].Workflow_WorkflowItem_GetAll
	@UserID uniqueidentifier,
	@IsAdmin bit,
	@Status int =0
AS
BEGIN
	BEGIN TRY
		--check user permission and return the node he has permission		
		if (@IsAdmin =1) --admin
		Begin
			if (@Status =0)
			BEGIN
				SELECT W.[WorkflowItemID]
					  ,W.URL
					  ,W.Title
					  ,H.Comment
					  ,H.PostActionStatus
					  ,H.[Action]
					  ,H.ActionBy 
					  ,H.Date
				  FROM [dbo].[WorkflowItem] W, dbo.WorkflowItemStatusHistory H
				Where H.[WorkflowItemID]= W.[WorkflowItemID] and H.Date= DBO.Core_Function_GetCurrentDate(W.[WorkflowItemID])
				order by H.Date Desc
			END
			ELSE
			BEGIN
				SELECT W.[WorkflowItemID]
					  ,W.URL
					  ,W.Title
					  ,H.Comment
					  ,H.PostActionStatus
					  ,H.[Action]
					  ,H.ActionBy 
					  ,H.Date
				  FROM [dbo].[WorkflowItem] W, dbo.WorkflowItemStatusHistory H
				Where H.[WorkflowItemID]= W.[WorkflowItemID] and H.Date= DBO.Core_Function_GetCurrentDate(W.[WorkflowItemID])
						and (H.PostActionStatus & @Status )>0
				order by H.Date Desc
			END
		END
		ELSE
		BEGIN
			if (@Status =0)
			BEGIN
				SELECT W.[WorkflowItemID]
					  ,W.URL
					  ,W.Title
					  ,H.Comment
					  ,H.PostActionStatus
					  ,H.[Action]
					  ,H.ActionBy 
					  ,H.Date
				  FROM [dbo].[WorkflowItem] W, dbo.WorkflowItemStatusHistory H, [dbo].Core_Function_GetUserNode(@UserID) N
				Where H.[WorkflowItemID]= W.[WorkflowItemID] and H.Date= DBO.Core_Function_GetCurrentDate(W.[WorkflowItemID])
					and W.[WorkflowItemID] = N.NodeID
				order by H.Date Desc
			END
			ELSE
			BEGIN
				SELECT W.[WorkflowItemID]
					  ,W.URL
					  ,W.Title
					  ,H.Comment
					  ,H.PostActionStatus
					  ,H.[Action]
					  ,H.ActionBy 
					  ,H.Date
				  FROM [dbo].[WorkflowItem] W, dbo.WorkflowItemStatusHistory H, [dbo].Core_Function_GetUserNode(@UserID) N
				Where H.[WorkflowItemID]= W.[WorkflowItemID] and H.Date= DBO.Core_Function_GetCurrentDate(W.[WorkflowItemID])
					and W.[WorkflowItemID] = N.NodeID	and (H.PostActionStatus & @Status )>0
				order by H.Date Desc
			END
		END

	END TRY

	BEGIN CATCH
		
			RETURN 126002  
		
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[Workflow_WorkflowItem_GetAll] TO [websiteuser_role]
GO
