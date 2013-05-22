IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_disApproveViewEdit]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_disApproveViewEdit]
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
**  Author: M.P. Brady 11-01-01
**  Revision History:
**
**
**  Return Values
**  0         Success
**  70001     Argument was invalid
**  70004     Failed during execution of deletion
**
*/
CREATE PROCEDURE [dbo].[usp_disApproveViewEdit] 
	(
	@viewID  uniqueidentifier,    -- View ID that was disapproved
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
	   (NOT EXISTS (SELECT NCIViewID FROM nciview WHERE NCIViewID = @viewID))
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
	
/*	update taskStep
	set Status = 'Canceled'
	where StepID = @stepID
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_DisAproveViewEdit
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 
*/	
	update NCIView
	set Status = 'Edit'
	where NCIViewID = @viewID
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_DisAproveViewEdit
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 
	
	DECLARE @vTitle varchar(255), @tName varchar(50), @sName varchar(50) , @Type  int
	
	SELECT @vTitle = title from NCIView where NCIViewID = @viewID
	select @tName = t.name, @sName = s.name, @Type = t.type from task t, taskstep s
	where t.taskID = @taskID and t.taskID = s.taskID and s.stepID = @stepID
	
	insert into NCIMessage
	(SenderID, RecipientID, Subject, Message, Status)	
	values
	(@sendID, @receiveID, 'View Edit Approval Request Denied', 'View Edit Approval Request Denied for <a href=/page/NCIViewRedirect.aspx?ReturnURL=&NCIViewID='+ CONVERT(varchar(38), @viewID) + '>' + 
	@vTitle + '</a> In Task "' + @tName + '" and Step "' + @sName + '"', 'Posted')
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_DisAproveViewEdit
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END

	if (@Type =2) -- xhtml denial, create a property to show it being denied
	BEGIN
		INSERT INTO [CancerGovStaging].[dbo].[ViewProperty]
           ([ViewPropertyID]
           ,[NCIViewID]
           ,[PropertyName]
           ,[PropertyValue]
           ,[UpdateDate]
           ,[UpdateUserID])
     VALUES
			(newid(), @viewID, 'XHTMLDenied', 'Yes', getdate(), @UpdateUserId)
	END

	COMMIT TRAN Tran_DisAproveViewEdit
	
	SET NOCOUNT OFF
	RETURN 0 

END
GO
GRANT EXECUTE ON [dbo].[usp_disApproveViewEdit] TO [webadminuser_role]
GO
