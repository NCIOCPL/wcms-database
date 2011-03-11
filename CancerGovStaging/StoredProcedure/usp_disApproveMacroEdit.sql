IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_disApproveMacroEdit]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_disApproveMacroEdit]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO

/*
**  This procedure is a specific funtion to process dis-approval of a requested
**  edit change.
**
**  NOTE: 
**
**  Issues:  
**
**  Author: Jay He 03/20/03
**  Revision History:
**
**
**  Return Values
**  0         Success
**  70001     Argument was invalid
**  70004     Failed during execution of deletion
**
*/
CREATE PROCEDURE [dbo].[usp_disApproveMacroEdit] 
	(
	@MacroID  uniqueidentifier,    -- Macro ID that was disapproved
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
		@MacroName 	varchar(512),
		@MacroValue	varchar(1024),
		@TopicID uniqueidentifier,
		@vTitle varchar(255), 
		@tName varchar(50), 
		@sName varchar(50) 

	/*
	** STEP - B
	**We need to get all topics and related terms on staging.
	*/	

	select @MacroName = left(MacroName,50) , @MacroValue = MacroValue from CancerGovStaging..TSMacros where MacroID  = @MacroID		
	
	CREATE TABLE #TempTSTopic (
			[TopicID] 	[uniqueidentifier], 
			[NCIViewID] 	[uniqueidentifier]
	);

	Insert INTO #TempTSTopic (TopicID, NCIViewID)
	SELECT ts.TopicID, 
			(SELECT vo.nciviewid 
				from CancerGovStaging..viewobjects vo 
				where vo.objectid=ts.TopicID) As NCIViewID
	FROM CancerGovStaging..TSTopics  ts
	where EditableTopicSearchTerm like '%' + @MacroName + '%'	

	/*
	** Create notified parties 
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

	
	SELECT @vTitle = left(MacroName,50) from TSMacros where MacroID = @MacroID

	select @tName = t.name, @sName = s.name from task t, taskstep s
	where t.taskID = @taskID and t.taskID = s.taskID and s.stepID = @stepID

	
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
	
	update TSMacros
	set Status = 'Edit'
	where MacroID = @MacroID
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_DisAproveViewEdit
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 
	
	insert into NCIMessage
	(SenderID, RecipientID, Subject, Message, Status)	
	values
	(@sendID, @receiveID, 'Macro Edit Approval Request Denied', 'Macro Edit Approval Request Denied for ' + 
	@vTitle + ' In Task "' + @tName + '" and Step "' + @sName + '"', 'Posted')
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_DisAproveViewEdit
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END

	-- Update staging macro back to status in Edit ----MacroValue = (select MacroValue from CancerGov..TSMacros where MacroID = @MacroID), 
	UPDATE CancerGovStaging..TSMacros
	SET Status ='EDIT'
	WHERE macroID = @MacroID
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_DisAproveViewEdit
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END

	/*
	* Roll back all changes for Macro, terms and nciview. 
	*/
	-- update nciview on staging status back to 'EDIT'

	UPDATE cnv
	SET 	status ='EDIT'
	FROM 	CancerGovStaging..NCIView cnv, #TempTSTopic tts
	WHERE tts.nciviewid =cnv.nciviewid
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_DisAproveViewEdit
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END
	
	drop table  #TempTSTopic
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
GRANT EXECUTE ON [dbo].[usp_disApproveMacroEdit] TO [webadminuser_role]
GO
