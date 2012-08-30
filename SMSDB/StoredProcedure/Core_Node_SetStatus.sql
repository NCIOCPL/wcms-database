IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_Node_SetStatus]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_Node_SetStatus]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE [dbo].Core_Node_SetStatus
	@NodeID uniqueidentifier, 
	@UserName varchar(50)
AS
BEGIN
	
	BEGIN TRY
		Declare @rtnValue int

		exec @rtnValue = [dbo].Workflow_WorkflowItem_Modify
			 @workflowItemID = @NodeID
			,@UpdateUserID = @UserName
		
		if (@rtnValue <>0)
			return @rtnValue

		return 0		
	END TRY

	BEGIN CATCH
		Print Error_Message()
		RETURN 12010
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[Core_Node_SetStatus] TO [websiteuser_role]
GO
