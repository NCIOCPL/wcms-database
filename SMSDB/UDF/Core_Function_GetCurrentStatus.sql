IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_Function_GetCurrentStatus]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[Core_Function_GetCurrentStatus]
GO
Create Function dbo.Core_Function_GetCurrentStatus 
/**************************************************************************************************
* Name		: Core_Function_GetCurrentStatus
* Purpose	: 
* Author	: SRamaiah
* Date		: 10/26/2006
* Returns	: status (int)
* Usage		: Select dbo.Core_Function_GetCurrentStatus('B978C513-9809-4B0F-AB9B-17BBB46F7C2E')
			  Select dbo.Core_Function_GetPreviousStatus('B978C513-9809-4B0F-AB9B-17BBB46F7C2E')
* Changes	: 
**************************************************************************************************/
( 
	@WorkflowItemID uniqueIdentifier
)
returns int
as

begin
-- declaration
   declare @retValue int		
--initialization
--execute
	select @retValue =  PostActionStatus
	From dbo.WorkflowItemStatusHistory 
	where WorkflowItemID = @WorkflowItemID 
	and Date =
	(
		select top 1 with ties Date 
		from dbo.WorkflowItemStatusHistory
		Where WorkflowItemID = @WorkflowItemID
		order by Date desc
	) 
	return @retValue
end

GO
