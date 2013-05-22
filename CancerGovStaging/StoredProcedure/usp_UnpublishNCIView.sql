IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_UnpublishNCIView]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_UnpublishNCIView]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[usp_UnpublishNCIView] 
	(
	@delView uniqueidentifier,
	@UpdateUserID varchar(50) = 'system'  -- Not Used but must support for step command processing
	)
AS
BEGIN	
	SET NOCOUNT ON
	
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
	
	
		BEGIN TRAN Tran_DeleteNCIView
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
		
		
		DECLARE @NCIViewObjectID uniqueidentifier,
		@ObjectID uniqueidentifier,
		@ObjectType	char(10),
		@returnStatus int,
		@Type varchar(20),
		@ObjectInstanceID uniqueidentifier
		
		
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

			COMMIT TRAN Tran_DeleteNCIView
				
		END  -- End the Delete of the Publishing view (it existed)

	

		update cancergovstaging.dbo.nciview
		set status = 'UNPUBLISH', isOnProduction =0, updateuserid = @updateuserid, updateDate = getDate()
		where nciviewid = @delView
 
		update cancergovstaging.dbo.PrettyURL
		set ProposedURL= CurrentURL,
			CurrentURL='',
			updateuserid = @updateuserid, updateDate = getDate()
		where nciviewid = @delView and CurrentURL is not null
	
	RETURN 0 
END

GO
GRANT EXECUTE ON [dbo].[usp_UnpublishNCIView] TO [webadminuser_role]
GO
