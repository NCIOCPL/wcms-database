IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_executeStep]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_executeStep]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/*
**  This procedure will execute a step's stored procedure.  The approve
**  or disapprove procedure is executed based on the type argument passed
**  in (Approve for approve procedure or DisApprove for dis-approve procedure)
**  If there is a problem executing the procedure the exception routine will 
**  executed.
**
**  NOTE: 
**
**  Issues:  
**
**  Author: M.P. Brady 11-01-01
**  Revision History:
**
**
**  Return Values
**  0         Success
**  70001     Argument was invalid
**  70004     Failed during execution of deletion
**  70006     Denotes the switch of task to executing status
**
**12/12/2008  error handle change
*/
CREATE PROCEDURE [dbo].[usp_executeStep] 
	(
	@stepID  uniqueidentifier,    -- The step that should be executed
	@type    varchar(30),         -- Appove to execute approve script, DisApprove to execute the disapprove script
	@UpdateUserID varchar(50) = 'system', -- This should be the username as it appears in NCIUsers table
	@processTask bit = '1'        -- flag used to determine if we should keep execution of the task que 
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
	   (NOT EXISTS (SELECT StepID FROM TaskStep where StepID = @stepID))
	   OR
	   (NOT EXISTS (SELECT userID from NCIUsers where loginname = @UpdateUserID))
	   OR (@type !=  'Approve' and @type != 'DisApprove')
	  )	
	BEGIN
		RAISERROR ( 70001, 16, 1)
		RETURN 70001
	END

	/*
	** Validate that the task and step are in the proper status values and 
	** the step is on the order level that is up for execution
	*/
	DECLARE @taskStatus char(10),
	@orderLevel int,
	@stepOrderLevel int,
	@stepStatus char(10),
	@taskID uniqueIdentifier
	
	select @taskStatus = t.status, @stepOrderLevel = s.orderLevel, @stepStatus = s.status, @taskID = s.TaskID
	from task t, taskstep s
	where s.TaskID = t.TaskID
	and s.StepID = @stepID
	IF (@@ERROR <> 0)
	BEGIN
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 
	
	select @orderLevel = min(orderLevel) from taskstep
	where taskID = @taskID
	and (status = 'Pending'
	or status = 'Ready')
	IF (@@ERROR <> 0)
	BEGIN
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 
	
	IF (
		@taskStatus != 'Executing'
		OR
		(@stepStatus != 'Pending' AND @stepStatus != 'Ready')
		OR
		(@stepOrderLevel != @orderLevel)
	   )
	BEGIN
		RAISERROR ( 70006, 16, 1)
		RETURN 70006
	END

	/*
	** Now that we know we have valid information we need to Start
	** building the Script with its arguments, so we can call it.
	*/
	PRINT '<break><p>Detail information from usp_executeStep: <br>Before loop'
	DECLARE @argumentValue varchar(1000),
	@CMDexec varchar(4000)
	
	IF (@type = 'Approve')
	BEGIN
		SELECT @CMDexec = AprvStoredProcedure + ' ' from TaskStep where StepID = @stepID
		IF (@@ERROR <> 0)
		BEGIN
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 
		DECLARE ArgumentCursor CURSOR FORWARD_ONLY  FOR
			select Replace(ArgumentValue, '''', '''''') from TaskStepArgument
			where StepID = @stepID
			AND ForProcedureX = '1'
			order by ArgumentOrdinal
			FOR READ ONLY 
			IF (@@ERROR <> 0)
			BEGIN
				RAISERROR ( 70004, 16, 1)
				RETURN 70004
		END 
	END ELSE
	BEGIN
		SELECT @CMDexec = DisAprvStoredProcedure + ' ' from TaskStep where StepID = @stepID
		IF (@@ERROR <> 0)
		BEGIN
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 

		DECLARE ArgumentCursor CURSOR FORWARD_ONLY  FOR
			select  Replace(ArgumentValue, '''', '''''')  from TaskStepArgument
			where StepID = @stepID
			AND ForProcedureX = '2'
			order by ArgumentOrdinal
			FOR READ ONLY 
			IF (@@ERROR <> 0)
			BEGIN
				RAISERROR ( 70004, 16, 1)
				RETURN 70004
			END 
	END
	
	OPEN ArgumentCursor 
	IF (@@ERROR <> 0)
	BEGIN
		DEALLOCATE ArgumentCursor 
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 
		
	FETCH NEXT FROM ArgumentCursor
	INTO 	@argumentValue
	
	WHILE @@FETCH_STATUS != -1   -- Fetch success is 0, failure is -1, and missing row is -2
	BEGIN
		/*
		** If we have a missing row we must continue and hope to pick it up on the 
		** next go around.  This is very dangerous, not sure if this will be a 
		** problem that can be worked around
		*/
		IF @@FETCH_STATUS != -2  -- Missing a row we need to fail on the delete
		BEGIN
			/*
			** If marked as auto execute it, else set to ready
			*/
			select @CMDexec = @CMDexec + ''''+ @argumentValue + ''', ' 
			PRINT 'proc value=' + @CMDexec + ' and arguement '+ @argumentValue
		END
			-- GET NEXT OBJECT
		FETCH NEXT FROM ArgumentCursor
		INTO 	@argumentValue	
	END

	-- CLOSE ViewObject_Cursor		
	CLOSE ArgumentCursor 
	DEALLOCATE ArgumentCursor 
	
	select @CMDexec = @CMDexec +''''+ @UpdateUserID + ''''

	/*
	** Execute the store proc and set the status on the step, if it errored
	** call the exeception routine
	*/
	BEGIN TRAN Tran_runtask

	EXEC (@CMDexec)
	IF (@@ERROR <> 0)
	BEGIN

		--SCR30308 change		12/12/2008
		if @@trancount > 0 
		  ROLLBACK TRAN Tran_runtask

		--SCR30308 change		12/12/2008
		Exec usp_updateTaskStatus @StepID
		IF (@@ERROR <> 0)
			BEGIN
				RAISERROR ( 70004, 16, 1)
				RETURN 70004 
			END
		

		update TaskStep 
		set status = 'Failed',
		UpdateUserID = @UpdateUserID,
		UpdateDate = getdate()
		where StepID = @StepID
	
		--SCR30308 change		12/12/2008
		IF (@@ERROR <> 0)
			BEGIN
				RAISERROR ( 70004, 16, 1)
				RETURN 70004 
			END
		
		
		/*
		** Create and execute the exception task now
		*/
		SELECT @CMDexec = OnErrorStoredProcedure + ' ' from TaskStep where StepID = @stepID
		IF (@@ERROR <> 0)
		BEGIN
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 
		DECLARE ArgumentCursor CURSOR FORWARD_ONLY  FOR
			select ArgumentValue from TaskStepArgument
			where StepID = @stepID
			AND ForProcedureX = '3'
			order by ArgumentOrdinal
			FOR READ ONLY 
			IF (@@ERROR <> 0)
			BEGIN
				RAISERROR ( 70004, 16, 1)
				RETURN 70004
			END 

		OPEN ArgumentCursor 
		IF (@@ERROR <> 0)
		BEGIN
			DEALLOCATE ArgumentCursor 
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 
			
		FETCH NEXT FROM ArgumentCursor
		INTO 	@argumentValue
		
		WHILE @@FETCH_STATUS != -1   -- Fetch success is 0, failure is -1, and missing row is -2
		BEGIN
			/*
			** If we have a missing row we must continue and hope to pick it up on the 
			** next go around.  This is very dangerous, not sure if this will be a 
			** problem that can be worked around
			*/
			IF @@FETCH_STATUS != -2  -- Missing a row we need to fail on the delete
			BEGIN
				/*
				** If marked as auto execute it, else set to ready
				*/
				select @CMDexec = @CMDexec + '''' + @argumentValue + ''', ' 
			END
				-- GET NEXT OBJECT
			FETCH NEXT FROM ArgumentCursor
			INTO 	@argumentValue	
		END	

		-- CLOSE ViewObject_Cursor		
		CLOSE ArgumentCursor 
		DEALLOCATE ArgumentCursor 
	
		select @CMDexec = @CMDexec + '''' + @UpdateUserID + ''''

		EXEC (@CMDexec)
		IF (@@ERROR <> 0)
		BEGIN
			--SCR30308 change		12/12/2008
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END
 
	return 70004

	END 
	ELSE
	BEGIN
		/*
		** Only Set the completed status for Approval Steps
		*/
		IF (@type = 'Approve')
		BEGIN
			update TaskStep 
			set status = 'Completed',
			UpdateUserID = @UpdateUserID,
			UpdateDate = getdate()
			where StepID = @StepID
			IF (@@ERROR <> 0)
			BEGIN
				ROLLBACK TRAN Tran_runtask
				RAISERROR ( 70004, 16, 1)
				RETURN 70004
			END 
		END ELSE
		BEGIN
			update TaskStep 
			set status = 'Canceled',
			UpdateUserID = @UpdateUserID,
			UpdateDate = getdate()
			where StepID = @StepID
			IF (@@ERROR <> 0)
			BEGIN
				ROLLBACK TRAN Tran_runtask
				RAISERROR ( 70004, 16, 1)
				RETURN 70004
			END 
		END

	END
	
	IF (@processTask = '1')
	BEGIN
		EXEC usp_processTaskExecution   @taskID
		IF (@@ERROR <> 0)
			BEGIN
				ROLLBACK TRAN Tran_runtask
				RAISERROR ( 70004, 16, 1)
				RETURN 70004
			END 
	END
	
	COMMIT TRAN Tran_runtask

	SET NOCOUNT OFF
	RETURN 0 

END
GO
GRANT EXECUTE ON [dbo].[usp_executeStep] TO [webadminuser_role]
GO
