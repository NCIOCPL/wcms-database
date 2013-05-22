IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_BatchPushNCIView20040525]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_BatchPushNCIView20040525]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_BatchPushNCIView20040525]
AS
BEGIN	
	SET NOCOUNT ON

	Declare @NCIViewID uniqueidentifier,
		@ShortTitle varchar(50),
		@updateuserID varchar(50),
		@return_status int

	select @updateuserID = '20040525BatchUpdateViewStatus'


	-- New on preview and not on production, status='Edit' and isonproduction=0

	BEGIN TRAN  Tran_BatchUpdate

	DECLARE ViewObject_Cursor CURSOR LOCAL FORWARD_ONLY  FOR
	SELECT NCIViewID , ShortTitle 
	FROM NCIView
	Where Isonproduction=0 and Status= 'EDIT'	
	FOR READ ONLY 
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_BatchUpdate
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 
		
	OPEN ViewObject_Cursor 
	IF (@@ERROR <> 0)
	BEGIN
		DEALLOCATE ViewObject_Cursor 
		ROLLBACK TRAN Tran_BatchUpdate
		RAISERROR ( 70004, 16, 1)		
		RETURN 70004
	END 
		
	FETCH NEXT FROM ViewObject_Cursor
	INTO 	@NCIViewID, 	@ShortTitle

	WHILE @@FETCH_STATUS = 0
	BEGIN
		Update nciview 
		set status='Submit' ,
		    updateuserID = @UpdateUserID,
		    updatedate = getdate()
		where nciviewid= @NCIViewID
		IF (@@ERROR <> 0)
		BEGIN
			CLOSE ViewObject_Cursor 
			DEALLOCATE ViewObject_Cursor 
			ROLLBACK TRAN   Tran_BatchUpdate
			RAISERROR ( 70006, 16, 1)
			RETURN  70006
		END 
		
		PRINT '--EXEC  @return_status= usp_pushnciviewtoproduction ' +  Convert(varchar(36), @NCIViewID) + ' , '  + @UpdateUserID
		EXEC  	@return_status = usp_pushnciviewtoproduction @NCIViewID, @UpdateUserID
						
		PRINT 'Page ' + @ShortTitle + '--return value=    ' + Convert(varchar(60), @return_status)
		

		-- GET NEXT OBJECT
		PRINT '-- '
		FETCH NEXT FROM ViewObject_Cursor
		INTO 	@NCIViewID, 	@ShortTitle	

	END -- End while
	
	-- CLOSE ViewObject_Cursor		
	CLOSE ViewObject_Cursor 
	DEALLOCATE ViewObject_Cursor 
 
	Commit TRAN   Tran_BatchUpdate

	SET NOCOUNT OFF
	RETURN 0

END

GO
