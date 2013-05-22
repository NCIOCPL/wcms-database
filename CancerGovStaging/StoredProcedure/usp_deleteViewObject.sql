IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_deleteViewObject]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_deleteViewObject]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



--***********************************************************************
-- Create New Object 
--************************************************************************

/****** Object:  Stored Procedure dbo.usp_RetrieveViewObject
   Owner:Jhe Purpose: For admin side Script Date: 1/15/2002 16:00:49 pm ******/

/*
**  This procedure will attempt to delete a view object from the system.  This will remove
**  the viewobject entry and all other child elements that reside in the database system. This
**  means that we will be using an external process for cleaning files off the server that are
**  not currently being used.
**
**  NOTE:  At the time of creation this stored procedure handled the following 
**         viewobjects in its deletion logic
**	   HDRDOC, INCLUDE, XMLINCLUDE, LIST, HDRLIST, DOCUMENT, PDF
**         I am not handleing SUMMARY on purpose in order to avoid inadvertent
**         deletion of PDQ production style data.  This data should be deleted manually.
**
**  Issues:  
**      Finally should we check at the end of this script for orphaned "add a link" views and delete them
**
**  Author: M.P. Brady 11-01-01
**  Revision History:
**  M.P. Brady 11-02-01   Added support for view object types TXTINCLUDE, NAVLIST, HELPLIST, NEWSCENTER,
**     LIVEHELP, PDQLIST, and TIPLIST.  Also correct bug in failure to remove Lists one of from viewobjects.
**  Jay He 	02-28-02 Added deletion of Summary
**  Jay He	12-23-2003 Adde update status to Edit for the nciview this vo belongs to
**
**  Return Values
**  0         Success
**  70001     The guid argument was invalid
**  70003     ViewObject being deleted was a SUMMARY/ PDQ_DOC
**  70004     Failed during execution of deletion
**  70100 	Failed during exeuction of deleting digest page document object property DigestDocList
*/
CREATE PROCEDURE [dbo].[usp_deleteViewObject] 
	(
	@delObj uniqueidentifier   -- Note this is the guid for NCIViewObjectID
	)
AS
BEGIN	
	SET NOCOUNT ON
	/*
	** STEP - A
	** First Validate that the guid provided is valid
	** if not return and 70001 error
	*/		
	if(	
	  (@delObj IS NULL) OR (NOT EXISTS (SELECT NCIViewID FROM viewobjects WHERE NCIViewObjectID = @delObj)) 
	  )	
	BEGIN
		RAISERROR ( 70001, 16, 1)
		RETURN 70001
	END
	
	/*  We implement the deletion of summary since we have summary table in cancergovstaging table - Jay
	** STEP - C  
	** Verify we are not trying to delete a summary view
	
	IF (EXISTS (SELECT NCIViewObjectID FROM viewobjects WHERE NCIViewObjectID = @delObj and type = 'SUMMARY'))
	BEGIN
		RAISERROR ( 70003, 16, 1)
		RETURN 70003
	END
	*/

	DECLARE @ObjectID uniqueidentifier,
		@ObjectType	char(10),
		@returnStatus	int

	BEGIN TRAN Tran_DeleteNCIViewObject
		/*
		** STEP - E
		** Ok now we need to delete view object and all its clild elements.
		** Depending on the "type" we will be required to perform the 
		** following actions.
		** INCLUDE, XMLINCLUDE, PDF:  Just Delete viewobject entry
		** HDRDOC, DOCUMENT: Delete the entry "objectid" from document table
		**  then delete the viewobject entry
		** HDRLIST, LIST: Look for 1 level of child lists.  Delete all child 
		**  lists contained by them, then delete the child lists.
		**  Delete all list items contained by the viewobject list
		**  "objectid", delete list, then delete the viewobject entry.
		*/
	
		select @ObjectID = objectID, @ObjectType = type 
		from viewobjects
		where NCIViewObjectID = @delObj
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN Tran_DeleteNCIViewObject
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 
	
		IF (@ObjectType = 'DOCUMENT' and exists (Select P.PropertyValue from ViewObjects V, ViewObjectProperty P Where V.ObjectID=@ObjectID  and V.NCIViewObjectID = P.NCIViewObjectID and P.PropertyName ='DigestRelatedListID'))
		BEGIN
			
			PRINT '--EXEC  @return_status= usp_DeleteDigestDocList ''' + Convert(varchar(36), @ObjectID) +'<br>'
			EXEC  	@returnStatus= usp_DeleteDigestDocList @ObjectID
			
			IF (@returnStatus <> 0)
			BEGIN
				ROLLBACK TRAN Tran_DeleteNCIViewObject
				RAISERROR ( 70004, 16, 1)
				RETURN 70004
			END 	
			PRINT '--returstatus =' + convert(varchar(1), @returnStatus) +'<br>'
		END
		
		/* Delete view object property 
		*/
		Delete from viewobjectproperty where NCIViewObjectID = @delObj
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN Tran_DeleteNCIViewObject
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 

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
				ROLLBACK TRAN Tran_DeleteNCIViewObject
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
				ROLLBACK TRAN Tran_DeleteNCIViewObject
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
				ROLLBACK TRAN Tran_DeleteNCIViewObject
				RAISERROR ( 70004, 16, 1)
				RETURN 70004
			END 	
			Print '1'
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
				ROLLBACK TRAN Tran_DeleteNCIViewObject
				RAISERROR ( 70004, 16, 1)
				RETURN 70004
			END 
		END
		ELSE IF (@ObjectType = 'DOCUMENT' or @ObjectType = 'HDRDOC' 
		or @ObjectType = 'NAVDOC' or @ObjectType = 'SEARCH'  or @ObjectType = 'VIRSEARCH' 
		or @ObjectType = 'TOC' or 	 @ObjectType = 'DETAILTOC' 
		or @ObjectType = 'INCLUDE' or @ObjectType = 'TXTINCLUDE' )
		BEGIN
			/*
			** Delete document item for the viewobject document
			*/
			delete from document
			where documentid = @ObjectID
			IF (@@ERROR <> 0)
			BEGIN
				ROLLBACK TRAN Tran_DeleteNCIViewObject
				RAISERROR ( 70004, 16, 1)
				RETURN 70004
			END 	
		END 
		ELSE IF (@ObjectType = 'IMAGE')
		BEGIN
			/*
			** Delete image item for the viewobject image
			*/
			delete from [image]
			where imageid = @ObjectID
			/*
			** Check Status
			*/
			IF (@@ERROR <> 0)
			BEGIN
				ROLLBACK TRAN Tran_DeleteNCIViewObject
				RAISERROR ( 70004, 16, 1)
				RETURN 70004
			END 	
		END 
		ELSE IF (@ObjectType = 'TSTOPIC')
		BEGIN
			/*
			** Delete topic search item for the viewobject image
			*/
			delete from TSTopics
			where topicid = @ObjectID
			/*
			** Check Status
			*/
			IF (@@ERROR <> 0)
			BEGIN
				ROLLBACK TRAN Tran_DeleteNCIViewObject
				RAISERROR ( 70004, 16, 1)
				RETURN 70004
			END 	
		END 
		/*IF (@ObjectType = 'LINK')
		BEGIN
			
			--** Delete image item for the viewobject image
			
			delete from LINK
			where Linkid = @ObjectID
			
			--** Check Status
			
			IF (@@ERROR <> 0)
			BEGIN
				ROLLBACK TRAN Tran_DeleteNCIViewObject
				RAISERROR ( 70004, 16, 1)
				RETURN 70004
			END 	
		END */
		ELSE IF (	@ObjectType = 'EFormSCode'
			or  @ObjectType = 'EFormWCode'
			or @ObjectType = 'EFormSHelp'
			or @ObjectType = 'EFormWHelp')
		BEGIN
			/*
			** Delete EFormSegment item for the viewobject 
			*/
			delete from [EFormsSegments]
			where Segmentid = @ObjectID
			/*
			** Check Status
			*/
			IF (@@ERROR <> 0)
			BEGIN
				ROLLBACK TRAN Tran_DeleteNCIViewObject
				RAISERROR ( 70004, 16, 1)
				RETURN 70004
			END 	
		END 
		ELSE IF (	@ObjectType = 'ANIMATION'
			or  @ObjectType = 'AUDIO'
			or @ObjectType = 'PHOTO')
		BEGIN
			/*
			** Delete eXternalobject item for the viewobject 
			*/
			delete from ExternalObject
			where ExternalObjectid = @ObjectID
			/*
			** Check Status
			*/
			IF (@@ERROR <> 0)
			BEGIN
				ROLLBACK TRAN Tran_DeleteNCIViewObject
				RAISERROR ( 70004, 16, 1)
				RETURN 70004
			END 	
		END 
		ELSE IF (@ObjectType = 'NLLIST ')
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
				ROLLBACK TRAN Tran_DeleteNCIViewObject
				RAISERROR ( 70004, 16, 1)
				RETURN 70004
			END 
			/*
			** Delete Child List Items
			*/
			delete from NLlistitem
			where listid in (select listid from list
			  where parentlistid = @ObjectID)
			/*
			** Check Status
			*/
			IF (@@ERROR <> 0)
			BEGIN
				ROLLBACK TRAN Tran_DeleteNCIViewObject
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
				ROLLBACK TRAN Tran_DeleteNCIViewObject
				RAISERROR ( 70004, 16, 1)
				RETURN 70004
			END 
			/*
			** Delete List items for the viewobject List
			*/
			delete from NLlistitem
			where listid = @ObjectID
			/*
			** Check Status
			*/
			IF (@@ERROR <> 0)
			BEGIN
				ROLLBACK TRAN Tran_DeleteNCIViewObject
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
				ROLLBACK TRAN Tran_DeleteNCIViewObject
				RAISERROR ( 70004, 16, 1)
				RETURN 70004
			END 
		END
		ELSE IF (@ObjectType = 'NLSECTION'  )
		BEGIN
			/*
			** Delete NLSection item for the viewobject document
			*/
			delete from NLSection
			where NLSectionID = @ObjectID
			IF (@@ERROR <> 0)
			BEGIN
				ROLLBACK TRAN Tran_DeleteNCIViewObject
				RAISERROR ( 70004, 16, 1)
				RETURN 70004
			END 	


		END 
		ELSE IF (@ObjectType = 'INFOBOX'  )
		BEGIN
			/*
			** Delete infobox -- NCIObjects/NCIobjectProperty/List/Image/Doc
			*/
			if (exists (select ObjectType from NCIObjects where ParentNCIObjectID = @ObjectID) )
			BEGIN
				Declare @Type varchar(20),
					@ObjectInstanceID uniqueidentifier

				--Loop through each child nciobject for leftnav

				DECLARE ViewObject_Cursor CURSOR LOCAL FORWARD_ONLY  FOR
				SELECT  ObjectType , ObjectInstanceID
				from 	CancerGovStaging..NCIObjects 
				where ParentNCIObjectID = @ObjectID
				FOR READ ONLY 
				IF (@@ERROR <> 0)
				BEGIN
					ROLLBACK TRAN  Tran_DeleteNCIViewObject
					RAISERROR ( 70004, 16, 1)
					RETURN 70004
				END 
		
				OPEN ViewObject_Cursor 
				IF (@@ERROR <> 0)
				BEGIN
					DEALLOCATE ViewObject_Cursor 
					ROLLBACK TRAN  Tran_DeleteNCIViewObject
					RAISERROR ( 70004, 16, 1)		
					RETURN 70004
				END 
		
				FETCH NEXT FROM ViewObject_Cursor
				INTO 	 @Type, @ObjectInstanceID

				WHILE @@FETCH_STATUS = 0
				BEGIN		

					PRINT '--EXEC  @return_status= usp_deleteNCIObject ''' + Convert(varchar(36), @ObjectID) +'<br>'
					EXEC  	@returnStatus= usp_DeleteNCIObject @ObjectInstanceID, @Type, 'websiteuser'
			
					IF (@returnStatus <> 0)
					BEGIN
						Close  ViewObject_Curso
						DEALLOCATE ViewObject_Cursor 
						ROLLBACK TRAN Tran_DeleteNCIViewObject
						RAISERROR ( 70004, 16, 1)
						RETURN 70004
					END 	
				
					FETCH NEXT FROM ViewObject_Cursor 
					INTO 	@Type, @ObjectInstanceID
			
				END
			
				CLOSE ViewObject_Cursor 
				DEALLOCATE ViewObject_Cursor 
			END
		END 

		/*
		** Delete viewobject from the viewobjects table 
		*/
		delete from viewobjects
		where NCIViewObjectID = @delObj
		/*
		** Check Status
		*/
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN Tran_DeleteNCIViewObject
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 	

		Update NCIView
		Set 	status ='EDIT'
		where nciviewid = (SELECT NCIViewID FROM viewobjects WHERE NCIViewObjectID = @delObj)
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN Tran_DeleteNCIViewObject
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 	
	
	COMMIT TRAN Tran_DeleteNCIViewObject

	SET NOCOUNT OFF
	RETURN 0 

END

GO
GRANT EXECUTE ON [dbo].[usp_deleteViewObject] TO [gatekeeper_role]
GO
GRANT EXECUTE ON [dbo].[usp_deleteViewObject] TO [webadminuser_role]
GO
