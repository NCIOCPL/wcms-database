IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_Function_GetCurrentDate]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[Core_Function_GetCurrentDate]
GO

create function DBO.Core_Function_GetCurrentDate (
	@WorkflowItemID uniqueIdentifier
)
returns DateTime
as 

BEGIN
	Declare @returnvalue DateTime
	
	select @returnvalue = max(Date) from dbo.WorkflowItemStatusHistory
	Where WorkflowItemID = @WorkflowItemID

	return @returnvalue
END

GO
