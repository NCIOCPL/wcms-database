IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_submitMacroForDeleteApproval]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_submitMacroForDeleteApproval]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



--***********************************************************************
-- Create New Object 
--************************************************************************
/*
**  This procedure will Create a Task and steps needed to perform a 
**    Deletion of a macro from the System
**
**
**  Issues:  
**
**  Author: Jay He 04/04/2003
**  Revision History:
****  02-11-2003 Jay He Revised for adding submission bestbets for deletion/approval  -- Have a hard coded group id 5 for best bets
**
**
**  Return Values
**  0         Success
**  70001     The guid argument was invalid
**  70004     Failed during execution of deletion
**  70005     Denotes the switch of task to executing status
**
*/
CREATE PROCEDURE [dbo].[usp_submitMacroForDeleteApproval] 
	(
	@MacroID 		uniqueidentifier,   -- Note this is the guid for NCIView to be approved
	@GroupID 		int,
	@UpdateUserID 	varchar(50),  -- This should be the username as it appears in NCIUsers table
	@AdminURL		varchar(50)
	)
AS
BEGIN	
	SET NOCOUNT ON

	/*
	** STEP - A
	** First Validate that the guid provided is valid
	** if not return a 70001 error
	*/		

	if(	
		  (@MacroID IS NULL) OR (NOT EXISTS (SELECT MacroName  FROM TSMacros WHERE MacroID= @MacroID)) 
	  )	
	BEGIN
		RAISERROR ( 70001, 16, 1)
		RETURN 70001
	END
	
	DECLARE @TaskID uniqueidentifier,
		@StepID uniqueidentifier,
		@ShortName	varchar(50), 
		@viewStatus char(10)
		
	select @TaskID = newid()

	select @ShortName = left(MacroName,50), @viewStatus=status  from TSMacros where MacroID = @MacroID

	BEGIN TRAN Tran_SubmitViewDelete

	/*
	** STEP - B
	** Set the status of the view to 'DelSubmit'.  This will
	** allow us to lock the content down until an approval or
	** dissaproval has been done on the content.
	*/	
	update TSMacros 
	set Status = 'DelSubmit',
	    UpdateUserID = @UpdateUserID,
	    UpdateDate = getdate()
	where MacroID = @MacroID
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_SubmitViewDelete
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END
	
	/*
	** STEP - C
	** Now we need to submit the task and Step for this action
	*/
	insert into Task
	(TaskID, ResponsibleGroupID, Name, UpdateDate, UpdateUserID, ObjectID, status)
	values
	(@TaskID, @GroupID, 'Deletion of ' +  @ShortName, getdate(), @UpdateUserID, @MacroID, 'Executing')
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_SubmitViewDelete
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 
	
	/*
	** Add a notification and Authorization step for delete of the page 
	** First
	*/
	select @StepID = newid()
	/*
	** Insert the First step which is a step used to notify the members of the group about the task
	** that needs to be worked on
	*/	
	insert into TaskStep
	(StepID, TaskID, ResponsibleGroupID, Name, OrderLevel, AprvStoredProcedure, DisAprvStoredProcedure, 
	OnErrorStoredProcedure, IsAuto, UpdateDate, UpdateUserID, status)
	values
	(@StepID, @TaskID, @GroupID, 'Notify', '1', 'usp_SendMessage', 
	null, 'usp_StepFailedStop', '1', getdate(), @UpdateUserID, 'Ready')
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_SubmitViewDelete
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END
	/*
	** Insert all the script arguments now, Tell the groupID, the permissions 
	** to send to, and the Message
	*/
	insert into TaskStepArgument
	(StepID, ArgumentOrdinal, ForProcedureX, ArgumentValue)
	values
	(@StepID, '1', '1', @GroupID)
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_SubmitViewDelete
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END
		
	insert into TaskStepArgument
	(StepID, ArgumentOrdinal, ForProcedureX, ArgumentValue)
	values
	(@StepID, '2', '1', '6')
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_SubmitViewDelete
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END	
	
	insert into TaskStepArgument
	(StepID, ArgumentOrdinal, ForProcedureX, ArgumentValue)
	values
	(@StepID, '3', '1', 'Page Deletion needs approval')	
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_SubmitViewDelete
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END	
	
	insert into TaskStepArgument
	(StepID, ArgumentOrdinal, ForProcedureX, ArgumentValue)
	values
	(@StepID, '4', '1', 'The Macro <a href=' + @AdminURL +'/Topic/EditTopicMacro.aspx?MacroID=' + Convert(varchar(36), @MacroID) + 
	'>' +  @ShortName + '</a> has been submitted for deletion, and awaits your approval. ' +
	'<a href="'+ @AdminURL +'/Page/PagePreview.aspx?TaskID=' + cast(@TaskID as varchar(40)) + '"> Go there now. </a>')
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_SubmitViewDelete
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END
	
	insert into TaskStepArgument
	(StepID, ArgumentOrdinal, ForProcedureX, ArgumentValue)
	values
	(@StepID, '5', '1', @UpdateUserID)
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_SubmitViewDelete
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END	
	
	/*
	** Insert the args for the failure script, It will not
	** do any notification, but needs to change the Task 
	** status so TaskID is setup as an argument.
	*/
	insert into TaskStepArgument
	(StepID, ArgumentOrdinal, ForProcedureX, ArgumentValue)
	values
	(@StepID, '1', '3', cast(@TaskID as varchar(40)))
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_SubmitViewDelete
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END	
	
	
	select @StepID = newid()
	
	insert into TaskStep
	(StepID, TaskID, ResponsibleGroupID, Name, Status, OrderLevel, AprvStoredProcedure, DisAprvStoredProcedure, 
	OnErrorStoredProcedure, IsAuto, UpdateDate, UpdateUserID, description)
	values
	(@StepID, @TaskID, @GroupID, 'Approve Deletion', 'Pending', '2', 'usp_doNothing', 
	'usp_disApproveMacroDelete', 'usp_StepFailedNotifyStop', '0', getdate(), @UpdateUserID, 
	'The Macro <a href=' + @AdminURL +'/Topic/EditTopicMacro.aspx?MacroID=' + Convert(varchar(36), @MacroID) + 
	'>' +  @ShortName + + + '</a> has been submitted for deletion, and awaits your approval.' + 
		'Note: This is just an approval for work to be performed later.')
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_SubmitViewDelete
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 
	
	/*
	** Insert all the script arguments now for DisApproval
	*/	
	insert into TaskStepArgument
	(StepID, ArgumentOrdinal, ForProcedureX, ArgumentValue)
	values
	(@StepID, '1', '2', cast(@MacroID as varchar(40)))
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_SubmitViewDelete
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END
	
	insert into TaskStepArgument
	(StepID, ArgumentOrdinal, ForProcedureX, ArgumentValue)
	values
	(@StepID, '2', '2', @viewStatus)
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_SubmitViewDelete
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END
	
	insert into TaskStepArgument
	(StepID, ArgumentOrdinal, ForProcedureX, ArgumentValue)
	values
	(@StepID, '3', '2', cast(@TaskID as varchar(40)))
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_SubmitViewDelete
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END
		
	insert into TaskStepArgument
	(StepID, ArgumentOrdinal, ForProcedureX, ArgumentValue)
	values
	(@StepID, '4', '2', cast(@StepID as varchar(40)))
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_SubmitViewDelete
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END	

	/*
	** Needs to Notify the submitter about dis-approval
	*/
	insert into TaskStepArgument
	(StepID, ArgumentOrdinal, ForProcedureX, ArgumentValue)
	values
	(@StepID, '5', '2', @UpdateUserID)
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_SubmitViewDelete
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END
	
	/*
	** Insert the args for the failure script, It will update 
	** Task Status and Notify respective people.
	*/
	insert into TaskStepArgument
	(StepID, ArgumentOrdinal, ForProcedureX, ArgumentValue)
	values
	(@StepID, '1', '3', cast(@TaskID as varchar(40)))
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_SubmitViewDelete
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END
	
	/* Only need group because we want to notify all members of group */
	insert into TaskStepArgument
	(StepID, ArgumentOrdinal, ForProcedureX, ArgumentValue)
	values
	(@StepID, '2', '3', @GroupID)
	IF (@@ERROR <> 0)

	BEGIN
		ROLLBACK TRAN Tran_SubmitViewDelete
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END
	
	insert into TaskStepArgument
	(StepID, ArgumentOrdinal, ForProcedureX, ArgumentValue)
	values
	(@StepID, '3', '3', 'The Macro <a href='+ @AdminURL +'/Topic/EditTopicMacro.aspx?MacroID=' + Convert(varchar(36), @MacroID) + 
	'>' +  @ShortName + '</a> failed during deletion processing')
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_SubmitViewDelete
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END	
	
		
	/*
	** Now that we are Done with the preliminaries, we can set up the steps
	** to delete view and Notify/close task.
	*/
			
	select @StepID = newid()
	/*
	** Insert the step used to delete the view
	*/	
	
	insert into TaskStep
	(StepID, TaskID, ResponsibleGroupID, Name, Status, OrderLevel, AprvStoredProcedure, DisAprvStoredProcedure, 
	OnErrorStoredProcedure, IsAuto, UpdateDate, UpdateUserID)
	values
	(@StepID, @TaskID, @GroupID, 'Delete Content', 'Pending', '5', 'usp_deleteMacro', 
	null, 'usp_StepFailedNotifyStop', '1', getdate(), @UpdateUserID)
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_SubmitViewDelete
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 
	
	/*
	** Insert all the script arguments now for Approval
	*/
	insert into TaskStepArgument
	(StepID, ArgumentOrdinal, ForProcedureX, ArgumentValue)
	values
	(@StepID, '1', '1', cast(@MacroID as varchar(40)))
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_SubmitViewDelete
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END
		
	/*
	** Insert all the script arguments now for DisApproval
	*/	
		
	/*
	** Insert the args for the failure script, It will update 
	** Task Status and Notify respective people.
	*/
	insert into TaskStepArgument
	(StepID, ArgumentOrdinal, ForProcedureX, ArgumentValue)
	values
	(@StepID, '1', '3', cast(@TaskID as varchar(40)))
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_SubmitViewDelete
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END
	
	/* Only need group because we want to notify all members of group */
	insert into TaskStepArgument
	(StepID, ArgumentOrdinal, ForProcedureX, ArgumentValue)
	values
	(@StepID, '2', '3', @GroupID)
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_SubmitViewDelete
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END
			
	insert into TaskStepArgument
	(StepID, ArgumentOrdinal, ForProcedureX, ArgumentValue)
	values
	(@StepID, '3', '3', 'The <a href='+ @AdminURL +'/topic/EditTopicMacro.aspx?MacroID=' + Convert(varchar(36), @MacroID) + 
	'>' +  @ShortName  + '</a> failed during deletion processing')
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_SubmitViewDelete
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END
			
	select @StepID = newid()
	/*
	** Insert the Last Step That will Announce the Task complete and close
	** out the task
	*/	
	insert into TaskStep
	(StepID, TaskID, ResponsibleGroupID, Name, Status, OrderLevel, AprvStoredProcedure, DisAprvStoredProcedure, 
	OnErrorStoredProcedure, IsAuto, UpdateDate, UpdateUserID)
	values
	(@StepID, @TaskID, @GroupID, 'Notify Completion', 'Pending', '6', 'usp_NotifyAndEndTask', 
	null, 'usp_StepFailedStop', '1', getdate(), @UpdateUserID)
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_SubmitViewDelete
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END

	/*
	** Insert all the script arguments now, Will need to update task
	** and inform interested parties
	*/
	insert into TaskStepArgument
	(StepID, ArgumentOrdinal, ForProcedureX, ArgumentValue)
	values
	(@StepID, '1', '1', cast(@TaskID as varchar(40)))
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_SubmitViewDelete
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END
		
	/* Only need group because we want to notify all members of group */
	insert into TaskStepArgument
	(StepID, ArgumentOrdinal, ForProcedureX, ArgumentValue)
	values
	(@StepID, '2', '1', @GroupID)
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_SubmitViewDelete
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END
		
	insert into TaskStepArgument
	(StepID, ArgumentOrdinal, ForProcedureX, ArgumentValue)
	values
	(@StepID, '3', '1', 'The Macro ' + @ShortName+ ' has been deleted from the Site.')
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_SubmitViewDelete
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END

	/*
	** Insert the args for the failure script, It will not
	** do any notification, but needs to change the Task 
	** status so TaskID is setup as an argument.
	*/
	insert into TaskStepArgument
	(StepID, ArgumentOrdinal, ForProcedureX, ArgumentValue)
	values
	(@StepID, '1', '3', cast(@TaskID as varchar(40)))
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_SubmitViewDelete
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END

	COMMIT TRAN Tran_SubmitViewDelete
	
	/*
	** Now that the task has been completely we need to kick the first round
	** of execution so any auto steps will be performed
	*/
	EXEC usp_processTaskExecution @TaskID
	
	SET NOCOUNT OFF
	RETURN 0 

END


GO
GRANT EXECUTE ON [dbo].[usp_submitMacroForDeleteApproval] TO [webadminuser_role]
GO
