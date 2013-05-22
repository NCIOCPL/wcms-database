IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].usp_submitViewForUnpublish') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].usp_submitViewForUnpublish
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
**    publishing of nciview to production
**
**  NOTE:  
**
**  Issues:  
**
**  Author: M.P. Brady 11-01-01
**  Revision History:
**  02-11-2003 Jay He Revised for adding submission bestbets for deletion/approval  -- Have a hard coded group id 5 for best bets
** 11-02-2004  Jay He Added approval notes
**  Return Values
**  0         Success
**  70001     The guid argument was invalid
**  70004     Failed during execution of deletion
**  70005     Denotes the switch of task to executing status
**
*/
CREATE PROCEDURE [dbo].usp_submitViewForUnpublish 
	(
	@viewObj uniqueidentifier,   -- Note this is the guid for NCIView to be approved
	@UpdateUserID varchar(50),   -- This should be the username as it appears in NCIUsers table
	@previewURL varchar(50) ,     -- This should be defined in web.config file
	@AdminURL varchar(50),      -- This should be defined in web.config file
	@ChangeComments varchar(200) -- Approval Notes
	)
AS
BEGIN	
	SET NOCOUNT ON
	/*
	** STEP - A
	** First Validate that the guid provided is valid
	** if not return and 70001 error
	*/
		
	if(	
		  (@viewObj IS NULL) OR (NOT EXISTS (SELECT NCIViewID FROM nciview WHERE NCIViewID = @viewObj)) 
	  )	
	BEGIN
		RAISERROR ( 70001, 16, 1)
		RETURN 70001
	END

	DECLARE @TaskID uniqueidentifier,
		@StepID uniqueidentifier,
		@GroupID int,
		@title   varchar(255),
		@stitle  varchar(50),
		@url     varchar(1000),
		@urlarguments varchar(2000),
		@type int,
		@realPreviewurl     varchar(3000)
		
		
	select @TaskID = newid()

	select @GroupID = groupID, @title = Replace(title, '''', ''''''), @stitle = Replace(shorttitle, '''', '''''') , @url = url, @urlarguments = urlarguments 
	from nciview where nciviewid = @viewObj

	if (@urlarguments is null)
	BEGIN
		if (substring(@url,1,4) <> 'http' )
		BEGIN 
			select @realPreviewurl = @previewURL+ @url
		END
		ELSE
		BEGIN
			select @realPreviewurl = @url
		END
	END
	ELSE
	BEGIN
		select @realPreviewurl = @previewURL + @url +IsNull(NullIf( '?'+IsNull(@urlarguments,''),'?'),'') 
	END
		
	BEGIN TRAN Tran_SubmitViewApproval

	/*
	** STEP - B
	** Set the status of the view to submitted.  This will
	** allow us to lock the content down until an approval or
	** dissaproval has been done on the content.
	*/	
	
		update nciview 
		set Status = 'Submit',
		   ChangeComments = @ChangeComments,
		    UpdateUserID = @UpdateUserID,
		    UpdateDate = getdate()
		where NCIViewID = @viewObj
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN Tran_SubmitViewApproval
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 

	

	/*
	** Now we need to submit the task and Step for this action
	*/
	insert into Task
	(TaskID, ResponsibleGroupID, Name, UpdateDate, UpdateUserID, ObjectID, status)
	values
	(@TaskID, @GroupID, 'Unpublishing of ' + substring(@stitle,1,40) +'...', getdate(), @UpdateUserID, @viewObj, 'Executing')
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_SubmitViewApproval
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 

	
	select @StepID = newid()
	/*
	** Insert the First step which is a step used to notify the members of the group about the task
	** that needs to be worked on
	*/	
	insert into TaskStep
	(StepID, TaskID, ResponsibleGroupID, Name, OrderLevel, AprvStoredProcedure, DisAprvStoredProcedure, 
	OnErrorStoredProcedure, IsAuto, UpdateDate, UpdateUserID)
	values
	(@StepID, @TaskID, @GroupID, 'Notify', '1', 'usp_SendMessage', 
	null, 'usp_StepFailedStop', '1', getdate(), @UpdateUserID)
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_SubmitViewApproval
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
		ROLLBACK TRAN Tran_SubmitViewApproval
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END
		
	insert into TaskStepArgument
	(StepID, ArgumentOrdinal, ForProcedureX, ArgumentValue)
	values
	(@StepID, '2', '1', '6')
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_SubmitViewApproval
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END	
	
	insert into TaskStepArgument
	(StepID, ArgumentOrdinal, ForProcedureX, ArgumentValue)
	values
	(@StepID, '3', '1', 'The Page ' + @title + ' needs approval for unpublishing.')
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_SubmitViewApproval
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END

	
		insert into TaskStepArgument
		(StepID, ArgumentOrdinal, ForProcedureX, ArgumentValue)
		values
		(@StepID, '4', '1', 'The Page <a href="' +  @realPreviewurl	  + 
		'">' + @title + '</a> has been submitted for unpublishing from the production site, and awaits your approval. ' + 
		'<a href="' + @AdminURL +'/Page/PagePreview.aspx?TaskID=' + cast(@TaskID as varchar(40)) + '"> Go there now </a>')
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN Tran_SubmitViewApproval
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END

	insert into TaskStepArgument
	(StepID, ArgumentOrdinal, ForProcedureX, ArgumentValue)
	values
	(@StepID, '5', '1', @UpdateUserID)
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_SubmitViewApproval
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
		ROLLBACK TRAN Tran_SubmitViewApproval
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END
		
	select @StepID = newid()
	/*
	** Insert the First step which is a step used to notify the members of the group about the task
	** that needs to be worked on
	*/	

		insert into TaskStep
		(StepID, TaskID, ResponsibleGroupID, Name, Status, OrderLevel, AprvStoredProcedure, DisAprvStoredProcedure, 
		OnErrorStoredProcedure, IsAuto, UpdateDate, UpdateUserID, description)
		values
		(@StepID, @TaskID, @GroupID, 'Approve UnPublishing', 'Pending', '2', 'usp_UnpublishNCIView', 
		'usp_disApproveViewEdit', 'usp_StepFailedNotifyStop', '0', getdate(), @UpdateUserID, 'The Page <a href="'         
		+ @realPreviewurl    + '">' + @title + '</a> has been submitted for unpublishing from the production site, and awaits your approval.')
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN Tran_SubmitViewApproval
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END
	
	/*
	** Insert all the script arguments now for Approval
	*/
	insert into TaskStepArgument
	(StepID, ArgumentOrdinal, ForProcedureX, ArgumentValue)
	values
	(@StepID, '1', '1', cast(@viewObj as varchar(40)))
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_SubmitViewApproval
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END
	
	insert into TaskStepArgument
	(StepID, ArgumentOrdinal, ForProcedureX, ArgumentValue)
	values
	(@StepID, '1', '2', cast(@viewObj as varchar(40)))
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_SubmitViewApproval
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END
	
	insert into TaskStepArgument
	(StepID, ArgumentOrdinal, ForProcedureX, ArgumentValue)
	values
	(@StepID, '2', '2', cast(@TaskID as varchar(40)))
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_SubmitViewApproval
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END
		
	insert into TaskStepArgument
	(StepID, ArgumentOrdinal, ForProcedureX, ArgumentValue)
	values
	(@StepID, '3', '2', cast(@StepID as varchar(40)))
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_SubmitViewApproval
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END	

	/*
	** Needs to Notify the submitter about dis-approval
	*/
	insert into TaskStepArgument
	(StepID, ArgumentOrdinal, ForProcedureX, ArgumentValue)
	values
	(@StepID, '4', '2', @UpdateUserID)
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_SubmitViewApproval
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
		ROLLBACK TRAN Tran_SubmitViewApproval
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
		ROLLBACK TRAN Tran_SubmitViewApproval
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END
	
	
		insert into TaskStepArgument
		(StepID, ArgumentOrdinal, ForProcedureX, ArgumentValue)
		values
		(@StepID, '3', '3', 'The Page <a href="' + @realPreviewurl	+ 
		'">' + @title + '</a> failed during its unpublishing from production.')
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN Tran_SubmitViewApproval
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
	(@StepID, @TaskID, @GroupID, 'Notify Completion', 'Pending', '3', 'usp_NotifyAndEndTask', 
	null, 'usp_StepFailedStop', '1', getdate(), @UpdateUserID)
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_SubmitViewApproval
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
		ROLLBACK TRAN Tran_SubmitViewApproval
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
		ROLLBACK TRAN Tran_SubmitViewApproval
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END

	
		insert into TaskStepArgument
		(StepID, ArgumentOrdinal, ForProcedureX, ArgumentValue)
		values
		(@StepID, '3', '1', 'The Page <a href="' +@realPreviewurl	+ 
		'">' + @title + '</a> with XHTML conversion has been unpublished from the production site successfully.')
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN Tran_SubmitViewApproval
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
		ROLLBACK TRAN Tran_SubmitViewApproval
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END

	/*
	** Now that the task has been completely we need to kick the first round
	** of execution so any auto steps will be performed
	*/
	EXEC usp_processTaskExecution @TaskID
	

	COMMIT TRAN Tran_SubmitViewApproval

	SET NOCOUNT OFF
	RETURN 0 

END


GO
GRANT EXECUTE ON [dbo].usp_submitViewForUnpublish TO [webadminuser_role]
GO
