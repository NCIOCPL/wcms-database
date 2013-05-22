IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_sendMessage]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_sendMessage]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/*
**  This procedure is a general purpose function that will insert a given 
**    message in to all the users in group x with permission of type y's
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
CREATE PROCEDURE [dbo].[usp_sendMessage] 
	(
	@groupID  int,                -- Group to send message to
	@permissionID int,  -- Permission ID to further define whom to send message to
	@subject varchar(255),        -- Subject of the Message to send
	@message varchar(4000),       -- Body of the message sent
	@RequesterUserID varchar(50),    -- This should be the username as it appears in NCIUsers table
	@UpdateUserID varchar(50) = 'system'   -- Used to set the updateuserid in message table
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
	select @sendID = userID from NCIusers where loginName = @RequesterUserID
	IF (@@ERROR <> 0 or @sendID is null)
	BEGIN
		RAISERROR ( 70001, 16, 1)
		RETURN 70001
	END 	
		
	BEGIN TRAN Tran_SendMessage
			
	/*
	** Note Now look up the users to send the message to
	*/
 	
	DECLARE User_Cursor CURSOR FORWARD_ONLY  FOR
	SELECT 	DISTINCT userID
	FROM 	UserGroupPermissionMap
	where groupID = @GroupID
	and permissionID  = @permissionID
	FOR READ ONLY 
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_SendMessage
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 
	
	OPEN User_Cursor 
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_SendMessage
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
			(@sendID, @receiveID, @subject, @message, 'Posted', @UpdateUserID)
			IF (@@ERROR <> 0)
			BEGIN
				ROLLBACK TRAN Tran_SendMessage
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
	
	COMMIT TRAN Tran_SendMessage
	
	SET NOCOUNT OFF
	RETURN 0 

END
GO
GRANT EXECUTE ON [dbo].[usp_sendMessage] TO [webadminuser_role]
GO
