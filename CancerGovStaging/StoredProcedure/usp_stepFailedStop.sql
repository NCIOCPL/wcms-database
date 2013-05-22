IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_stepFailedStop]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_stepFailedStop]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/*
**  This procedure is a general purpose function that will mark the tasks
**    status that was passed in to Failed.  This procedure should only be 
**    in event of a step failing in a task.
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
**  70004     Failed during general purpose sql
**
*/
CREATE PROCEDURE [dbo].[usp_stepFailedStop] 
	(
	@taskID  uniqueidentifier,                -- Task to mark as failed
	@UpdateUserID varchar(50)    -- This should be the username as it appears in NCIUsers table
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
	   (NOT EXISTS (SELECT TaskID FROM Task WHERE TaskID = @taskID)) 
	  )	
	BEGIN
		RAISERROR ( 70001, 16, 1)
		RETURN 70001
	END

	update task
	set Status = 'Failed',
	UpdateUserID = @UpdateUserID,
	UpdateDate = getdate()
	where TaskID = @taskID
	IF (@@ERROR <> 0)
	BEGIN
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 
	
	update NCIView
	set Status = 'Edit',
	UpdateUserID = @UpdateUserID,
	UpdateDate = getdate()
	where NciviewID = (select ObjectID from Task WHERE taskID =@taskID)
	IF (@@ERROR <> 0)
	BEGIN
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 

	SET NOCOUNT OFF
	RETURN 0 

END
GO
GRANT EXECUTE ON [dbo].[usp_stepFailedStop] TO [webadminuser_role]
GO
