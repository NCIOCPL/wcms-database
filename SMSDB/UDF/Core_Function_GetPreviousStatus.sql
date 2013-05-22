IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_Function_GetPreviousStatus]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[Core_Function_GetPreviousStatus]
GO

create function DBO.Core_Function_GetPreviousStatus (
	@WorkflowItemID uniqueIdentifier
)
returns int
as 

BEGIN
	Declare @returnvalue int
	
	select @returnvalue =  PostActionStatus
	From dbo.WorkflowItemStatusHistory where WorkflowItemID = @WorkflowItemID and Date in
	(
		select top 1 with ties  Date from 
		(select top 2 with ties Date from dbo.WorkflowItemStatusHistory
			Where WorkflowItemID = @WorkflowItemID
			order by Date desc) sub
		order by Date asc
	) 

	return @returnvalue
END

GO
