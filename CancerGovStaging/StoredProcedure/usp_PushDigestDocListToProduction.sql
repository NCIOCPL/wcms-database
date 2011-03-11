IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_PushDigestDocListToProduction]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_PushDigestDocListToProduction]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** 	Object:  Stored Procedure dbo.usp_InsertViewObject    
	Purpose: This script can be used for  inserting view objects property value.	Script Date: 8/13/2003 11:43:49 pM 

*	EXEC sp_addmessage 80100, 16, N' CancerGov Error. Document Digest page property DigestRelatedList doesn't exist.','us_english', true,replace
*	EXEC sp_addmessage 80101, 16, N' CancerGov Error. Unable to push this DigestRelatedList parentlist to production','us_english', true,replace
*	EXEC sp_addmessage 80102, 16, N' CancerGov Error. Unable to push this DigestRelatedList  List to production','us_english', true,replace
*	EXEC sp_addmessage 80103, 16, N' CancerGov Error. Unable to push this DigestRelatedList  list item''s Simple-link page (%s in "Approved" status) to production','us_english', true,replace
*	EXEC sp_addmessage 80104, 16, N' CancerGov Error. Unable to push this DigestRelatedList  list item''s Simple-link page (%s in "EDIT"status) to production. Please push it first','us_english', true,replace
*	EXEC sp_addmessage 80105, 16, N' CancerGov Error. Unable to push this Digest Document List item''s page not on production (%s is not a Simple-link page) to production','us_english', true,replace
*	EXEC sp_addmessage 80106, 16, N' CancerGov Error. Unable to push this Digest Document List item to production','us_english', true,replace
*		
******/

CREATE PROCEDURE dbo.usp_PushDigestDocListToProduction
(
	@NCIViewObjectID		UniqueIdentifier, 
	@UpdateUserID 		varchar(50)
)
AS
BEGIN
	SET NOCOUNT ON;

	Declare @ListID UniqueIdentifier,
		@PListID varchar(36),
		@CListID UniqueIdentifier,
		@NCIViewID UniqueIdentifier,
		@ShortTitle	varchar(50),
		@ReturnStatus int

	Print 'Begin usp_pushdigestdoclisttoproduction' + convert(varchar(36), @NCIViewObjectID) +'<br> ' + Convert(varchar(2), @@TRANCOUNT) 


	if(	
	  (@NCIviewObjectID IS NULL) OR (NOT EXISTS (Select  PropertyValue from CancerGovStaging..ViewObjectProperty Where NCIViewObjectID = @NCIViewObjectID and PropertyName ='DigestRelatedListID')) 
	  )	
	BEGIN
		RAISERROR ( 80100, 16, 1)
		RETURN 
	END

	Select @PListID = PropertyValue 
	from CancerGovStaging..ViewObjectProperty 
	Where NCIViewObjectID = @NCIViewObjectID and PropertyName ='DigestRelatedListID'

	/*
	** Add a parentlist
	*/	
	--BEGIN  TRAN   Tran_PushNCIViewToProduction

	INSERT INTO CancerGov..List 
	(ListID, GroupID, ListName,ListDesc,URL,ParentListID,NCIViewID,Priority, UpdateDate,UpdateUserID,DescDisplay, ReleaseDateDisplay, ReleaseDateDisplayLoc)
	select ListID, GroupID, ListName,ListDesc,URL,ParentListID,NCIViewID,Priority, UpdateDate,UpdateUserID,DescDisplay, ReleaseDateDisplay, ReleaseDateDisplayLoc
	from CancerGovStaging..List
 	where listID = @PListID
	IF (@@ERROR <> 0)
	BEGIN
		--ROLLBACK TRAN Tran_PushNCIViewToProduction
		RAISERROR ( 80101, 16, 1)
		RETURN 
	END 

	DECLARE ViewObject_Cursor CURSOR LOCAL FORWARD_ONLY  FOR
	SELECT 	ListID
	FROM 		CancerGovStaging..List
	Where 		ParentListID = @PListID
	FOR READ ONLY 
	IF (@@ERROR <> 0)
	BEGIN
		--ROLLBACK TRAN Tran_PushNCIViewToProduction
		RAISERROR ( 70004, 16, 1)
		RETURN 
	END 
		
	OPEN ViewObject_Cursor 
	IF (@@ERROR <> 0)
	BEGIN
		DEALLOCATE ViewObject_Cursor 
		--ROLLBACK TRAN Tran_PushNCIViewToProduction
		RAISERROR ( 70004, 16, 1)		
		RETURN 
	END 
		
	FETCH NEXT FROM ViewObject_Cursor
	INTO 	@ListID

	WHILE @@FETCH_STATUS = 0
	BEGIN
		Print 'Insert List with ListID =' + Convert(varchar(36), @ListID)
		Insert into CancerGov..List
		(ListID, GroupID, ListName,ListDesc,URL,ParentListID,NCIViewID,Priority, UpdateDate,UpdateUserID,DescDisplay, ReleaseDateDisplay, ReleaseDateDisplayLoc)
		select ListID, GroupID, ListName,ListDesc,URL,ParentListID,NCIViewID,Priority, UpdateDate,UpdateUserID,DescDisplay, ReleaseDateDisplay, ReleaseDateDisplayLoc
		from CancerGovStaging..List
		where listid = @ListID
		IF (@@ERROR <> 0)
		BEGIN
			CLOSE  ViewObject_Cursor 
			DEALLOCATE ViewObject_Cursor 
			--Rollback tran Tran_PushNCIViewToProduction
			RAISERROR ( 80102, 16, 1)
			RETURN 
		END 

		-- insert each listitem 
		DECLARE VO_Cursor CURSOR LOCAL FORWARD_ONLY  FOR
		SELECT 	ListID, NCIViewID
		FROM 		CancerGovStaging..Listitem
		Where 		ListID = @ListID
		FOR READ ONLY 
		IF (@@ERROR <> 0)
		BEGIN
			CLOSE  ViewObject_Cursor 
			DEALLOCATE ViewObject_Cursor 
			--ROLLBACK TRAN Tran_PushNCIViewToProduction
			RAISERROR ( 70004, 16, 1)
			RETURN 
		END 
		
		OPEN VO_Cursor 
		IF (@@ERROR <> 0)
		BEGIN
			DEALLOCATE VO_Cursor 
			CLOSE  ViewObject_Cursor 
			DEALLOCATE ViewObject_Cursor 
			--ROLLBACK TRAN Tran_PushNCIViewToProduction
			RAISERROR ( 70004, 16, 1)		
			RETURN 
		END 
		
		FETCH NEXT FROM VO_Cursor
		INTO 	@CListID, @NCIViewID

		WHILE @@FETCH_STATUS = 0
		BEGIN
			-- Check whether NCIViewID is on CancerGov. If not, raise error.
			if (not exists (select * from CancerGov..NCIView where NCIViewID = @NCIViewID))
			BEGIN
				-- without templateID
				IF (EXISTS (SELECT * FROM CancerGovStaging..NCIView WHERE  NCIViewID = @NCIViewID and NCITemplateID is null )) 
				BEGIN				
					Print 'Push simple-view with "Approved" status.'			
					Select @ShortTitle =ShortTitle from  CancerGovStaging..NCIView WHERE  NCIViewID = @NCIViewID and NCITemplateID is null 

					IF (EXISTS (SELECT * FROM CancerGovStaging..NCIView WHERE  NCIViewID = @NCIViewID and NCITemplateID is null and status in ('Approved')) )
					BEGIN
						UPDATE 	CancerGovStaging..NCIView
						SET	Status = 'SUBMIT'
						WHERE 	NCIViewID =  @NCIViewID
						IF (@@ERROR <> 0)
						BEGIN
							Close  VO_Cursor 
							DEALLOCATE VO_Cursor 
							CLOSE  ViewObject_Cursor 
							DEALLOCATE ViewObject_Cursor 
							--Rollback tran Tran_PushNCIViewToProduction
							RAISERROR ( 70004, 16, 1)
							RETURN
						END 
			
						SELECT @ReturnStatus = 0
						EXECUTE @ReturnStatus = [CancerGovStaging].[dbo].[usp_PushNCIViewToProduction] @NCIViewID, @UpdateUserID 
						if (@ReturnStatus <>0 )
						BEGIN
							Close  VO_Cursor 
							DEALLOCATE VO_Cursor 
							CLOSE  ViewObject_Cursor 
							DEALLOCATE ViewObject_Cursor 
							--Rollback tran Tran_PushNCIViewToProduction
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

						Close  VO_Cursor 
						DEALLOCATE VO_Cursor 
						CLOSE  ViewObject_Cursor 
						DEALLOCATE ViewObject_Cursor 
						RAISERROR ( 80104, 16, 1, @ShortTitle)
						RETURN
					END
				END
				ELSE
				BEGIN
					Print ' This nciview is not on productionRaise and error and ask them to push it before this pushing'
					/*
					*   This nciview is not on productionRaise and error and ask them to push it before this pushing
					*/ 
					Close  VO_Cursor 
					DEALLOCATE VO_Cursor 
					CLOSE  ViewObject_Cursor 
					DEALLOCATE ViewObject_Cursor 
					RAISERROR ( 80105, 16, 1, @ShortTitle)
					RETURN 
				END
			END

			Print 'Insert Listitem with ListID =' + Convert(varchar(36), @ListID)
			Insert into CancerGov..Listitem
			(ListID, NCIViewID,Priority, IsFeatured, UpdateDate, UpdateUserID)
			select	ListID, NCIViewID,Priority, IsFeatured, UpdateDate, UpdateUserID
			from CancerGovStaging..Listitem where listid = @ListID and NCIViewID = @NCIViewID
			IF (@@ERROR <> 0)
			BEGIN
				Close  VO_Cursor 
				DEALLOCATE VO_Cursor 
				CLOSE  ViewObject_Cursor 
				DEALLOCATE ViewObject_Cursor 
				--Rollback tran Tran_PushNCIViewToProduction
				RAISERROR ( 80106, 16, 1)
				RETURN
			END 

			-- GET NEXT OBJECT
			PRINT '--get next'
			FETCH NEXT FROM VO_Cursor
			INTO 	@CListID, @NCIViewID

		END -- End while
		
		-- CLOSE ViewObject_Cursor		
		CLOSE VO_Cursor 
		DEALLOCATE VO_Cursor 


		-- GET NEXT OBJECT
		PRINT '--get next'
		FETCH NEXT FROM ViewObject_Cursor
		INTO 	@ListID

	END -- End while
	
	-- CLOSE ViewObject_Cursor		
	CLOSE ViewObject_Cursor 
	DEALLOCATE ViewObject_Cursor 

	--COMMIT tran  Tran_PushNCIViewToProduction

	SET NOCOUNT OFF
	RETURN 0 

END
GO
GRANT EXECUTE ON [dbo].[usp_PushDigestDocListToProduction] TO [webadminuser_role]
GO
