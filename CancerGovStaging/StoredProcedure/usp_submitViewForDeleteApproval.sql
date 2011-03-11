IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_submitViewForDeleteApproval]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_submitViewForDeleteApproval]
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
**    Deletion of a NCIView from the System
**
**  NOTE: This procedure does not handle recursive nesting of lists, if
**    this is needed before a major data model change let me know and I 
**    will update the code.
**
**  Issues:  
**
**  Author: M.P. Brady 11-01-01
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
CREATE PROCEDURE [dbo].[usp_submitViewForDeleteApproval] 
	(
	@viewObj uniqueidentifier,   -- Note this is the guid for NCIView to be approved
	@UpdateUserID varchar(50),    -- This should be the username as it appears in NCIUsers table
	@previewURL varchar(50),      -- This should be defined in web.config file
	@AdminURL varchar(50)      -- This should be defined in web.config file
	)
AS
BEGIN	
	SET NOCOUNT ON

	-- If TSTopic, previewurl should be empty
	if ( exists (select Type from ViewObjects where nciviewid=	@viewObj and type ='TSTOPIC'))
	BEGIN
		select @previewURL =''
	END
	/*
	** STEP - A
	** First Validate that the guid provided is valid
	** if not return a 70001 error
	*/		

	if ( @previewURL='BESTBETS')
	BEGIN		
		if(	
			  (@viewObj IS NULL) OR (NOT EXISTS (SELECT CategoryID FROM BestBetCategories WHERE categoryID =@viewObj)) 
		  )	
		BEGIN
			RAISERROR ( 70001, 16, 1)
			RETURN 70001
		END
	END
	ELSE
	BEGIN		
		if(	
			  (@viewObj IS NULL) OR (NOT EXISTS (SELECT NCIViewID FROM nciview WHERE NCIViewID = @viewObj)) 
		  )	
		BEGIN
			RAISERROR ( 70001, 16, 1)
			RETURN 70001
		END
	END

	DECLARE @TaskID uniqueidentifier,
		@StepID uniqueidentifier,
		@GroupID int,
		@title   varchar(255),
		@stitle  varchar(50),
		@viewStatus char(10),
		@url     varchar(1000),
		@urlarguments varchar(2000)
		
	select @TaskID = newid()

	-- best bets has no preview url and url. 
	if ( @previewURL='BESTBETS')
	BEGIN
		select @GroupID = 5, @title = 'BestBets: '+ Replace(left(Catname,50), '''', ''''''), @stitle = 'BestBets: '+ Replace(left(Catname,50), '''', ''''''), @url = '', @urlarguments = '', @viewStatus = status
		from BestbetCategories where categoryid = @viewObj
	END
	ELSE
	BEGIN
		select @GroupID = groupID, @title = Replace(title, '''', ''''''), @stitle = Replace(shorttitle, '''', ''''''), @url = url, @urlarguments = urlarguments, @viewStatus = status
		from nciview where nciviewid = @viewObj
	END

	BEGIN TRAN Tran_SubmitViewDelete

	/*
	** STEP - B
	** Set the status of the view to 'DelSubmit'.  This will
	** allow us to lock the content down until an approval or
	** dissaproval has been done on the content.
	*/	
	if ( @previewURL='BESTBETS')
	BEGIN
		update bestbetcategories 
		set Status = 'DelSubmit',
		    UpdateUserID = @UpdateUserID,
		    UpdateDate = getdate()
		where CategoryID = @viewObj
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN Tran_SubmitViewApproval
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 
	END
	ELSE
	BEGIN
		update nciview 
		set Status = 'DelSubmit',
		    UpdateUserID = @UpdateUserID,
		    UpdateDate = getdate()
		where NCIViewID = @viewObj
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN Tran_SubmitViewDelete
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END
	END 
	
	/*
	** STEP - C
	** Now we need to submit the task and Step for this action
	*/
	insert into Task
	(TaskID, ResponsibleGroupID, Name, UpdateDate, UpdateUserID, ObjectID, status)
	values
	(@TaskID, @GroupID, 'Deletion of ' + @stitle, getdate(), @UpdateUserID, @viewObj, 'Executing')
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
	
	if ( @previewURL='BESTBETS')
	BEGIN
		insert into TaskStepArgument
		(StepID, ArgumentOrdinal, ForProcedureX, ArgumentValue)
		values
		(@StepID, '4', '1', 'The Bestbet "' +  @title + '" has been submitted for <font color=red><bold>DELETION</bold></font>, and awaits your approval. ' +
		'<a href="'+ @AdminURL + '/Page/PagePreview.aspx?TaskID=' + cast(@TaskID as varchar(40)) + '"> Go there now. </a>')
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN Tran_SubmitViewDelete
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END
	END
	ELSE
	BEGIN
		insert into TaskStepArgument
		(StepID, ArgumentOrdinal, ForProcedureX, ArgumentValue)
		values
		(@StepID, '4', '1', 'The NCIView "' +  @title + '" has been submitted for <font color=red><bold>DELETION</bold></font>, and awaits your approval. ' +
		'<a href="' + @AdminURL + '/Page/PagePreview.aspx?TaskID=' + cast(@TaskID as varchar(40)) + '"> Go there now. </a>')
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN Tran_SubmitViewDelete
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END
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
	/*
	** Insert the step used to delete the view
	*/	
	if ( @previewURL='BESTBETS')
	BEGIN	
		insert into TaskStep
		(StepID, TaskID, ResponsibleGroupID, Name, Status, OrderLevel, AprvStoredProcedure, DisAprvStoredProcedure, 
		OnErrorStoredProcedure, IsAuto, UpdateDate, UpdateUserID, description)
		values
		(@StepID, @TaskID, @GroupID, 'Approve Deletion', 'Pending', '2', 'usp_doNothing',  
		'usp_disApproveBestBetDelete', 'usp_StepFailedNotifyStop', '0', getdate(), @UpdateUserID, 
		'The Bestbet "'  + @title + '" has been submitted for <font color=red><bold>DELETION</bold></font>, and awaits your approval.')
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN Tran_SubmitViewDelete
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END
	END
	ELSE 
	BEGIN
		insert into TaskStep
		(StepID, TaskID, ResponsibleGroupID, Name, Status, OrderLevel, AprvStoredProcedure, DisAprvStoredProcedure, 
		OnErrorStoredProcedure, IsAuto, UpdateDate, UpdateUserID, description)
		values
		(@StepID, @TaskID, @GroupID, 'Approve Deletion', 'Pending', '2', 'usp_doNothing', 
		'usp_disApproveViewDelete', 'usp_StepFailedNotifyStop', '0', getdate(), @UpdateUserID, 
		'The Page "'  + @title + '" has been submitted for <font color=red><bold>DELETION</bold></font>, and awaits your approval. ' + 
		'Note: This is just an approval for work to be performed later.')
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN Tran_SubmitViewDelete
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 
	END	
	/*
	** Insert all the script arguments now for DisApproval
	*/	
	insert into TaskStepArgument
	(StepID, ArgumentOrdinal, ForProcedureX, ArgumentValue)
	values
	(@StepID, '1', '2', cast(@viewObj as varchar(40)))
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
	(@StepID, '3', '3', 'The Page <a href="' + @previewURL + @url + IsNull(NullIf( '?'+IsNull(@URLArguments,''),'?'),'')  + 	'">' + @title + '</a> failed during deletion processing')
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_SubmitViewDelete
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END	
	
	/*
	** STEP - D
	** Determine if we will need to add any steps to inform users about this view deletion
	** because they referece this view (This does not handle nesting of code)
	*/
	if ( @previewURL!='BESTBETS')
	BEGIN		
		DECLARE 	@ListID uniqueidentifier, 
				@ParentListID uniqueidentifier, 
				@conGroupID int,
			  	@ListName varchar(255), 
				@newUrl varchar(2000), 
				@pgTitle varchar(255)
 	
		DECLARE List_Cursor CURSOR FORWARD_ONLY  FOR
--		SELECT 	DISTINCT l.ListID, ParentListID, ListName
--		FROM 	listitem li, list l
--		WHERE  	li.NCIViewID = @viewObj 
--				AND     li.ListID = l.ListID
--				or      l.NCIViewID = @viewObj	
		SELECT  DISTINCT l.ListID, ParentListID, ListName  
		  FROM  listitem li, list l  
		  WHERE   li.NCIViewID =  @viewObj
			AND     li.ListID = l.ListID  
		Union
		 SELECT  DISTINCT l.ListID, ParentListID, ListName  
		  FROM   list l  
		  WHERE         l.NCIViewID = @viewObj

		FOR READ ONLY 
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN Tran_SubmitViewDelete
			RAISERROR ( 70004, 16, 1)

			RETURN 70004
		END 
	
		OPEN List_Cursor 
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN Tran_SubmitViewDelete
			DEALLOCATE List_Cursor 
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 
		
		FETCH NEXT FROM List_Cursor
		INTO 	@ListID, @ParentListID, @ListName	
	
		WHILE @@FETCH_STATUS != -1   -- Fetch success is 0, failure is -1, and missing row is -2
		BEGIN
			IF @@FETCH_STATUS = -2  -- Missing a row we need to fail on the delete
			BEGIN
				ROLLBACK TRAN Tran_SubmitViewDelete
				DEALLOCATE List_Cursor 
				RAISERROR ( 70002, 16, 1)
				RETURN 70002
			END
			/*
			** Now that we have a list of conflicting lists, Lets determine
			** Which pages/ groups are affected and add appropriate steps to 
			** the task.  NOTE I am not sure the following checking for NULLS
			** will work.
			*/
			select @newUrl = null
			IF (@ParentListID is NULL)
			BEGIN
				select @newUrl = (url + IsNull(NullIf( '?'+IsNull(URLArguments,''),'?'),'') ), @pgTitle = Replace(title, '''', ''''''), @conGroupID = groupID
				from nciview nv, viewobjects vo
				where vo.objectid = @ListID
					and nv.nciviewid = vo.nciviewid	
			END
			ELSE BEGIN
				select @newUrl = (url + IsNull(NullIf( '?'+IsNull(URLArguments,''),'?'),'') ), @pgTitle = Replace(title, '''', ''''''), @conGroupID = groupID
				from nciview nv, viewobjects vo
				where vo.objectid = @ParentListID
					and nv.nciviewid = vo.nciviewid	
			END
		
			IF (@newUrl is NULL)
			BEGIN
				select @conGroupID = '5', @newURL = @AdminURL, @pgTitle = Replace(@ListName, '''', '''''')
			END
		
			/*
			** Now that we have the particuliars for this conflict Add 2 tasks one
			** of orderlevel one to perform a notification, and one of orderlevel 2
			** to recieve the approval or dis-approval of conflicted page owner.
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
			(@StepID, @TaskID, @conGroupID, 'Notify', '3', 'usp_SendMessage', 
			null, 'usp_StepFailedStop', '1', getdate(), @UpdateUserID, 'Pending')
			IF (@@ERROR <> 0)
			BEGIN
				ROLLBACK TRAN Tran_SubmitViewDelete
				DEALLOCATE List_Cursor 
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
			(@StepID, '1', '1', @conGroupID)
			IF (@@ERROR <> 0)
			BEGIN
				ROLLBACK TRAN Tran_SubmitViewDelete
				DEALLOCATE List_Cursor 
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
				DEALLOCATE List_Cursor 
				RAISERROR ( 70004, 16, 1)
				RETURN 70004
			END	
		
			insert into TaskStepArgument
			(StepID, ArgumentOrdinal, ForProcedureX, ArgumentValue)
			values
			(@StepID, '3', '1', 'A Page Deletion Affects Your Page')
			IF (@@ERROR <> 0)
			BEGIN
				ROLLBACK TRAN Tran_SubmitViewDelete
				DEALLOCATE List_Cursor 
				RAISERROR ( 70004, 16, 1)
				RETURN 70004
			END	
		
			insert into TaskStepArgument
			(StepID, ArgumentOrdinal, ForProcedureX, ArgumentValue)
			values
			(@StepID, '4', '1', 'The Page <a href="' + @previewURL+ @url + IsNull(NullIf( '?'+IsNull(@URLArguments,''),'?'),'')  + 
			'">' + @title + '</a> has been submitted for <font color=red><bold>Deletion</bold></font> and is currently being referenced by your page/menu ' + 
			'<a href="' + @newUrl + '">' + @pgTitle + '</a>.  Please review and authorize us to continue with this deletion.' + 
			'<a href="' + @AdminURL +'/Page/PagePreview.aspx?TaskID=' + cast(@TaskID as varchar(40)) + '"> Go there now. </a>')
			IF (@@ERROR <> 0)
			BEGIN
				ROLLBACK TRAN Tran_SubmitViewDelete
				DEALLOCATE List_Cursor 
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
				DEALLOCATE List_Cursor 
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
				DEALLOCATE List_Cursor 
				RAISERROR ( 70004, 16, 1)
				RETURN 70004
			END

			/*
			** Now insert the action step
			*/	
			select @StepID = newid()
			/*
			** Insert the First step which is a step used to notify the members of the group about the task
			** that needs to be worked on
			*/	
			insert into TaskStep
			(StepID, TaskID, ResponsibleGroupID, Name, Status, OrderLevel, AprvStoredProcedure, DisAprvStoredProcedure, 
			OnErrorStoredProcedure, IsAuto, UpdateDate, UpdateUserID, description)
			values
			(@StepID, @TaskID, @conGroupID, 'Approve Link Deletion', 'Pending', '4', 'usp_doNothing', 
			'usp_disApproveReferenceDelete', 'usp_StepFailedNotifyStop', '0', getdate(), @UpdateUserID,
			'The Page <a href="' + @previewURL +@url + IsNull(NullIf( '?'+IsNull(@URLArguments,''),'?'),'')  + '">' + @title + 	
			'</a> has been submitted for <font color=red><bold>Deletion</bold></font> and is currently being referenced by your page/menu ' + 
			'<a href="' + @newUrl + '">' + @pgTitle + '</a>.  Please review and authorize us to continue with this deletion.' +
			'Note: This is just an approval for work to be performed later.')
			IF (@@ERROR <> 0)
			BEGIN
				ROLLBACK TRAN Tran_SubmitViewDelete
				DEALLOCATE List_Cursor 
				RAISERROR ( 70004, 16, 1)
				RETURN 70004
			END 
		
			/*
			** Insert all the script arguments now for Approval
			** Nothing to do here it is a do nothing script just
			** used to provide a spot for a person to mark approval
			*/
			
			/*
			** Insert all the script arguments now for DisApproval
			*/	
			insert into TaskStepArgument
			(StepID, ArgumentOrdinal, ForProcedureX, ArgumentValue)
			values
			(@StepID, '1', '2', cast(@viewObj as varchar(40)))
			IF (@@ERROR <> 0)
			BEGIN
				ROLLBACK TRAN Tran_SubmitViewDelete
				DEALLOCATE List_Cursor 
				RAISERROR ( 70004, 16, 1)
				RETURN 70004
			END
		
			/*
			** Insert all the script arguments now for DisApproval
			*/			insert into TaskStepArgument
			(StepID, ArgumentOrdinal, ForProcedureX, ArgumentValue)
			values
			(@StepID, '2', '2', @viewStatus)
			IF (@@ERROR <> 0)
			BEGIN
				ROLLBACK TRAN Tran_SubmitViewDelete			
				DEALLOCATE List_Cursor 
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
				DEALLOCATE List_Cursor 
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
				DEALLOCATE List_Cursor 
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
				DEALLOCATE List_Cursor 
				RAISERROR ( 70004, 16, 1)
				RETURN 70004
			END
		
			/*
			** Insert the args for the failure script, It will update 
			** Task Status and Notify respective people.  This should only
			** ever happen on a dis-approval request

			*/
			insert into TaskStepArgument
			(StepID, ArgumentOrdinal, ForProcedureX, ArgumentValue)
			values
			(@StepID, '1', '3', cast(@TaskID as varchar(40)))
			IF (@@ERROR <> 0)
			BEGIN
				ROLLBACK TRAN Tran_SubmitViewDelete
				DEALLOCATE List_Cursor 
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
				DEALLOCATE List_Cursor 
				RAISERROR ( 70004, 16, 1)
				RETURN 70004
			END
		
			insert into TaskStepArgument
			(StepID, ArgumentOrdinal, ForProcedureX, ArgumentValue)
			values
			(@StepID, '3', '3', 'The Dis-approval of deletion of a link to our page failed. <a href="' + @previewURL
			+ @url + IsNull(NullIf( '?'+IsNull(@URLArguments,''),'?'),'')  + 
			'">' + @title + '</a>')
			IF (@@ERROR <> 0)
			BEGIN
				ROLLBACK TRAN Tran_SubmitViewDelete
				DEALLOCATE List_Cursor 
				RAISERROR ( 70004, 16, 1)
				RETURN 70004
			END

			-- GET NEXT OBJECT
			FETCH NEXT FROM List_Cursor
			INTO 	@ListID, @ParentListID, @ListName	
		END -- end while loop

		-- CLOSE ViewObject_Cursor		
		CLOSE List_Cursor 
		DEALLOCATE List_Cursor 
	END -- end listitem if
	
	/*
	** Now that we are Done with the preliminaries, we can set up the steps
	** to delete view and Notify/close task.
	*/
			
	select @StepID = newid()
	/*
	** Insert the step used to delete the view
	*/	
	if ( @previewURL !='BESTBETS')
	BEGIN
		insert into TaskStep
		(StepID, TaskID, ResponsibleGroupID, Name, Status, OrderLevel, AprvStoredProcedure, DisAprvStoredProcedure, 
		OnErrorStoredProcedure, IsAuto, UpdateDate, UpdateUserID)
		values
		(@StepID, @TaskID, @GroupID, 'Delete Content', 'Pending', '5', 'usp_deleteNCIView', 
		null, 'usp_StepFailedNotifyStop', '1', getdate(), @UpdateUserID)
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN Tran_SubmitViewDelete
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 
	END
	ELSE
	BEGIN
		insert into TaskStep
		(StepID, TaskID, ResponsibleGroupID, Name, Status, OrderLevel, AprvStoredProcedure, DisAprvStoredProcedure, 
		OnErrorStoredProcedure, IsAuto, UpdateDate, UpdateUserID)
		values
		(@StepID, @TaskID, @GroupID, 'Delete Content', 'Pending', '5', 'usp_deleteBestBetBoth', 
		null, 'usp_StepFailedNotifyStop', '1', getdate(), @UpdateUserID)
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN Tran_SubmitViewDelete
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 
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
	(@StepID, '3', '3', 'The Page <a href="' + @previewURL+ @url + IsNull(NullIf( '?'+IsNull(@URLArguments,''),'?'),'')  + '">' + @title + '</a> failed during deletion processing')
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
	(@StepID, '3', '1', 'The Page ' + @title + ' has been deleted from the Site.')
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
GRANT EXECUTE ON [dbo].[usp_submitViewForDeleteApproval] TO [webadminuser_role]
GO
