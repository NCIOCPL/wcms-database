IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_PushInfoBoxToProduction]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_PushInfoBoxToProduction]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



--***********************************************************************
-- Create New Object 
--************************************************************************
/****** 	Object:  Stored Procedure dbo.usp_InsertViewObject    
	Purpose: This script can be used for  inserting view objects property value.	Script Date: 8/13/2003 11:43:49 pM 
*
*	Get ObjectID from Viewobjects
*		|
*	Get each NCIObjectID from NCIObjects where ParentNCIObjectID = ObjectID 
*		|	
*	First Remove any NCIObjects on Prod but no on Staging (incl. related list/image/navdoc/listitem)
*		|
*	Decide by each type 
* 		\
*		  \List -- 
*		  \IMAGE
*		  \NavDoc
*
*	EXEC sp_addmessage 80200, 16, N' CancerGov Error. InfoBox related nciobject doesn't exist.','us_english', true,replace
*	EXEC sp_addmessage 80202, 16, N' CancerGov Error. Unable to push this nciobject image to production','us_english', true,replace
*	EXEC sp_addmessage 80203, 16, N' CancerGov Error. Unable to push this nciobject list Simple-link page (%s in "Approved" status) to production','us_english', true,replace
*	EXEC sp_addmessage 80204, 16, N' CancerGov Error. Unable to push this  nciobject  list item''s Simple-link page (%s in "EDIT"status) to production. Please push it first','us_english', true,replace
*	EXEC sp_addmessage 80205, 16, N' CancerGov Error. Unable to push this  nciobject List item''s page not on production (%s is not a Simple-link page) to production','us_english', true,replace
*	EXEC sp_addmessage 80205, 16, N' CancerGov Error. Unable to push this  nciobject List  on production (%s is not a Simple-link page) to production','us_english', true,replace
*	EXEC sp_addmessage 80206, 16, N' CancerGov Error. Unable to push this nciobject navdoc to production','us_english', true,replace
*	EXEC sp_addmessage 80201, 16, N' CancerGov Error. Unable to push this nciobject property to production','us_english', true,replace
*		
******/

CREATE PROCEDURE dbo.usp_PushInfoBoxToProduction
(
	@ObjectID			UniqueIdentifier, 
	@UpdateUserID 		varchar(50)
)
AS
BEGIN
	SET NOCOUNT ON;

	Declare @ObjectInstanceID 	UniqueIdentifier,
		@NCIObjectID 		UniqueIdentifier,
		@NCIViewID 		UniqueIdentifier,
		@ShortTitle		varchar(50),
		@Type			varchar(50),
		@PropertyName		varchar(50),
		@PropertyValue		varchar(7800),
		@UpdateDate		Datetime,
		@ReturnStatus 		int,
		@OldObjectInstanceID 	UniqueIdentifier,
		@OldType		varchar(10)

	select @UpdateDate = getdate()

	Print 'Begin usp_PushInfoBoxToProduction' + convert(varchar(36), @ObjectID) +'<br> ' + Convert(varchar(2), @@TRANCOUNT) 

	if(	
	  (@ObjectID IS NULL) OR (NOT EXISTS (Select  objectID from CancerGovStaging..ViewObjects Where ObjectID = @ObjectID))
	  )	
	BEGIN
		RAISERROR ( 80200, 16, 1)
		RETURN 
	END

	-- Return to the main sp when there is no related nciobject for this infobox viewobject
	if(	
	NOT EXISTS (Select  NCIobjectID from CancerGovStaging..NCIObjects Where ParentNCIObjectID = @ObjectID)
	  )	
	BEGIN
		RETURN 0
	END

	-- Loop through each child view object

	DECLARE NCIObject_Cursor CURSOR LOCAL FORWARD_ONLY  FOR

	SELECT  ObjectType ,  NCIObjectID, ObjectInstanceID
	from 	CancerGovStaging..NCIObjects 
	where ParentNCIObjectID = @ObjectID
	FOR READ ONLY 

	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_PushNCIViewToProduction
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 

	OPEN NCIObject_Cursor 
	IF (@@ERROR <> 0)
	BEGIN
		DEALLOCATE NCIObject_Cursor 
		ROLLBACK TRAN Tran_PushNCIViewToProduction
		RAISERROR ( 70004, 16, 1)		
		RETURN 70004
	END 

	FETCH NEXT FROM NCIObject_Cursor
	INTO 	 @Type, @NCIObjectID, @ObjectInstanceID

	WHILE @@FETCH_STATUS = 0
	BEGIN	

		/* Delete nciobject which is on prod but not on staging. 
		*   Include List, ListItem, Image, NavDoc and NCIObjectProperty
		*/

		DECLARE OldObjects_Cursor  CURSOR FOR 
		SELECT 	ObjectInstanceID, ObjectType
		FROM 	CancerGov..NCIObjects 
		WHERE 	ParentNCIObjectID = @ObjectID
			AND ObjectInstanceID NOT IN (
						SELECT 	ObjectInstanceID
						FROM 	CancerGovStaging..NCIObjects 
						WHERE 	ParentNCIObjectID = @ObjectID
						)

		
		OPEN OldObjects_Cursor 
		IF (@@ERROR <> 0)
		BEGIN
			DEALLOCATE OldObjects_Cursor 
			Close NCIObject_Cursor 
			DEALLOCATE NCIObject_Cursor 
			ROLLBACK TRAN Tran_PushNCIViewToProduction
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 

		FETCH NEXT FROM OldObjects_Cursor  
		INTO @ObjectInstanceID, @OldType
		
		WHILE @@FETCH_STATUS = 0
		BEGIN
	
			-- Delete Non-existing NCIobejct's Property on production 
			SELECT @ReturnStatus = 0
			EXECUTE @ReturnStatus = [CancerGovStaging]..[usp_DeleteNCIObjectForProduction]   @ObjectInstanceID, @OldType, @UpdateUserID 
			if (@ReturnStatus <>0 )
			BEGIN
				CLOSE OldObjects_Cursor 
				DEALLOCATE OldObjects_Cursor  
				RAISERROR ( 80102, 16, 1)
				RETURN  
			END 	
	
			FETCH NEXT FROM OldObjects_Cursor  
			INTO @ObjectInstanceID, @OldType
		END
		
		CLOSE OldObjects_Cursor 
		DEALLOCATE OldObjects_Cursor 


		/*
		** Add a parentlist
		*/	
		
		if (@Type ='LIST')
		BEGIN
			Print 'Insert List with ListID =' + Convert(varchar(36), @NCIObjectID)
	
			IF (not EXISTS (SELECT * FROM CancerGov..List WHERE  ListID = @NCIObjectID ))
			BEGIN
				Insert into CancerGov..List
				(ListID, GroupID, ListName,ListDesc,URL,ParentListID,NCIViewID,Priority, UpdateDate,UpdateUserID,DescDisplay, ReleaseDateDisplay, ReleaseDateDisplayLoc)
				select ListID, GroupID, ListName,ListDesc,URL,ParentListID,NCIViewID,Priority, UpdateDate,UpdateUserID,DescDisplay, ReleaseDateDisplay, ReleaseDateDisplayLoc
				from CancerGovStaging..List
				where listid = @NCIObjectID
				IF (@@ERROR <> 0)
				BEGIN
					RAISERROR ( 80102, 16, 1)
					RETURN 
				END
			END
			ELSE
			BEGIN
				PRint 'Delete listitem on prod non-existing on staging'
				
				Delete from CancerGov..ListItem where listid = @NCIObjectID and NCIViewID not in (
					select NCIViewID from cancergovstaging..ListItem where ListID = @NCIObjectID
					)
	
				Update P
				set	P.GroupID	= S.GroupID, 
					P.ListName	= S.ListName,
					P.ListDesc	= S.ListDesc,
					P.URL		= S.URL,
					P.ParentListID	= S.ParentListID,
					P.NCIViewID	= S.NCIViewID,
					P.Priority	= S.Priority, 
					P.UpdateDate	= S.UpdateDate,
					P.UpdateUserID	= S.UpdateUserID,
					P.DescDisplay	= S.DescDisplay, 
					P.ReleaseDateDisplay	= S.ReleaseDateDisplay, 
					P.ReleaseDateDisplayLoc	= S.ReleaseDateDisplayLoc
				From CancerGov..List P, CancerGovStaging..List S
				where P.ListID = S.ListId and S.listid = @NCIObjectID
				IF (@@ERROR <> 0)
				BEGIN
					RAISERROR ( 80102, 16, 1)
					RETURN 
				END
			END		 

			-- insert each listitem 
			DECLARE VO_Cursor CURSOR LOCAL FORWARD_ONLY  FOR
			SELECT 	NCIViewID
			FROM 		CancerGovStaging..Listitem
			Where 		ListID = @NCIObjectID
			FOR READ ONLY 
			IF (@@ERROR <> 0)
			BEGIN
				RAISERROR ( 70004, 16, 1)
				RETURN 
			END 
			
			OPEN VO_Cursor 
			IF (@@ERROR <> 0)
			BEGIN
				DEALLOCATE VO_Cursor 
				RAISERROR ( 70004, 16, 1)		
				RETURN 
			END 
			
			FETCH NEXT FROM VO_Cursor
			INTO 	 @NCIViewID
	
			WHILE @@FETCH_STATUS = 0
			BEGIN
				-- Check whether NCIViewID is on CancerGov. If not, raise error.
				if (not exists (select * from CancerGov..NCIView where NCIViewID = @NCIViewID))
				BEGIN
					-- without templateID
					Print 'NCIView not exists on cancergov ' + Convert(varchar(36), @NCIViewID)
					IF (EXISTS (SELECT * FROM CancerGovStaging..NCIView WHERE  NCIViewID = @NCIViewID and NCITemplateID is null )) 
					BEGIN				
						Print 'Push simple-view with "Approved" status.'			
						Select @ShortTitle =ShortTitle from  CancerGovStaging..NCIView WHERE  NCIViewID = @NCIViewID and NCITemplateID is null 
	
						IF (EXISTS (SELECT * FROM CancerGovStaging..NCIView WHERE  NCIViewID = @NCIViewID and NCITemplateID is null and status in ('Approved')) )
						BEGIN
							UPDATE 	CancerGovStaging..NCIView
							SET		Status = 'SUBMIT'
							WHERE 	NCIViewID =  @NCIViewID
							IF (@@ERROR <> 0)
							BEGIN
								Close  VO_Cursor 
								DEALLOCATE VO_Cursor 
								RAISERROR ( 70004, 16, 1)
								RETURN
							END 
				
							SELECT @ReturnStatus = 0
							EXECUTE @ReturnStatus = [CancerGovStaging].[dbo].[usp_PushNCIViewToProduction] @NCIViewID, @UpdateUserID 
							if (@ReturnStatus <>0 )
							BEGIN
								Close  VO_Cursor 
								DEALLOCATE VO_Cursor 
								RAISERROR ( 80103, 16, 1, @ShortTitle)
								RETURN 
							END
						END 
						ELSE IF (EXISTS (SELECT * FROM CancerGovStaging..NCIView WHERE  NCIViewID = @NCIViewID and NCITemplateID is null and status in ('EDIT')) )
						BEGIN
							Print 'Simple page in Edit status. Raise and error and ask them to push it before this pushing' +  Convert(varchar(2), @@TRANCOUNT)  
							/*
							*   If a simple is not in Approved. Raise and error and ask them to push it before this pushing
							*/ 
							IF (not EXISTS (SELECT * FROM CancerGov..NCIView WHERE  NCIViewID = @NCIViewID) )
							BEGIN
								Close  VO_Cursor 
								DEALLOCATE VO_Cursor 
								RAISERROR ( 80104, 16, 1, @ShortTitle)
								RETURN
							END
						END
					END
					ELSE
					BEGIN
						Print ' This nciview is not on production Raise and error and ask them to push it before this pushing'
						/*
						*   This nciview is not on productionRaise and error and ask them to push it before this pushing
						*/ 
						Close  VO_Cursor 
						DEALLOCATE VO_Cursor 
						RAISERROR ( 80105, 16, 1, @ShortTitle)
						RETURN 
					END
				END
	
				Print 'Insert Listitem with ListID =' + Convert(varchar(36), @NCIObjectID)
	
				IF (not EXISTS (SELECT * FROM CancerGov..ListItem WHERE  ListID = @NCIObjectID  and NCIViewID = @NCIViewID  ))
				BEGIN
					Insert into CancerGov..Listitem
					(ListID, NCIViewID,Priority, IsFeatured, UpdateDate, UpdateUserID)
					select	ListID, NCIViewID,Priority, IsFeatured, UpdateDate, UpdateUserID
					from CancerGovStaging..Listitem where listid = @NCIObjectID and NCIViewID = @NCIViewID
					IF (@@ERROR <> 0)
					BEGIN
						Close  VO_Cursor 
						DEALLOCATE VO_Cursor 
						RAISERROR ( 80106, 16, 1)
						RETURN
					END
				END
				ELSE
				BEGIN
					Update P
					set 	P.Priority	= S.Priority, 
						P.IsFeatured	= S.IsFeatured, 
						P.UpdateDate	= S.UpdateDate , 
						P.UpdateUserID	= S.UpdateUserID 
					From CancerGov..Listitem P, CancerGovStaging..Listitem S
					where 	P.ListID	= S.ListID and P.NCIViewID= S.NCIViewID 
						and S.listid = @NCIObjectID and S.NCIViewID = @NCIViewID
					IF (@@ERROR <> 0)
					BEGIN
						Close  VO_Cursor 
						DEALLOCATE VO_Cursor 
						RAISERROR ( 80106, 16, 1)
						RETURN
					END
				END 
	
				-- GET NEXT OBJECT
				PRINT '--get next'
				FETCH NEXT FROM VO_Cursor
				INTO 	@NCIViewID
	
			END -- End while
			
			-- CLOSE ViewObject_Cursor		
			CLOSE VO_Cursor 
			DEALLOCATE VO_Cursor 
		END
		ELSE
		IF @Type ='IMAGE'
		BEGIN
			PRINT '*** PUSH IMAGE RECORD TO PRODUCTION'+'<br>'
	
			IF (EXISTS (SELECT * FROM CancerGov..[Image] WHERE  ImageID = @NCIObjectID))
			BEGIN
				PRINT '--    Upadate Existing Image Record'+'<br>'
				UPDATE 	P
				SET 	P.ImageName = S.ImageName,
					P.ImageSource = S.ImageSource ,
					P.TextSource = S.TextSource ,
					P.Url = S.Url,
					P.Width = S.Width,
					P.Height = S.Height,
					P.ImageAltText = S.ImageAltText, 
					P.Border = S.Border,
					P.UpdateDate = @UpdateDate,
					P.UpdateUserID = @UpdateUserID 
				FROM 	CancerGovStaging..[Image] AS S,
					CancerGov..[Image] AS P  
				WHERE  P.[ImageID] = S.[ImageID] 
					AND S.[ImageID] = @NCIObjectID
				IF (@@ERROR <> 0) OR (@@ROWCOUNT <> 1)
				BEGIN
					RAISERROR ( 80007, 16, 1)
					RETURN  
				END 				
			END
			ELSE 
			BEGIN
				PRINT '--    Insert New Image Record'+'<br>'
				INSERT INTO CancerGov..[Image](ImageID,ImageName,ImageSource,ImageAltText, TextSource,Url,Width,Height,Border,UpdateDate,UpdateUserID)
				SELECT 	ImageID,
						ImageName,
						ImageSource,
						ImageAltText ,
						TextSource,
						Url,
						Width,
						Height,
						Border,
						UpdateDate,
						UpdateUserID
				FROM 	CancerGovStaging..[Image]
				WHERE	[ImageID] = @NCIObjectID
	
				IF (@@ERROR <> 0) OR (@@ROWCOUNT <> 1)
				BEGIN
					RAISERROR ( 80007, 16, 1)
					RETURN  
				END 
			END
		END
		ELSE
		IF @Type ='NAVDOC'
		BEGIN
			PRINT '*** PUSH DOCUMENT TO PRODUCTION' +'<br>'
			IF (EXISTS (SELECT * FROM CancerGov..Document WHERE  DocumentID = @NCIObjectID))
			BEGIN
				PRINT '--    Upadate Existing Document' +'<br>'
				UPDATE Prod
				SET	Prod.Title 		= Staging.Title,
					Prod.ShortTitle 		= Staging.ShortTitle,
					Prod.Description 	= Staging.Description,
					Prod.GroupID 		= Staging.GroupID,
					Prod.DataType 		= Staging.DataType,
					Prod.DataSize  		= Staging.DataSize ,
					Prod.IsWirelessPage 	= Staging.IsWirelessPage,
					Prod.TOC 		= Staging.TOC,
					Prod.Data 		= Staging.Data,
					Prod.RunTimeOwnerID 	= Staging.RunTimeOwnerID,
					Prod.CreateDate 	= Staging.CreateDate,
					Prod.ReleaseDate 	= Staging.ReleaseDate,
					Prod.ExpirationDate 	= Staging.ExpirationDate,
					Prod.UpdateDate 	= @UpdateDate,
					Prod.UpdateUserID  	= @UpdateUserID 
				FROM 	CancerGov..Document AS Prod, CancerGovStaging..Document AS Staging
				WHERE Staging.DocumentID = Prod.DocumentID
					AND Prod.DocumentID = @NCIObjectID
				IF (@@ERROR <> 0)
				BEGIN
					RAISERROR ( 80003, 16, 1)
					RETURN  
				END 
			END 
			ELSE
			BEGIN
				PRINT '--    Insert New Document' +'<br>'
				INSERT INTO 	CancerGov..Document (DocumentID, Title, ShortTitle, [Description], GroupID, DataType, /*ContentType,*/ DataSize, IsWirelessPage, 
							TOC, Data, RunTimeOwnerID, CreateDate, ReleaseDate,ExpirationDate, UpdateDate, UpdateUserID)
				SELECT 	DocumentID,
						Title,
						ShortTitle,
						[Description],
						GroupID,
						DataType,
						DataSize,
						IsWirelessPage,
						TOC,
						Data,
						RunTimeOwnerID,
						CreateDate,
						ReleaseDate,
						ExpirationDate,
						@UpdateDate AS UpdateDate,
						@UpdateUserID  AS UpdateUserID
				FROM 	CancerGovStaging..Document 
				WHERE DocumentID = @NCIObjectID					 	
				IF (@@ERROR <> 0)
				BEGIN
					RAISERROR ( 80004, 16, 1)
					RETURN  
				END 
			END
		END
		
	
	
		-- Push NCIObjectProperty Over
	
		DECLARE NCIOP_Cursor CURSOR LOCAL FORWARD_ONLY  FOR
		SELECT 	PropertyName, PropertyValue
		FROM 		CancerGovStaging..NCIObjectProperty
		Where 		ObjectInstanceID = @ObjectInstanceID
		FOR READ ONLY 
		IF (@@ERROR <> 0)
		BEGIN
			RAISERROR ( 70004, 16, 1)
			RETURN 
		END 
			
		OPEN NCIOP_Cursor 
		IF (@@ERROR <> 0)
		BEGIN
			DEALLOCATE NCIOP_Cursor 
			RAISERROR ( 70004, 16, 1)		
			RETURN 
		END 
			
		FETCH NEXT FROM NCIOP_Cursor
		INTO 	 @PropertyName, @PropertyValue
	
		WHILE @@FETCH_STATUS = 0
		BEGIN
			Print 'Push every NCIObjectProperty to Prod'
	
			IF (EXISTS (SELECT * FROM CancerGov..NCIObjectProperty WHERE  ObjectInstanceID = @ObjectInstanceID and PropertyName = @PropertyName))
			BEGIN
				PRINT '--    Upadate Existing Property '  + @PropertyName +'<br>'
				UPDATE CancerGov..NCIObjectProperty
				SET	PropertyValue	= @PropertyValue,
					UpdateDate 	= @UpdateDate,
					UpdateUserID  	= @UpdateUserID 
				WHERE ObjectInstanceID= @ObjectInstanceID
					AND PropertyName = @PropertyName
				IF (@@ERROR <> 0)
				BEGIN
					Close  NCIOP_Cursor 
					DEALLOCATE  NCIOP_Cursor 
					RAISERROR ( 80003, 16, 1)
					RETURN  
				END 
			END 
			ELSE
			BEGIN
				PRINT '--    Insert New Document' +'<br>'
				INSERT INTO 	 CancerGov..NCIObjectProperty 
				(ObjectInstanceID, PropertyName, PropertyValue, UpdateDate, UpdateUserID)
				SELECT 	ObjectInstanceID, 
						PropertyName, 
						PropertyValue,
						@UpdateDate AS UpdateDate,
						@UpdateUserID  AS UpdateUserID
				FROM 	CancerGovStaging..NCIObjectProperty
				WHERE ObjectInstanceID = @ObjectInstanceID and PropertyName = @PropertyName				 	
				IF (@@ERROR <> 0)
				BEGIN
					Close  NCIOP_Cursor 
					DEALLOCATE  NCIOP_Cursor 
					RAISERROR ( 80003, 16, 1)
					RETURN  
				END 
			END
				
			-- GET NEXT OBJECT
			PRINT '--get next'
			FETCH NEXT FROM NCIOP_Cursor
			INTO 	@PropertyName, @PropertyValue
	
		END -- End while
			
		-- CLOSE ViewObject_Cursor		
		CLOSE NCIOP_Cursor 
		DEALLOCATE NCIOP_Cursor 
		
		-- Push NCIObjects over
	
		IF (EXISTS (Select  NCIobjectID from CancerGov..NCIObjects Where NCIObjectID = @NCIObjectID))
		BEGIN
			PRINT '--    Upadate Existing NCIObject;' + '<br>'
			UPDATE P
			SET	P.NCIObjectID		= S.NCIObjectID, 
				P.ObjectInstanceID	= S.ObjectInstanceID,
				P.ObjectType		= S.ObjectType, 
				P.Priority		= S.Priority,
				P.UpdateDate 		= @UpdateDate,
				P.UpdateUserID  	= @UpdateUserID 
			From CancerGov..NCIObjects P, CancerGovStaging..NCIObjects S
			WHERE S.ObjectInstanceID= P.ObjectInstanceID
				AND S.ObjectInstanceID =@ObjectInstanceID
			IF (@@ERROR <> 0)
			BEGIN
				RAISERROR ( 80003, 16, 1)
				RETURN  
			END 
		END 
		ELSE
		BEGIN
			PRINT '    --Insert New NCIObjects' +'<br>'
			INSERT INTO 	 CancerGov..NCIObjects
			(ObjectInstanceID, NCIObjectID, ParentNCIObjectID, ObjectType, Priority, UpdateDate, UpdateUserID)
			SELECT 	ObjectInstanceID, 
					NCIObjectID,
					ParentNCIObjectID,
					ObjectType,
					Priority,
					@UpdateDate AS UpdateDate,
					@UpdateUserID  AS UpdateUserID
			FROM 	CancerGovStaging..NCIObjects
			WHERE ObjectInstanceID =@ObjectInstanceID
			IF (@@ERROR <> 0)
			BEGIN
				RAISERROR ( 80003, 16, 1)
				RETURN  
			END 
		END
	
		FETCH NEXT FROM NCIObject_Cursor
		INTO 	@Type, @NCIObjectID, @ObjectInstanceID
					
	END
		
	CLOSE  NCIObject_Cursor 
	DEALLOCATE NCIObject_Cursor 	

	SET NOCOUNT OFF
	RETURN 0 

END

GO
GRANT EXECUTE ON [dbo].[usp_PushInfoBoxToProduction] TO [webadminuser_role]
GO
