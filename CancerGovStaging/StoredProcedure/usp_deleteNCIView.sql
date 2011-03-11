IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_deleteNCIView]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_deleteNCIView]
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
**  This procedure will attempt to delete an nciview from the system (authoring 
**  and production) and all of its dependent objects.  This procedure will 
**  validate the arguments and ensure the delete is valid.  Otherwise it will 
**  return one of the error values identified below.  This procedure will not 
**  handle recursion of lists at this time, If this is needed before a data model 
**  change Ask me and I will update this script (and the delete viewobject script).
**
**  NOTE:  I am not handleing deletion PDQ_DOCS on purpose in order to avoid inadvertent
**           deletion of PDQ production style data.  This data should be deleted manually.
**         This procedure is ment to be used as a queue action, because it does not resolve
**           any references to this document it assumes these references have been removed
**           or authorized for removal so it will remove them if encountered.
**
**  Issues:  
**      Finally should we check at the end of this script for orphaned "add a link" views 
**        and delete them
**
**  Author: M.P. Brady 10-29-01
**  Revision History:
**  M.P. Brady 11-02-01   Added support for view object types TXTINCLUDE, NAVLIST, HELPLIST, NEWSCENTER,
**     LIVEHELP, PDQLIST, and TIPLIST.  Also correct bug in failure to remove Lists one of from viewobjects.
**  M.P. Brady 12-18-01   Added support for view object type IMAGE, and view object types NEWSCENTER and LIVEHELP
**     were removed from system.
**  Jay He	02-28-2002	Added deletion for summary
**  Jay He	03-19-2002	Added deletion for pretty url
**  Jay He	09-24-2002        Added view object property deletion function and viewobject "Search" deletion function
**
**  Return Values
**  0         Success
**  70001     One of the Guid's provided was not a valid NCIViewID
**  70002     Deleteing a view that is being linked to by a list
**  70003     Deleteing a view that represents a summary
**  70004     Error performing one of the SQL commands actions should be rolled back
**
*/
CREATE PROCEDURE [dbo].[usp_deleteNCIView] 
	(
	@delView uniqueidentifier,
	@UpdateUserID varchar(50) = 'system'  -- Not Used but must support for step command processing
	)
AS
BEGIN	
	SET NOCOUNT ON
	
	/*
	** We always want to operate against the staging/ authoring database first
	** USE CancerGovStaging (statement not allowed
	*/
	
	/*
	** STEP - A
	** First Validate that the guid provided is valid
	** if not return and 70001 error
	*/		
	if(	
	  (@delView IS NULL) OR (NOT EXISTS (SELECT NCIViewID FROM CancerGovStaging..NCIView WHERE NCIViewID = @delView)) 
	  )	
	BEGIN
		RAISERROR ( 70001, 16, 1)
		RETURN 70001
	END

	/*
	** STEP - B
	** First make sure we are not trying to delete a view that is being pointed to.
	** If so we better have a "newView" to point the links to.  Otherwise get out and
	** return 70002 as the error code
	
	IF (
		EXISTS (SELECT * FROM CancerGovStaging..listitem WHERE NCIViewID = @delView) 
		OR 
		EXISTS (SELECT * FROM CancerGovStaging..list WHERE NCIViewID = @delView)
	   )
	BEGIN
		RAISERROR ( 70002, 16, 1)
		RETURN 70002
	END 
	*/
	
	/* -- We will delete summary - Jay He
	** STEP - C
	** Verify we are not trying to delete a summary view
	
	IF (EXISTS (SELECT NCIViewID FROM CancerGovStaging..viewobjects WHERE NCIViewID = @delView and type = 'SUMMARY'))
	BEGIN
		RAISERROR ( 70003, 16, 1)
		RETURN 70003
	END
	*/

	DECLARE @NCIViewObjectID uniqueidentifier,
		@ObjectID uniqueidentifier,
		@ObjectType	char(10),
		@returnStatus int,
		@Type varchar(20),
		@ObjectInstanceID uniqueidentifier
		
	BEGIN TRAN Tran_DeleteNCIView
		--- Delete nciobjects section mapping first
		if(	
		  EXISTS (SELECT NCIObjectID FROM CancerGovStaging..NCIObjects WHERE NCIObjectID = @delView and ObjectType='LEFTNAV')
		  )	
		BEGIN
			delete from CancerGovStaging..NCIObjects WHERE NCIObjectID =@delView and ObjectType='LEFTNAV'
			IF (@@ERROR <> 0)
			BEGIN
				ROLLBACK TRAN Tran_DeleteNCIView
				RAISERROR ( 70004, 16, 1)
				RETURN 70004
			END 
		END

		-- Delete Newsletter issue mapping first
		if(	
		  EXISTS (SELECT NCIViewID FROM CancerGovStaging..NLIssue WHERE NCIViewID = @delView)
		  )	
		BEGIN
			delete from CancerGovStaging..NLIssue WHERE NCIViewID = @delView
			IF (@@ERROR <> 0)
			BEGIN
				ROLLBACK TRAN Tran_DeleteNCIView
				RAISERROR ( 70004, 16, 1)
				RETURN 70004
			END 
		END

		/*
		** STEP - D
		** Now that we have started and we know that the refernces to this page should be
		** gone, so we will remove any that are still present
		*/
		DELETE FROM CancerGovStaging..listItem WHERE NCIViewID = @delView
		UPDATE CancerGovStaging..list SET NCIViewID = NULL WHERE NCIViewID = @delView
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN Tran_DeleteNCIView
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 

		/*
		** STEP - E
		** Ok We now need to cycle through all of the viewobjects that this 
		** view represents.  Depending on the "type" we will be required to 
		** perform the following actions.
		** INCLUDE, XMLINCLUDE, PDF:  Just Delete viewobject entry
		** HDRDOC, DOCUMENT: Delete the entry "objectid" from document table
		**  then delete the viewobject entry
		** HDRLIST, LIST: Look for 1 level of child lists.  If child lists 
		**  Delete all listitems contained by them, then delete the child
		**  lists.  Delete all list items contained by the viewobject list
		**  "objectid", delete list, then delete the viewobject entry.
		** IMAGE: Delete the entry "objectid" from the image table then 
		**  delete the viewobject entry
		*/
	
		DECLARE ViewObject_Cursor CURSOR FORWARD_ONLY  FOR
			SELECT 	NCIViewObjectID, ObjectID, Type
			FROM 	CancerGovStaging..ViewObjects
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
			IF @@FETCH_STATUS = -2  -- Missing a row we need to fail on the delete
			BEGIN
				ROLLBACK TRAN Tran_DeleteNCIView
				DEALLOCATE ViewObject_Cursor 
				RAISERROR ( 70002, 16, 1)
				RETURN 70002
			END

			IF (@ObjectType = 'DOCUMENT' and exists (Select P.PropertyValue from ViewObjects V, ViewObjectProperty P Where V.ObjectID=@ObjectID  and V.NCIViewObjectID = P.NCIViewObjectID and P.PropertyName ='DigestRelatedListID'))
			BEGIN
			
				PRINT '--EXEC  @return_status= usp_DeleteDigestDocList ''' + Convert(varchar(36), @ObjectID) +'<br>'
				EXEC  	@returnStatus= usp_DeleteDigestDocList @ObjectID
			
				IF (@returnStatus <> 0)
				BEGIN
					ROLLBACK TRAN Tran_DeleteNCIViewObject
					RAISERROR ( 70100, 16, 1)
					RETURN 70100
				END 	
				PRINT '--returstatus =' + convert(varchar(1), @returnStatus) +'<br>'
			END

			/* Delete view object property 
			*/
			Delete from CancerGovStaging..viewobjectproperty where NCIViewObjectID = @NCIViewObjectID
			IF (@@ERROR <> 0)
			BEGIN
				ROLLBACK TRAN Tran_DeleteNCIView
				DEALLOCATE ViewObject_Cursor 
				RAISERROR ( 70002, 16, 1)
				RETURN 70002
			END	
 
			-- Push Each Object
			IF (@ObjectType = 'LIST' or @ObjectType = 'HDRLIST'
			OR @ObjectType = 'NAVLIST' or @ObjectType = 'HELPLIST'
			OR @ObjectType = 'PDQLIST' or @ObjectType = 'TIPLIST')
			BEGIN
				/*
				** Delete Child List Items
				*/
				delete from CancerGovStaging..listitem
				where listid in (select listid from CancerGovStaging..list
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
				delete from CancerGovStaging..list
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
				delete from CancerGovStaging..listitem
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
				delete from CancerGovStaging..list
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
			IF (	@ObjectType = 'DOCUMENT' or @ObjectType = 'HDRDOC'
				 or @ObjectType = 'NAVDOC' or @ObjectType = 'SEARCH'  or @ObjectType = 'VIRSEARCH' 
				 or @ObjectType = 'TOC' or @ObjectType = 'DETAILTOC' 
				  or @ObjectType = 'INCLUDE' or @ObjectType = 'TXTINCLUDE' )
			BEGIN
				/* Delete docpart if object is DOC in OESI template
				*/
				delete from CancerGovStaging..docpart
				where documentid = @ObjectID

				/*
				** Delete document item for the viewobject document
				*/
				delete from CancerGovStaging..document
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
			IF (@ObjectType = 'IMAGE')
			BEGIN
				/*
				** Delete image item for the viewobject image
				*/
				delete from CancerGovStaging..image
				where imageid = @ObjectID
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
			IF (@ObjectType = 'TSTOPIC')
			BEGIN
				/*
				** Delete topic item for the viewobject image
				*/
				delete from CancerGovStaging..TSTopics
				where topicid = @ObjectID
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
			IF (@ObjectType = 'LINK')
			BEGIN
				
				-- Delete topic item for the viewobject image
				
				delete from CancerGovStaging..Link
				where linkid = @ObjectID
				
				-- Check Status
				
				IF (@@ERROR <> 0)
				BEGIN
					ROLLBACK TRAN Tran_DeleteNCIView
					DEALLOCATE ViewObject_Cursor 
					RAISERROR ( 70004, 16, 1)
					RETURN 70004
				END 	
			END  */
			IF (	@ObjectType = 'ANIMATION'
				or  @ObjectType = 'AUDIO'
				or @ObjectType = 'PHOTO')
			BEGIN
				/*
				** Delete eXternalobject item for the viewobject 
				*/
				delete from  CancerGovStaging..ExternalObject
				where ExternalObjectid = @ObjectID
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
			IF (@ObjectType = 'EFormSCode'
				or  @ObjectType = 'EFormWCode'
				or @ObjectType = 'EFormSHelp'
				or @ObjectType = 'EFormWHelp')
			BEGIN
				/*
				** Delete EFormSegment item for the viewobject summary
				*/
				delete from CancerGovStaging..EFormsSegments
				where Segmentid = @ObjectID
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
			IF (@ObjectType = 'NLLIST ')
			BEGIN
				/*
				** Delete Child List Items
				*/
				delete from CancerGovStaging..listitem
				where listid in (select listid from CancerGovStaging..list
				  where parentlistid = @ObjectID)
				IF (@@ERROR <> 0)
				BEGIN
					ROLLBACK TRAN Tran_DeleteNCIView
					DEALLOCATE ViewObject_Cursor 
					RAISERROR ( 70004, 16, 1)
					RETURN 70004
				END 
			
				delete from CancerGovStaging..NLlistitem
				where listid in (select listid from CancerGovStaging..list
				 where parentlistid = @ObjectID)
				IF (@@ERROR <> 0)
				BEGIN
					ROLLBACK TRAN Tran_DeleteNCIView
					DEALLOCATE ViewObject_Cursor 
					RAISERROR ( 70004, 16, 1)
					RETURN 70004
				END 

				delete from CancerGovStaging..list
				where parentlistid = @ObjectID
				IF (@@ERROR <> 0)
				BEGIN
					ROLLBACK TRAN Tran_DeleteNCIView
					DEALLOCATE ViewObject_Cursor 
					RAISERROR ( 70004, 16, 1)
					RETURN 70004
				END 

				delete from CancerGovStaging..NLlistitem
				where listid = @ObjectID
				IF (@@ERROR <> 0)
				BEGIN
					ROLLBACK TRAN Tran_DeleteNCIView
					DEALLOCATE ViewObject_Cursor 
					RAISERROR ( 70004, 16, 1)
					RETURN 70004
				END 

				delete from CancerGovStaging..list
				where listid = @ObjectID
				IF (@@ERROR <> 0)
				BEGIN
					ROLLBACK TRAN Tran_DeleteNCIView
					DEALLOCATE ViewObject_Cursor 
					RAISERROR ( 70004, 16, 1)
					RETURN 70004
				END  
			END
			IF (@ObjectType = 'NLSECTION'  )
			BEGIN
				/*
				** Delete NLSection item for the viewobject document
				*/
				delete from CancerGovStaging..NLSection
				where NLSectionID = @ObjectID
				IF (@@ERROR <> 0)
				BEGIN
					ROLLBACK TRAN Tran_DeleteNCIView
					DEALLOCATE ViewObject_Cursor 
					RAISERROR ( 70004, 16, 1)
					RETURN 70004
				END  
			END 
			ELSE IF (@ObjectType = 'INFOBOX'  )
			BEGIN
				/*
				** Delete infobox -- NCIObjects/NCIobjectProperty/List/Image/Doc
				*/

				if (exists (select ObjectType from NCIObjects where ParentNCIObjectID = @ObjectID ))
				BEGIN
					--Loop through each child nciobject for leftnav

					DECLARE NCIObject_Cursor CURSOR LOCAL FORWARD_ONLY  FOR
					SELECT  ObjectType , ObjectInstanceID
					from 	CancerGovStaging..NCIObjects 
					where ParentNCIObjectID = @ObjectID
					FOR READ ONLY 
					IF (@@ERROR <> 0)
					BEGIN
						DEALLOCATE ViewObject_Cursor
						ROLLBACK TRAN   Tran_DeleteNCIView
						RAISERROR ( 70004, 16, 1)
						RETURN 70004
					END 
			
					OPEN NCIObject_Cursor 
					IF (@@ERROR <> 0)
					BEGIN
						DEALLOCATE NCIObject_Cursor 
						Close  ViewObject_Cursor
						DEALLOCATE ViewObject_Cursor
						ROLLBACK TRAN  Tran_DeleteNCIView
						RAISERROR ( 70004, 16, 1)		
						RETURN 70004
					END 
			
					FETCH NEXT FROM NCIObject_Cursor
					INTO 	 @Type, @ObjectInstanceID
	
					WHILE @@FETCH_STATUS = 0
					BEGIN		
	
						PRINT '--EXEC  @return_status= usp_deleteNCIObject ''' + Convert(varchar(36), @ObjectID) +'<br>'
						EXEC  	@returnStatus= usp_DeleteNCIObject @ObjectInstanceID, @Type, 'websiteuser'
				
						IF (@returnStatus <> 0)
						BEGIN
							Close  NCIObject_Cursor
							DEALLOCATE NCIObject_Cursor
							Close  ViewObject_Cursor
							DEALLOCATE ViewObject_Cursor 
							ROLLBACK TRAN  Tran_DeleteNCIView
							RAISERROR ( 70004, 16, 1)
							RETURN 70004
						END 	
					
						FETCH NEXT FROM NCIObject_Cursor
						INTO 	@Type, @ObjectInstanceID
					END
		
					CLOSE  NCIObject_Cursor 
					DEALLOCATE NCIObject_Cursor 		
				END
			END 
			/*
			** We will leave the viewobjects alone for now and do the
			** delete of all the viewobjects at once
			*/
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
		delete from CancerGovStaging..viewobjects
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
		** Delete relevant viewproperty record from the viewproperty table for this
		** view.
		*/
		delete from CancerGovStaging..viewproperty
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
		** Delete relevant pretty url record from the pretty url  table for this
		** view.
		*/
		delete from CancerGovStaging..prettyurl 
		where nciviewid = @delView
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN Tran_DeleteNCIView
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 

		/*
		** Finally we get to delete the view from the view table
		*/
		delete from CancerGovStaging..nciview
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
		** Now that we are done with the Staging/ Authoring data we need to delete the production/ 
		** publishing data
		** 	USE CancerGov (statement not allowed)
		*/
		
		/*
		** STEP - F
		** If we find a view clean it up otherwise fall through and get out.  Remember
		** Any errors in here will require to transactions to rollback.
		*/		
		if(	
		  (EXISTS (SELECT NCIViewID FROM CancerGov..NCIView WHERE NCIViewID = @delView)) 
		  )	
		BEGIN
	
			--- Delete nciobjects section mapping first
			if(	
			  EXISTS (SELECT NCIObjectID FROM CancerGov..NCIObjects WHERE NCIObjectID = @delView and ObjectType='LEFTNAV')
			  )	
			BEGIN
				delete from CancerGov..NCIObjects WHERE NCIObjectID =@delView and ObjectType='LEFTNAV'
				IF (@@ERROR <> 0)
				BEGIN
					ROLLBACK TRAN Tran_DeleteNCIView
					RAISERROR ( 70004, 16, 1)
					RETURN 70004
				END 
			END
			/*
			** STEP - B
			** First make sure we are not trying to delete a view that is being pointed to.
			** If so we better have a "newView" to point the links to.  Otherwise get out and
			** return 70002 as the error code
			
			IF (
				EXISTS (SELECT * FROM CancerGov..listitem WHERE NCIViewID = @delView) 
				OR 
				EXISTS (SELECT * FROM CancerGov..list WHERE NCIViewID = @delView)
			   )
			BEGIN
				RAISERROR ( 70002, 16, 1)
				RETURN 70002
			END 
			*/
	
			/*
			** STEP - G  -- we do delete summary now - Jay He
			** Verify we are not trying to delete a summary view
			
			IF (EXISTS (SELECT NCIViewID FROM CancerGov..viewobjects WHERE NCIViewID = @delView and type = 'SUMMARY'))
			BEGIN
				ROLLBACK TRAN Tran_DeleteNCIView
				RAISERROR ( 70003, 16, 1)
				RETURN 70003
			END
			*/
		
			/*
			** STEP - H
			** Now that we have started and we know that the refernces to this page should be
			** gone, so we will remove any that are still present
			*/
			DELETE FROM CancerGov..listItem WHERE NCIViewID = @delView
			IF (@@ERROR <> 0)
			BEGIN
				ROLLBACK TRAN Tran_DeleteNCIView
				RAISERROR ( 70004, 16, 1)
				RETURN 70004
			END 
			
			UPDATE CancerGov..list SET NCIViewID = NULL WHERE NCIViewID = @delView
			IF (@@ERROR <> 0)
			BEGIN
				ROLLBACK TRAN Tran_DeleteNCIView
				RAISERROR ( 70004, 16, 1)
				RETURN 70004
			END 
					

			/*
			** Delete relevant pretty url record from the redirectmap table first for this view
			** We need to do delete from Redirect..map here sicne we need the mapping for pdq object in summary table before it is deleted
			** delete from Redirect..RedirectMap
			** where currentURL in (select currentURL from cancergov..prettyurl where NCIViewID =@delView)
			
			IF (@ObjectType = 'SUMMARY')
			BEGIN
				delete from CancerGov..RedirectMap
				where currentURL in (select currentURL from cancergov..prettyurl where NCIViewID =@delView) 
					or currentURL like ( select  '/Templates/' + T.URL + IsNull(NullIf( '?'+IsNull(N.URLArguments,''),'?'),'') from cancergov..NCITemplate T, cancergov..NCIView N 
							where T.NCITemplateID=N.NCITemplateID and N.NCIViewID =@delView) +'%'
					or currentURL like  '%' + ( select 'summaryid='  + Isnull(Convert(varchar(50), S.sourceID),'')  from 
									CancerGov..summary S, CancerGov..ViewObjects V 
								where S.summaryID = V.ObjectID and V.NCIViewID = @delView )
				
				** Check Status
				
				IF (@@ERROR <> 0)
				BEGIN
					ROLLBACK TRAN Tran_DeleteNCIView
					RAISERROR ( 70004, 16, 1)
					RETURN 70004
				END
			END
			ELSE
			BEGIN
				delete from CancerGov..RedirectMap
				where currentURL in (select currentURL from cancergov..prettyurl where NCIViewID =@delView) 
					or currentURL like ( select  '/Templates/' + T.URL + IsNull(NullIf( '?'+IsNull(N.URLArguments,''),'?'),'') from cancergov..NCITemplate T, cancergov..NCIView N 
							where T.NCITemplateID=N.NCITemplateID and N.NCIViewID =@delView) +'%'
				
				** Check Status
				
				IF (@@ERROR <> 0)
				BEGIN
					ROLLBACK TRAN Tran_DeleteNCIView
					RAISERROR ( 70004, 16, 1)
					RETURN 70004
				END
			END 
			*/

			-- We get rid of Summary since prettyurl won't have 'summaryid=' in it
			delete from CancerGov..RedirectMap
			where currentURL in (select currentURL from cancergov..prettyurl where NCIViewID =@delView) 
				or currentURL like ( select  '/Templates/' + T.URL + IsNull(NullIf( '?'+IsNull(N.URLArguments,''),'?'),'') from cancergov..NCITemplate T, cancergov..NCIView N 
						where T.NCITemplateID=N.NCITemplateID and N.NCIViewID =@delView) +'%'
				
			--Check Status
				
			IF (@@ERROR <> 0)
			BEGIN
				ROLLBACK TRAN Tran_DeleteNCIView
				RAISERROR ( 70004, 16, 1)
				RETURN 70004
			END

			/*
			** Delete relevant pretty url record from the prettyURL table for this
			** view.
			*/
			delete from CancerGov..prettyurl
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
			** STEP - I
			** Ok We now need to cycle through all of the viewobjects that this 
			** view represents.  Depending on the "type" we will be required to 
			** perform the following actions.
			** INCLUDE, XMLINCLUDE, PDF:  Just Delete viewobject entry
			** HDRDOC, DOCUMENT: Delete the entry "objectid" from document table
			**  then delete the viewobject entry
			** HDRLIST, LIST: Look for 1 level of child lists.  If child lists 
			**  Delete all listitems contained by them, then delete the child
			**  lists.  Delete all list items contained by the viewobject list
			**  "objectid", delete list, then delete the viewobject entry.

			** IMAGE: Delete the entry "objectid" from the image table then 
			**  delete the viewobject entry
			*/
		
			DECLARE PubViewObject_Cursor CURSOR FORWARD_ONLY  FOR
				SELECT 	NCIViewObjectID, ObjectID, Type
				FROM 	CancerGov..ViewObjects
				WHERE  	NCIViewID = @delView 	
			FOR READ ONLY 
			IF (@@ERROR <> 0)
			BEGIN
				ROLLBACK TRAN Tran_DeleteNCIView
				RAISERROR ( 70004, 16, 1)
				RETURN 70004
			END 
	
			OPEN PubViewObject_Cursor 
			IF (@@ERROR <> 0)
			BEGIN
				ROLLBACK TRAN Tran_DeleteNCIView
				DEALLOCATE PubViewObject_Cursor 
				RAISERROR ( 70004, 16, 1)
				RETURN 70004
			END 
				
			FETCH NEXT FROM PubViewObject_Cursor
			INTO 	@NCIViewObjectID, @ObjectID, @ObjectType	
				
			WHILE @@FETCH_STATUS != -1   -- Fetch success is 0, failure is -1, and missing row is -2
			BEGIN
				IF @@FETCH_STATUS = -2  -- Missing a row we need to fail on the delete
				BEGIN
					ROLLBACK TRAN Tran_DeleteNCIView
					DEALLOCATE PubViewObject_Cursor 
					RAISERROR ( 70002, 16, 1)
					RETURN 70002
				END
	 
				IF (@ObjectType = 'DOCUMENT' and exists (Select P.PropertyValue from CancerGov..ViewObjects V, CancerGov..ViewObjectProperty P Where V.ObjectID=@ObjectID  and V.NCIViewObjectID = P.NCIViewObjectID and P.PropertyName ='DigestRelatedListID'))
				BEGIN
			
					PRINT '--EXEC  @return_status= usp_CheckRedirectMap ''' + Convert(varchar(36), @ObjectID) +'<br>'
					EXEC  	@returnStatus= usp_DeleteDigestDocListForProduction @ObjectID
			
					IF (@returnStatus <> 0)
					BEGIN
						ROLLBACK TRAN Tran_DeleteNCIViewObject
						RAISERROR ( 70100, 16, 1)
						RETURN 70100
					END 	
					PRINT '--returstatus =' + convert(varchar(1), @returnStatus) +'<br>'
				END

				/* Delete view object property 
				*/
				Delete from CancerGov..viewobjectproperty where NCIViewObjectID = @NCIViewObjectID
				IF (@@ERROR <> 0)
				BEGIN
					ROLLBACK TRAN Tran_DeleteNCIView
					DEALLOCATE ViewObject_Cursor 
					RAISERROR ( 70002, 16, 1)
					RETURN 70002
				END	
 
				-- Push Each Object
				IF (@ObjectType = 'LIST' or @ObjectType = 'HDRLIST'
				OR @ObjectType = 'NAVLIST' or @ObjectType = 'HELPLIST'
				OR @ObjectType = 'PDQLIST' or @ObjectType = 'TIPLIST')
				BEGIN
					/*
					** Delete Child List Items
					*/
					delete from CancerGov..listitem
					where listid in (select listid from CancerGov..list
					  where parentlistid = @ObjectID)
					/*
					** Check Status
					*/
					IF (@@ERROR <> 0)
					BEGIN
						ROLLBACK TRAN Tran_DeleteNCIView
						DEALLOCATE PubViewObject_Cursor 
						RAISERROR ( 70004, 16, 1)
						RETURN 70004
					END 
					/*
					** Delete child Lists
					*/
					delete from CancerGov..list
					where parentlistid = @ObjectID
					/*
					** Check Status
					*/
					IF (@@ERROR <> 0)
					BEGIN
						ROLLBACK TRAN Tran_DeleteNCIView
						DEALLOCATE PubViewObject_Cursor 
						RAISERROR ( 70004, 16, 1)
						RETURN 70004
					END 
					/*
					** Delete List items for the viewobject List
					*/
					delete from CancerGov..listitem
					where listid = @ObjectID
					/*
					** Check Status
					*/
					IF (@@ERROR <> 0)
					BEGIN
						ROLLBACK TRAN Tran_DeleteNCIView
						DEALLOCATE PubViewObject_Cursor 
						RAISERROR ( 70004, 16, 1)
						RETURN 70004
					END 
					/*
					** Delete List
					*/
					delete from CancerGov..list
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
				IF (@ObjectType = 'DOCUMENT' or @ObjectType = 'HDRDOC' 
				or @ObjectType = 'NAVDOC' or @ObjectType = 'SEARCH'  or @ObjectType = 'VIRSEARCH' 
				or @ObjectType = 'INCLUDE' or @ObjectType = 'TXTINCLUDE' 
				or @ObjectType = 'TOC' or @ObjectType = 'DETAILTOC' )
				BEGIN
					/*
					** Delete document item for the viewobject document
					*/
					delete from CancerGov..document
					where documentid = @ObjectID
					/*
					** Check Status
					*/
					IF (@@ERROR <> 0)
					BEGIN
						ROLLBACK TRAN Tran_DeleteNCIView
						DEALLOCATE PubViewObject_Cursor 
						RAISERROR ( 70004, 16, 1)
						RETURN 70004
					END 	
				END 
				IF (@ObjectType = 'IMAGE')
				BEGIN	
					/*
					** Delete image item for the viewobject image
					*/
					delete from CancerGov..image
					where imageid = @ObjectID
					/*
					** Check Status
					*/
					IF (@@ERROR <> 0)
					BEGIN
						ROLLBACK TRAN Tran_DeleteNCIView
						DEALLOCATE PubViewObject_Cursor 
						RAISERROR ( 70004, 16, 1)
						RETURN 70004
						END 	
				END 
				IF (@ObjectType = 'TSTOPIC')
				BEGIN	
					/*
					** Delete image item for the viewobject image
					*/
					delete from CancerGov..TSTOPICs
					where topicid = @ObjectID
					/*
					** Check Status
					*/
					IF (@@ERROR <> 0)
					BEGIN
						ROLLBACK TRAN Tran_DeleteNCIView
						DEALLOCATE PubViewObject_Cursor 
						RAISERROR ( 70004, 16, 1)
						RETURN 70004
						END 	
				END
				/* 
				IF (@ObjectType = 'LINK')
				BEGIN	
					
					-- Delete image item for the viewobject image
					
					delete from CancerGov..LINK
					where linkid = @ObjectID
					
					-- Check Status
					
					IF (@@ERROR <> 0)
					BEGIN
						ROLLBACK TRAN Tran_DeleteNCIView
						DEALLOCATE PubViewObject_Cursor 
						RAISERROR ( 70004, 16, 1)
						RETURN 70004
					END 	
				END */
				IF (	@ObjectType = 'ANIMATION'
					or  @ObjectType = 'AUDIO'
					or @ObjectType = 'PHOTO')
				BEGIN
				/*
				** Delete eXternalobject item for the viewobject 
				*/
					delete from  CancerGov..ExternalObject
					where ExternalObjectid = @ObjectID
					/*
					** Check Status
					*/
					IF (@@ERROR <> 0)
					BEGIN
						ROLLBACK TRAN Tran_DeleteNCIView
						DEALLOCATE PubViewObject_Cursor 
						RAISERROR ( 70004, 16, 1)
						RETURN 70004
					END 	
				END 
				IF (@ObjectType = 'EFormSCode'
					or  @ObjectType = 'EFormWCode'
					or @ObjectType = 'EFormSHelp'
					or @ObjectType = 'EFormWHelp')
				BEGIN
					/*
					** Delete EFormSegment item for the viewobject summary
					*/
					delete from CancerGov..EFormsSegments
					where Segmentid = @ObjectID
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
				IF (@ObjectType = 'NLLIST ')
				BEGIN
					/*
					** Delete Child List Items
					*/
					delete from CancerGov..listitem
					where listid in (select listid from CancerGov..list
					  where parentlistid = @ObjectID)
					IF (@@ERROR <> 0)
					BEGIN
						ROLLBACK TRAN Tran_DeleteNCIView
						DEALLOCATE ViewObject_Cursor 
						RAISERROR ( 70004, 16, 1)
						RETURN 70004
					END 
			
					delete from CancerGov..NLlistitem
					where listid in (select listid from CancerGov..list
					 where parentlistid = @ObjectID)
					IF (@@ERROR <> 0)
					BEGIN
						ROLLBACK TRAN Tran_DeleteNCIView
						DEALLOCATE ViewObject_Cursor 
						RAISERROR ( 70004, 16, 1)
						RETURN 70004
					END 

					delete from CancerGov..list
					where parentlistid = @ObjectID
					IF (@@ERROR <> 0)
					BEGIN
						ROLLBACK TRAN Tran_DeleteNCIView
						DEALLOCATE ViewObject_Cursor 
						RAISERROR ( 70004, 16, 1)
						RETURN 70004
					END 

					delete from CancerGov..NLlistitem
					where listid = @ObjectID
					IF (@@ERROR <> 0)
					BEGIN
						ROLLBACK TRAN Tran_DeleteNCIView
						DEALLOCATE ViewObject_Cursor 
						RAISERROR ( 70004, 16, 1)
						RETURN 70004
					END 

					delete from CancerGov..list
					where listid = @ObjectID
					IF (@@ERROR <> 0)
					BEGIN
						ROLLBACK TRAN Tran_DeleteNCIView
						DEALLOCATE ViewObject_Cursor 
						RAISERROR ( 70004, 16, 1)
						RETURN 70004
					END  
				END
				IF (@ObjectType = 'NLSECTION'  )
				BEGIN
					/*
					** Delete NLSection item for the viewobject document
					*/
					delete from CancerGov..NLSection
					where NLSectionID = @ObjectID
					IF (@@ERROR <> 0)
					BEGIN
						ROLLBACK TRAN Tran_DeleteNCIView
						DEALLOCATE ViewObject_Cursor 
						RAISERROR ( 70004, 16, 1)
						RETURN 70004
					END  
				END 
				ELSE IF (@ObjectType = 'INFOBOX'  )
				BEGIN
					/*
					** Delete infobox -- NCIObjects/NCIobjectProperty/List/Image/Doc
					*/
					if (exists (select ObjectType from CancerGov..NCIObjects where ParentNCIObjectID = @ObjectID))
					BEGIN

						--Loop through each child nciobject for leftnav
	
						DECLARE NCIObject_Cursor CURSOR LOCAL FORWARD_ONLY  FOR
						SELECT  ObjectType , ObjectInstanceID
						from 	CancerGov..NCIObjects 
						where ParentNCIObjectID = @ObjectID
						FOR READ ONLY 
						IF (@@ERROR <> 0)
						BEGIN
							DEALLOCATE ViewObject_Cursor
							ROLLBACK TRAN   Tran_DeleteNCIView
							RAISERROR ( 70004, 16, 1)
							RETURN 70004
						END 
				
						OPEN NCIObject_Cursor 
						IF (@@ERROR <> 0)
						BEGIN
							DEALLOCATE NCIObject_Cursor 
							Close  ViewObject_Cursor
							DEALLOCATE ViewObject_Cursor
							ROLLBACK TRAN  Tran_DeleteNCIView
							RAISERROR ( 70004, 16, 1)		
							RETURN 70004
						END 
				
						FETCH NEXT FROM NCIObject_Cursor
						INTO 	 @Type, @ObjectInstanceID
		
						WHILE @@FETCH_STATUS = 0
						BEGIN		
		
							PRINT '--EXEC  @return_status= usp_deleteNCIObjectForProd ''' + Convert(varchar(36), @ObjectID) +'<br>'
							EXEC  	@returnStatus= usp_DeleteNCIObjectForProduction @ObjectInstanceID, @Type, 'websiteuser'
			
							IF (@returnStatus <> 0)
							BEGIN
								Close NCIObject_Cursor
								DEALLOCATE NCIObject_Cursor
								Close  ViewObject_Cursor
								DEALLOCATE ViewObject_Cursor 
								ROLLBACK TRAN  Tran_DeleteNCIView
								RAISERROR ( 70004, 16, 1)
								RETURN 70004
							END 	
						
							FETCH NEXT FROM NCIObject_Cursor
							INTO 	@Type, @ObjectInstanceID
						END
			
						CLOSE  NCIObject_Cursor 
						DEALLOCATE NCIObject_Cursor 		
					END
				END 

				/*
				** We will leave the viewobjects alone for now and do the
				** delete of all the viewobjects at once
				*/
				-- GET NEXT OBJECT
				FETCH NEXT FROM PubViewObject_Cursor
				INTO 	@NCIViewObjectID, @ObjectID, @ObjectType	
			END	

			CLOSE PubViewObject_Cursor 
			DEALLOCATE PubViewObject_Cursor

			/*
			** Delete viewobjects from the viewobjects table for this
			** view.
			*/
			delete from CancerGov..viewobjects
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
			** Delete relevant viewproperty record from the viewproperty table for this
			** view.
			*/
			delete from CancerGov..viewproperty
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
			delete from CancerGov..nciview
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

				
		END  -- End the Delete of the Publishing view (it existed)

	COMMIT TRAN Tran_DeleteNCIView

	SET NOCOUNT OFF
	RETURN 0 
END

GO
GRANT EXECUTE ON [dbo].[usp_deleteNCIView] TO [webadminuser_role]
GO
