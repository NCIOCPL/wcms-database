IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_processTaskExecution]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_processTaskExecution]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*
**  This procedure Takes a task and performs all required logic to process 
**    steps looking for automatic execution, or set their status to 'ready',
**    so they can be excuted manually.
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
**  70005     Denotes the switch of task to executing status
**
*/
CREATE PROCEDURE [dbo].[usp_processTaskExecution] 
	(
	@taskID  uniqueidentifier,    -- Task to mark as failed
	@UpdateUserID varchar(50) = 'system' -- This should be the username as it appears in NCIUsers table
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
	   (NOT EXISTS (SELECT TaskID FROM Task where TaskID = @taskID))
	   OR
	   (NOT EXISTS (SELECT userID from NCIUsers where loginname = @UpdateUserID))
	  )	
	BEGIN
		RAISERROR ( 70001, 16, 1)
		RETURN 70001
	END

	PRINT 'TaskID and UserID is good'
	/*
	** Now that we know we have valid information we need to verify that the 
	** task is in executing status (This is the only status that allows steps
	** to execute). 
	** The next step is to find all the steps in the lowest order level that
	** are of status pending or ready.  Then we will execute any of the ones
	** marked auto, if not auto we switch the status from pending to ready.
	** Finally this procedure of processing the steps will be done in a loop
	** to ensure we process as many orderlevels as required.
	*/

	DECLARE @taskStatus varchar(10),
	@loopControl int, 
	@stepID uniqueidentifier,
	@status varchar(10),
	@isAuto bit
		
	select @taskStatus = status, @loopControl = '1' from task where taskid = @taskID
	
	WHILE (@taskStatus = 'Executing' AND @loopControl = 1)
	BEGIN
	
		DECLARE StepCursor CURSOR FORWARD_ONLY  FOR
		select StepID, Status, IsAuto from TaskStep
		where TaskID = @taskID
		and (status = 'Pending' or status = 'Ready')
		and OrderLevel = (select min(OrderLevel) from TaskStep
		where TaskID = @taskID
		and (status = 'Pending'
		or status = 'Ready'))
		FOR READ ONLY 
		IF (@@ERROR <> 0)
		BEGIN
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 
		
		OPEN StepCursor 
		IF (@@ERROR <> 0)
		BEGIN
			DEALLOCATE StepCursor 
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 
			
		FETCH NEXT FROM StepCursor
		INTO 	@stepID, @status, @isAuto	
		
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
				if (@isAuto = 1)
				BEGIN
					PRINT 'before usp_executeStep '
					EXEC usp_executeStep @stepID, 'Approve', @UpdateUserID, '0'
				END ELSE
				BEGIN
					update TaskStep
					set status = 'Ready'
					where StepID = @stepID
					select @loopControl = 0  -- Break the Loop, because a manual Step needs to be processed
				END
			END

			-- GET NEXT OBJECT
			FETCH NEXT FROM StepCursor
			INTO 	@stepID, @status, @isAuto	
		END
	
		-- CLOSE ViewObject_Cursor		
		CLOSE StepCursor 
		DEALLOCATE StepCursor 
		
		select @taskStatus = status from task where taskid = @taskID
		PRINT 'end of usp_process status =' + @taskStatus
	END
	
	SET NOCOUNT OFF
	RETURN 0 

END
GO
GRANT EXECUTE ON [dbo].[usp_processTaskExecution] TO [webadminuser_role]
GO
