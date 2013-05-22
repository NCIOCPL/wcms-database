IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[WorkFlow_History_GetNextSequenceID]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[WorkFlow_History_GetNextSequenceID]
GO
Create Function dbo.WorkFlow_History_GetNextSequenceID 
/**************************************************************************************************
* Name		: WorkFlow_History_GetNextSequenceID
* Purpose	: returns next sequence id for a given objectid from workflow history table
* Author	: SRamaiah
* Date		: 11/27/2006
* Returns	: next seq id (int)
* Usage		: Select dbo.WorkFlow_History_GetNextSequenceID('76cff7b2-afbd-4943-bb89-61833218f71d')
* Changes	: 
**************************************************************************************************/
( 
	@objectID uniqueIdentifier
)
returns int
as

begin
-- declaration
   declare @retValue int		
--initialization
	Set @retValue = 0
--execute
	If(Exists(Select * From WorkFlowHistory Where ObjectID = @objectID))
	Begin
		Select @retValue = Max(SequenceID)
		From WorkFlowHistory
		Where ObjectID = @objectID
	End
	--return next id
	return @retValue + 1
end

GO
