IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_disApproveBestBetEdit]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_disApproveBestBetEdit]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*
**  This procedure is a specific funtion to process dis-approval of a requested
**  edit change.
**
**  NOTE: 
**
**  Issues:  
**
**  Author: Jay He 02/19/2003 
**  Revision History:
**  
**
**  Return Values
**  0         Success
**  70001     Argument was invalid
**  70004     Failed during execution of deletion
**
*/
CREATE PROCEDURE [dbo].[usp_disApproveBestBetEdit] 
	(
	@CategoryID  uniqueidentifier,    -- Category ID that was disapproved
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
	   (NOT EXISTS (SELECT CategoryID FROM bestbetcategories WHERE CategoryID = @CategoryID))
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
		@receiveID uniqueidentifier
	
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
	
	BEGIN TRAN Tran_DisAproveViewEdit
	
	update task
	set Status = 'Canceled'
	where TaskID = @taskID
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_DisAproveViewEdit
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 

	update BestBetCategories
	set Status = 'Edit'
	where CategoryID = @CategoryID
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_DisAproveViewEdit
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 
	
	DECLARE @vTitle varchar(255), @tName varchar(50), @sName varchar(50) 
	
	SELECT @vTitle = left(CatName,50) from BestBetCategories where CategoryID = @CategoryID
	select @tName = t.name, @sName = s.name from task t, taskstep s
	where t.taskID = @taskID and t.taskID = s.taskID and s.stepID = @stepID
	
	insert into NCIMessage
	(SenderID, RecipientID, Subject, Message, Status)	
	values
	(@sendID, @receiveID, 'Best Bets Edit Approval Request Denied', 'Best Bets Edit Approval Request Denied for ' + 
	@vTitle + ' In Task "' + @tName + '" and Step "' + @sName + '"', 'Posted')
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_DisAproveViewEdit
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END

	COMMIT TRAN Tran_DisAproveViewEdit
	
	SET NOCOUNT OFF
	RETURN 0 

END
GO
GRANT EXECUTE ON [dbo].[usp_disApproveBestBetEdit] TO [webadminuser_role]
GO
