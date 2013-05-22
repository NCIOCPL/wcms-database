IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_MikesCleanupdeleteNCIView]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_MikesCleanupdeleteNCIView]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
/*
**  This procedure will attempt to delete an nciview from the system and all
**  of its dependent objects.  This procedure will validate the arguments and 
**  ensure the delete is valid.  Other wise it will return one of the 
**  error values identified below.  This procedure will not handle recursion of 
**  lists at this time, If this is needed before a data model change Ask me and
**  I will update this script.
**
**  NOTE:  At the time of creation this stored procedure handled the following 
**         viewobjects in its deletion logic
**	   HDRDOC, INCLUDE, XMLINCLUDE, LIST, HDRLIST, DOCUMENT, PDF
**         I am not handleing SUMMARY on purpose in order to avoid inadvertent
**         deletion of PDQ production style data.  This data should be deleted manually.
**
**  Issues:  
**      We need to figure out how to remove files associacted with a view on the
**         the file system if delete is being done against prublishing side of production data.
**      Need to support messageing to groups of users if item is requested to be deleted / redirected
**         and email messageing (email) to groups of users if view is deleted / redirected even if this
**         means deleteing of links on other pages.  If this messageing can be done in the proc great
**         otherwise we need to support returning of a list of userid's to notify from this proc.
**      Finally should we check at the end of this script for orphaned "add a link" views and delete them
**
**  Author: M.P. Brady 10-29-01
**  Revision History:
**  M.P. Brady 11-02-01   Added support for view object types TXTINCLUDE, NAVLIST, HELPLIST, NEWSCENTER,
**     LIVEHELP, PDQLIST, and TIPLIST.  Also correct bug in failure to remove Lists one of from viewobjects.
**
**  Return Values
**  0         Success
**  70001     One of the Guid's provided was not a valid NCIViewID
**  70002     Deleteing a view that is being linked to with out declaring a
**            new view to redirect the links to
**  70003     Deleteing a view that represents a summary
**  70004     Error performing one of the SQL commands actions should be rolled back
**
*/
CREATE PROCEDURE [dbo].[usp_MikesCleanupdeleteNCIView] 
	(
	@delView uniqueidentifier,
	@UpdateUserID varchar(50),
	@newView uniqueidentifier    /* View to reassign all links to the delete view to */ 
	)
AS
BEGIN	
	SET NOCOUNT ON
	/*
	** STEP - A
	** First Validate that both of the guids provided are valid
	** if not return and 70001 error
	*/		
	if(	
	  (@delView IS NULL) OR (NOT EXISTS (SELECT NCIViewID FROM NCIView WHERE NCIViewID = @delView)) 
	  OR  
	  (@newView IS NOT NULL) AND (NOT EXISTS (SELECT NCIViewID FROM NCIView WHERE NCIViewID = @newView))
	  )	
	BEGIN
		RAISERROR ( 70001, 16, 1)
		RETURN 70001
	END

	/*
	** STEP - B
	** First make sure we are not trying to delete a view that is being pointed to.
	** If so we better have a "newView" to point the links to.  Otherwise get out and
	** return 70001 as the error code
	IF (
		(
		EXISTS (SELECT * FROM listitem WHERE NCIViewID = @delView) 
		OR 
		EXISTS (SELECT * FROM list WHERE NCIViewID = @delView)
		)
	   and @newView IS NULL
	   )
	BEGIN
		RAISERROR ( 70002, 16, 1)
		RETURN 70002
	END 
	*/
	
	/*
	** STEP - C
	** Verify we are not trying to delete a summary view
	*/
	IF (EXISTS (SELECT NCIViewID FROM viewobjects WHERE NCIViewID = @delView and type = 'SUMMARY'))
	BEGIN
		RAISERROR ( 70003, 16, 1)
		RETURN 70003
	END

	DECLARE @NCIViewObjectID uniqueidentifier,
		@ObjectID uniqueidentifier,
		@ObjectType	char(10)
	DECLARE @ChildListID uniqueidentifier

	BEGIN TRAN Tran_DeleteNCIView
		/*
		** STEP - D
		** First before we go to crazzy with the deleteing lets reassign the viewid's
		** in existing lists to the new viewid
		*/
		if (@newView is not null)
		BEGIN
			update 	listitem
			set 	nciviewid = @newView
			where 	nciviewid = @delView
			/*
			** Check Status
			*/
			IF (@@ERROR <> 0)
			BEGIN
				ROLLBACK TRAN Tran_DeleteNCIView
				RAISERROR ( 70004, 16, 1)
				RETURN 70004
			END 
	
			UPDATE 	List
			SET 	NCIViewID = @newView
			WHERE 	nciviewid = @delView
			/*
			** Check Status
			*/
			IF (@@ERROR <> 0)
			BEGIN
				ROLLBACK TRAN Tran_DeleteNCIView
				RAISERROR ( 70004, 16, 1)
				RETURN 70004
			END 
		END
		ELSE BEGIN
			/*
			** STEP - D.1	
			** Now we need to null out the page behind for lists if
			** delView is used in that manner
			*/
			update 	list
			set 	nciviewid = null
			where 	nciviewid = @delView
			/*
			** Check Status
			*/
			IF (@@ERROR <> 0)
			BEGIN
				ROLLBACK TRAN Tran_DeleteNCIView
				RAISERROR ( 70004, 16, 1)
				RETURN 70004
			END 

			DELETE listitem
			where 	nciviewid = @delView
			/*
			** Check Status
			*/
			IF (@@ERROR <> 0)
			BEGIN
				ROLLBACK TRAN Tran_DeleteNCIView
				RAISERROR ( 70004, 16, 1)
				RETURN 70004
			END 
		END 			
	
		/*
		** STEP - E
		** Ok We now need to cycle through all of the viewobjects that this 
		** view represents.  Depending on the "type" we will be required to 
		** perform the following actions.
		** INCLUDE, XMLINCLUDE, PDF, TXTINCLUDE, NEWSCENTER, LIVEHELP:  
		**  Just Delete viewobject entry
		** HDRDOC, DOCUMENT: Delete the entry "objectid" from document table
		**  then delete the viewobject entry
		** HDRLIST, LIST, NAVLIST, HELPLIST, PDQLIST, TIPLIST: Look for 1 
		**  level of child lists.  If child lists 
		**  Delete all listitems contained by them, then delete the child
		**  lists.  Delete all list items contained by the viewobject list
		**  "objectid", delete list, then delete the viewobject entry.
		*/
		DECLARE ViewObject_Cursor CURSOR FORWARD_ONLY  FOR
			SELECT 	NCIViewObjectID, ObjectID, Type
			FROM 	ViewObjects
			WHERE  	NCIViewID = @delView 	
		FOR READ ONLY 
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN Tran_DeleteNCIView
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 
	
		OPEN ViewObject_Cursor 
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN Tran_DeleteNCIView
			DEALLOCATE ViewObject_Cursor 
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 
			
		FETCH NEXT FROM ViewObject_Cursor
		INTO 	@NCIViewObjectID, @ObjectID, @ObjectType	
			
		WHILE @@FETCH_STATUS != -1   -- Fetch success is 0, failure is -1, and missing row is -2
		BEGIN
			IF @@FETCH_STATUS = 0
			BEGIN  -- This is a valid row
				-- Push Each Object
				IF (@ObjectType = 'LIST' or @ObjectType = 'HDRLIST'
				or @ObjectType = 'NAVLIST' or @ObjectType = 'HELPLIST'
				or @ObjectType = 'PDQLIST' or @ObjectType = 'TIPLIST')
				BEGIN
					/*
					** Delete Child List Items
					*/
					delete from listitem
					where listid in (select listid from list
					  where parentlistid = @ObjectID)
					/*
					** Check Status
					*/
					IF (@@ERROR <> 0)
					BEGIN
						ROLLBACK TRAN Tran_DeleteNCIView
							DEALLOCATE ViewObject_Cursor 
						RAISERROR ( 70004, 16, 1)
						RETURN 70004
					END 
					/*
					** Delete child Lists
					*/
					delete from list
					where parentlistid = @ObjectID
					/*
					** Check Status
					*/
					IF (@@ERROR <> 0)
					BEGIN
						ROLLBACK TRAN Tran_DeleteNCIView
						DEALLOCATE ViewObject_Cursor 
						RAISERROR ( 70004, 16, 1)
						RETURN 70004
					END 
					/*
					** Delete List items for the viewobject List
					*/
					delete from listitem
					where listid = @ObjectID
					/*
					** Check Status
					*/
					IF (@@ERROR <> 0)
					BEGIN
						ROLLBACK TRAN Tran_DeleteNCIView
						DEALLOCATE ViewObject_Cursor 
						RAISERROR ( 70004, 16, 1)
						RETURN 70004
					END 
					/*
					** Delete List
					*/
					delete from list
					where listid = @ObjectID
					/*
					** Check Status
					*/
					IF (@@ERROR <> 0)
					BEGIN
						ROLLBACK TRAN Tran_DeleteNCIView
						DEALLOCATE ViewObject_Cursor 
						RAISERROR ( 70004, 16, 1)
						RETURN 70004
					END 
				END
				IF (@ObjectType = 'DOCUMENT' or @ObjectType = 'HDRDOC')
				BEGIN
					/*
					** Delete document item for the viewobject document
					*/
					delete from document
					where documentid = @ObjectID
					/*
					** Check Status
					*/
					IF (@@ERROR <> 0)
					BEGIN
						ROLLBACK TRAN Tran_DeleteNCIView
						DEALLOCATE ViewObject_Cursor 
						RAISERROR ( 70004, 16, 1)
						RETURN 70004
					END 	
				END 
				/*
				** We will leave the viewobjects alone for now and do the
				** delete of all the viewobjects at once
				*/
			END
			-- GET NEXT OBJECT
			FETCH NEXT FROM ViewObject_Cursor
			INTO 	@NCIViewObjectID, @ObjectID, @ObjectType	
		END

		-- CLOSE ViewObject_Cursor		
		CLOSE ViewObject_Cursor 
		DEALLOCATE ViewObject_Cursor 

		/*
		** Delete viewobjects from the viewobjects table for this
		** view.
		*/
		delete from viewobjects
		where nciviewid = @delView
		/*
		** Check Status
		*/
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN Tran_DeleteNCIView
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 	
	
		/*
		** Finally we get to delete the view from the view table
		*/
		delete from nciview
		where nciviewid = @delView
		/*
		** Check Status
		*/
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN Tran_DeleteNCIView
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 		
	COMMIT TRAN Tran_DeleteNCIView

	SET NOCOUNT OFF
	RETURN 0 

END
GO
