IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[WorkFlow_ObjectState_Update]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[WorkFlow_ObjectState_Update]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE  PROCEDURE  [dbo].[WorkFlow_ObjectState_Update]
/**************************************************************************************************
* Name		: WorkFlow_ObjectState_Update
* Purpose	: used to add/update a record in WorkFlowStatus table
* Author	: SRamaiah
* Date		: 11/27/2006
* Returns	: 0/30102
* Usage		: Exec WorkFlow_ObjectState_Update '76cff7b2-afbd-4943-bb89-61833218f71d', 'Submit', 'Submitted', 0, 'Notes-Submitted', '5188146770731162715' 
* Changes	: 
**************************************************************************************************/
( 
	@objectID uniqueidentifier
	, @transitionName varchar(255)
	, @state varchar(100)
	, @isPublished bit
	, @notes varchar(MAX)
	, @updateUserID uniqueidentifier
)
AS
BEGIN
  --Declaration
  --Initialization
  --Execute
	BEGIN TRY
		set nocount on;
		If(Not Exists(Select * From WorkFlowStatus Where ObjectID = @objectID))
		Begin
			--add a new record into WorkFlowStatus table
			Insert Into WorkFlowStatus(
				  ObjectID
				, TransitionName
				, State
				, IsPublished
				, Notes
				, UpdateUserID
				, UpdateDate
			)
			Values(
				  @objectID
				, @transitionName
				, @state
				, @isPublished
				, @notes
				, @updateUserID
				, getdate()
			)
		
		End
		Else
		Begin
			--save previous status in the workflow history table 			
			Insert Into WorkFlowHistory(
				  ObjectID
				, SequenceID
				, TransitionName			
				, State
				, IsPublished
				, Notes
				, UpdateUserID
				, UpdateDate
			)
			Select 
				  ObjectID
				, dbo.WorkFlow_History_GetNextSequenceID(@objectID)
				, transitionName
				, state
				, isPublished
				, notes
				, updateUserID
				, getdate()
			From WorkFlowStatus
			Where ObjectID = @objectID
		
			--update workflow status table with current status
			Update WorkFlowStatus
			Set
				  TransitionName = @transitionName
				, State = @state
				, IsPublished = @isPublished
				, Notes = @notes
				, UpdateUserID = @updateUserID
				, UpdateDate = getdate()
			Where 
				ObjectID = @objectID
		End				
	END TRY
	BEGIN CATCH 
		--Return Error Number
		print error_message()
		return 30102
	END CATCH	  	  	  
END

GO
GRANT EXECUTE ON [dbo].[WorkFlow_ObjectState_Update] TO [websiteuser_role]
GO
