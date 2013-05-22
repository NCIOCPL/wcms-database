IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[WorkFlow_ObjectState_GetPreviousState]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[WorkFlow_ObjectState_GetPreviousState]
GO
Create Function dbo.WorkFlow_ObjectState_GetPreviousState 
/**************************************************************************************************
* Name		: WorkFlow_ObjectState_GetPreviousState
* Purpose	: returns previous state of a given objectid from workflow status table
* Author	: SRamaiah
* Date		: 11/29/2006
* Returns	: previous state (string)
* Usage		: Select dbo.WorkFlow_ObjectState_GetPreviousState('3580F767-7D5D-4446-A944-009DE36BB26B')
* Changes	: 
**************************************************************************************************/
( 
	@objectID uniqueIdentifier
)
returns varchar(100)
as

begin
-- declaration
   declare @retValue varchar(100)
--initialization
	Set @retValue = ''
--execute
	If(Exists(Select * From WorkFlowHistory Where ObjectID = @objectID))
	Begin
		Select top 1 @retValue = State
		From WorkFlowHistory
		Where ObjectID = @objectID
		order by SequenceID desc
	End
	--return previous state
	return @retValue
end

GO
