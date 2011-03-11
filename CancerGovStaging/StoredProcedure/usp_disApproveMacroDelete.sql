IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_disApproveMacroDelete]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_disApproveMacroDelete]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO

/*
**  This procedure is a specific funtion to process dis-approval of a request
**  to delete a macro
**
**  NOTE: 
**
**  Issues:  
**
**  Author: Jay He
**  Revision History:
**
**
**  Return Values
**  0         Success
**  70001     Argument was invalid
**  70004     Failed during execution of deletion
**
*/
CREATE PROCEDURE [dbo].[usp_disApproveMacroDelete] 
	(
	@MacroID  uniqueidentifier,    -- View ID that was disapproved
	@viewStatus char(10),	      -- Status to return view to
	@taskID  uniqueidentifier,    -- Task to mark as Canceled
	@stepID  uniqueidentifier,    -- Step to mark as Canceled
	@submitUserId varchar(50),     -- User that Requested the approval
	@UpdateUserId varchar(50)     -- User that Denied approval
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
	   (NOT EXISTS (SELECT MacroName FROM TSMacros WHERE MacroID= @MacroID))
	   OR 
	   (NOT EXISTS (SELECT TaskID FROM Task where TaskID = @taskID))
	   OR
	   (NOT EXISTS (SELECT StepID FROM TaskStep where StepID = @stepID))
	  )	
	BEGIN
		RAISERROR ( 70001, 16, 1)
		RETURN 70001
	END

	DECLARE @sendID uniqueidentifier,
		@receiveID uniqueidentifier,
		@ShortName 	varchar(50),
		@tName varchar(50), @sName varchar(50) 
	
	select @ShortName = left(MacroName,50) from TSMacros where MacroID  = @MacroID		

	/*
	** Note Not sure if the test for NULL will work????
	*/	
	select @receiveID = userID from NCIusers where loginName = @submitUserId
	IF (@@ERROR <> 0 or @receiveID is null)
	BEGIN
		RAISERROR ( 70001, 16, 1)
		RETURN 70001
	END 
	
	select @sendID = userID from NCIusers where loginName = @UpdateUserID	
	IF (@@ERROR <> 0 or @sendID is null)
	BEGIN
		RAISERROR ( 70001, 16, 1)
		RETURN 70001
	END 
	
	select @tName = t.name, @sName = s.name from task t, taskstep s
	where t.taskID = @taskID and t.taskID = s.taskID and s.stepID = @stepID
	

	BEGIN TRAN Tran_DisAproveViewDelete
	
	update task
	set Status = 'Canceled'
	where TaskID = @taskID
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_DisAproveViewDelete
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 
	
	update TSMacros
	set Status = @viewStatus 
	where MacroID = @MacroID
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_DisAproveViewDelete
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 
	

	insert into NCIMessage
	(SenderID, RecipientID, Subject, Message, Status)	
	values
	(@sendID, @receiveID, 'Macro Delete Approval Request Denied', 'Macro Delete Approval Request Denied for ' + 
	@ShortName + ' In Task "' + @tName + '" and Step "' + @sName + '"', 'Posted')
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_DisAproveViewDelete
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END

	COMMIT TRAN Tran_DisAproveViewDelete
	
	SET NOCOUNT OFF
	RETURN 0 

END
GO
GRANT EXECUTE ON [dbo].[usp_disApproveMacroDelete] TO [webadminuser_role]
GO
