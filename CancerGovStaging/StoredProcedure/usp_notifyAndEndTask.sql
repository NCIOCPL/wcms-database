IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_notifyAndEndTask]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_notifyAndEndTask]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/*
**  This procedure is a general purpose function that will insert a given 
**    message in to all the users in group x with permission of type y and
**    also set the Task Status to completed
**
**  NOTE: Could not get a list stored in PermissionList/ ID, so bailed on it
**    for now
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
CREATE PROCEDURE [dbo].[usp_notifyAndEndTask] 
	(
	@taskID  uniqueidentifier,    -- Task to mark as failed
	@groupID  int,                -- Group to send message to
	@message varchar(4000),       -- Body of the message sent
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
	   (NOT EXISTS (SELECT groupID FROM groups WHERE groupID = @groupID))
	   OR 
	   (NOT EXISTS (SELECT TaskID FROM Task where TaskID = @taskID))
	  )	
	BEGIN
		RAISERROR ( 70001, 16, 1)
		RETURN 70001
	END

	DECLARE @sendID uniqueidentifier,
		@receiveID uniqueidentifier
	
	/*
	** This is a procedure used only as an automatic step, so sender should
	** always be system
	*/	
	select @sendID = userID from NCIusers where loginName = 'system'
	
	BEGIN TRAN Tran_NotifyAndComplete
	
	update task
	set Status = 'Completed',
	UpdateUserID = @UpdateUserID,
	UpdateDate = getdate()
	where TaskID = @taskID
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_NotifyAndComplete
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 
			
	/*
	** Note Now look up the users to send the message to
	*/
 	
	DECLARE User_Cursor CURSOR FORWARD_ONLY  FOR
	SELECT 	DISTINCT userID
	FROM 	UserGroupPermissionMap
	where groupID = @GroupID
	and permissionID  = '1'   -- All the members of the group
	FOR READ ONLY 
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_NotifyAndComplete
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 
	
	OPEN User_Cursor 
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_NotifyAndComplete
		DEALLOCATE User_Cursor 
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 
		
	FETCH NEXT FROM User_Cursor
	INTO 	@receiveID	
	
	WHILE @@FETCH_STATUS != -1   -- Fetch success is 0, failure is -1, and missing row is -2
	BEGIN
		/*
		** Do not try to insert a message on an missing row. Just skip and move on
		** No reason to report an error on this one this time
		*/
		IF @@FETCH_STATUS != -2  -- Missing a row we need to fail on the delete
		BEGIN
			insert into NCIMessage
			(SenderID, RecipientID, Subject, Message, Status, UpdateUserID)	
			values
			(@sendID, @receiveID, 'Task Completed', @message, 'Posted', @UpdateUserID)
			IF (@@ERROR <> 0)
			BEGIN
				ROLLBACK TRAN Tran_NotifyAndComplete
				DEALLOCATE User_Cursor 
				RAISERROR ( 70004, 16, 1)
				RETURN 70004
			END
		END

		-- GET NEXT OBJECT
		FETCH NEXT FROM User_Cursor
		INTO 	@receiveID	
	END

	-- CLOSE ViewObject_Cursor		
	CLOSE User_Cursor 
	DEALLOCATE User_Cursor 
	
	COMMIT TRAN Tran_NotifyAndComplete
	
	SET NOCOUNT OFF
	RETURN 0 

END
GO
GRANT EXECUTE ON [dbo].[usp_notifyAndEndTask] TO [webadminuser_role]
GO
