IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_PushBestBetToProduction]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_PushBestBetToProduction]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/**********************************************************************************

	Object's name:	usp_PushBestBetToProduction
	Object's type:	Stored Procedure
	Purpose:	This procedure will push best bets to production
	Change History:	02-11-03	Jay He	
			11/04/2004	Lijia add ChangeComments
	**  Return Values
	**  0         Success
	**  70001     The guid argument was invalid
	**  70004     Failed during execution 
	**  70005     Failed to create
	**  70006     Failed to update

**********************************************************************************/


CREATE PROCEDURE [dbo].[usp_PushBestBetToProduction]
	(
	@CategoryID		uniqueidentifier,  -- this is the guid for Header
	@UpdateUserID		varchar(50)
	)
AS
BEGIN	
	SET NOCOUNT ON

	if(  (@CategoryID IS NULL) OR (NOT EXISTS (SELECT CategoryID FROM BestBetCategories WHERE CategoryID = @CategoryID	)) )	
	BEGIN
		RAISERROR ( 70001, 16, 1)
		RETURN 70001
	END

	CREATE TABLE #tmpListItem(
		ListID uniqueidentifier,
		NCIViewID uniqueidentifier,
		Production char(1) DEFAULT 'N', -- Is this LIST on Production
		Staging char(1)  DEFAULT 'N', -- Is this LIST on Staging
		Status char(10)  DEFAULT 'SUBMIT', -- Status for related NCIView in staging database

		IsNCIViewExistsOnProduction char(1) DEFAULT 'N', -- Is related to that item NCIView exists on Production ('Y' - yes, 'N' - no, 'E' - exception, do not check)
		IsSimpleNCIView char(1) DEFAULT 'N' -- Simple if do not have any ViewObjects
	)


	DECLARE @UpdateDate 	datetime,
		@ProductionStatus varchar(50),
		@SimpleNCIViewID uniqueidentifier,
		@ListID		uniqueidentifier,
		@SynonymID	uniqueidentifier,
		@SynName	varchar(255),
		@Weight		int,
		@IsNegated  	bit,
		@IsExactMatch   bit,
		@Notes		varchar(2000),
		@ReturnStatus int,
		@ReadyForProductionStatus  varchar(50),
		@ReadyStatusForSimpleNCIView  varchar(50)

	SELECT 	@UpdateDate = GETDATE(),
		@ProductionStatus = 'PRODUCTION',
		@ReadyForProductionStatus = 'SUBMIT', 
		@ReadyStatusForSimpleNCIView = 'APPROVED'

	SELECT @ListID=ListID from BestBetCategories where CategoryID=@CategoryID

	BEGIN TRAN Tran_PushNCIViewToProduction

-- If list is not null, we need to check each list item.
	-- a. Update existing listitem on prod.
	-- b. Inser new listitme to prod.
	-- c. Push listitem-related simple view to prod.
	-- d. Delete listitem on prod which is not on staging
	if (LEN(Convert(varchar(36), @ListID)) !=0)
	BEGIN
		PRINT 'List is not null and we need to push list and list item to prod<br>'
		PRINT 'First check whether list is on production <Br>'		

		if (exists (select listid from CancerGov..List where listID= @ListID))
		BEGIN
			PRINT '--    Update existing LIST on production'	+'<br>'
			UPDATE  Prod
			SET 	GroupID		=CS.GroupID,
				ListName	=CS.ListName,
				ListDesc	=CS.ListDesc,
				URL		=CS.URL,
				ParentListID	=CS.ParentListID,
				NCIViewID	=CS.NCIViewID,
				Priority	=CS.Priority,
				UpdateDate	=@UpdateDate,
				UpdateUserID	=@UpdateUserID ,
				DescDisplay	=CS.DescDisplay, 
				ReleaseDateDisplay	=CS.ReleaseDateDisplay, 
				ReleaseDateDisplayLoc	=CS.ReleaseDateDisplayLoc
			FROM CancerGov..List Prod, CancerGovStaging..List CS	
			WHERE Prod.ListID =CS.ListID
				and  Prod.ListID= @ListID
			IF (@@ERROR <> 0)
			BEGIN
				ROLLBACK TRAN Tran_PushNCIViewToProduction
				RAISERROR ( 80007, 16, 1)
				RETURN  
			END 
		END
		ELSE
		BEGIN
			PRINT '--    Insert new LIST to production'	+'<br>'
			INSERT INTO CancerGov..List (ListID, GroupID, ListName, ListDesc, URL, ParentListID, NCIViewID,
					Priority, UpdateDate, UpdateUserID, DescDisplay, ReleaseDateDisplay, ReleaseDateDisplayLoc )
			SELECT 	ListID,
				GroupID,
				ListName,
				ListDesc,
				URL,
				ParentListID,
				NCIViewID,
				Priority,
				@UpdateDate AS UpdateDate,
				@UpdateUserID AS UpdateUserID,
				DescDisplay, 
				ReleaseDateDisplay, 
				ReleaseDateDisplayLoc
			FROM CancerGovStaging..List	
			WHERE ListID = @ListID
			IF (@@ERROR <> 0)
			BEGIN
				ROLLBACK TRAN Tran_PushNCIViewToProduction
				RAISERROR ( 80007, 16, 1)
				RETURN  
			END 
		END

		PRINT '--    (a) Get all Staging List Items' +'<br>'
		INSERT INTO #tmpListItem (ListID, NCIViewID, Production, Staging, Status)
			SELECT 	L.ListID, 
				L.NCIViewID , 
				'N' AS Production,
				'Y' AS Staging,
				V.Status 	
		FROM 	CancerGovStaging..ListItem L
			INNER JOIN CancerGovStaging..NCIView V
				ON L.NCIViewID = V.NCIViewID 
			AND L.ListID =@ListID
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN Tran_PushNCIViewToProduction
			RAISERROR ( 80006, 16, 1)
			RETURN  
		END 

		PRINT '--   (b) Get all Production List Items' +'<br>'
		INSERT INTO #tmpListItem (ListID, NCIViewID, Production, Staging, Status)
		SELECT 	L.ListID, 
			L.NCIViewID , 
			'Y' AS Production,
			'N' AS Staging,
			'EXCEPTION' AS Status 	
		FROM 	CancerGov..ListItem L
			INNER JOIN CancerGov..NCIView V
				ON L.NCIViewID = V.NCIViewID 
				AND L.ListID	=@ListID 
		WHERE 	convert(varchar(36),L.ListID) + convert(varchar(36),L.NCIViewID) NOT IN  (SELECT convert(varchar(36),ListID) + convert(varchar(36),NCIViewID) FROM #tmpListItem) 
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN Tran_PushNCIViewToProduction
			RAISERROR ( 80006, 16, 1)
			RETURN  
		END 		 
			
		PRINT '--    (c) Find out is the related to ListItem NCIViews exists on production' +'<br>'
		UPDATE 	TLI
		SET 	TLI.IsNCIViewExistsOnProduction = 'Y'
		FROM 	CancerGov..NCIView AS ProdV
			INNER JOIN #tmpListItem AS TLI
			ON TLI.NCIViewID = ProdV.NCIViewID 
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN Tran_PushNCIViewToProduction
			RAISERROR ( 80006, 16, 1)
			RETURN  
		END 
			
		PRINT '--    (d) Find out are the related to ListItem NCIViews is simple' +'<br>'
		UPDATE 	TLI
		SET 	IsSimpleNCIView = 
			CASE 
				WHEN EXISTS(SELECT * FROM CancerGovStaging..ViewObjects AS VO WHERE VO.NCIViewID = TLI.NCIViewID) 
				THEN 'N'
				ELSE 'Y'	
			END
		FROM 	#tmpListItem AS TLI 
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN Tran_PushNCIViewToProduction
			RAISERROR ( 80006, 16, 1)
			RETURN  
		END 			
					
		PRINT '--    (e) Push Simple NCIViews to Production (if it is ready to go)'	+'<br>'
		DECLARE Simple_NCIViews_cursor CURSOR LOCAL FOR 
		SELECT 	NCIViewID
		FROM 	#tmpListItem AS TLI 
		WHERE 	IsSimpleNCIView = 'Y'
				AND Staging = 'Y' 
				AND Status IN ( @ReadyStatusForSimpleNCIView, @ReadyForProductionStatus ) 
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN Tran_PushNCIViewToProduction

			RAISERROR ( 80011, 16, 1)
			RETURN  
		END 
		
		OPEN Simple_NCIViews_cursor
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN Tran_PushNCIViewToProduction
			RAISERROR ( 80011, 16, 1)
			RETURN  
		END 
		FETCH NEXT FROM Simple_NCIViews_cursor INTO @SimpleNCIViewID
				
		WHILE @@FETCH_STATUS = 0
		BEGIN
			PRINT '  --  (f-1) Set Correct Status for NCIView {'+convert(varchar(36), @SimpleNCIViewID)+'} Before Pushing' +'<br>'
			UPDATE 	SV
			SET	Status = @ReadyForProductionStatus 
			FROM 	CancerGovStaging..NCIView AS SV
			WHERE 	NCIViewID = @SimpleNCIViewID
			IF (@@ERROR <> 0)
			BEGIN
				CLOSE Simple_NCIViews_cursor 
				DEALLOCATE Simple_NCIViews_cursor 
				ROLLBACK TRAN Tran_PushNCIViewToProduction
				RAISERROR ( 80011, 16, 1)
				RETURN  
			END 
					
			PRINT '  --  (f-2) Push Simple NCIView {'+convert(varchar(36), @SimpleNCIViewID)+'}' +'<br>'
			SELECT @ReturnStatus = 0
			EXECUTE @ReturnStatus = [CancerGovStaging].[dbo].[usp_PushNCIViewToProduction] 
				@NCIViewID = @SimpleNCIViewID,
				@UpdateUserID = @UpdateUserID 
			IF (@@ERROR <> 0)
			     OR 
			    (@ReturnStatus <> 0)
			BEGIN
				CLOSE Simple_NCIViews_cursor 
				DEALLOCATE Simple_NCIViews_cursor 
				ROLLBACK TRAN Tran_PushNCIViewToProduction
				RAISERROR ( 80011, 16, 1)
				RETURN  
			END 

			FETCH NEXT FROM Simple_NCIViews_cursor INTO @SimpleNCIViewID
		END
								
		CLOSE Simple_NCIViews_cursor
		DEALLOCATE Simple_NCIViews_cursor
				
		PRINT '--    (g) Check do we have List and ListItem''s records on Production'	+'<br>'	
		UPDATE 	TLI
		SET 	TLI.Production = 'Y'
		FROM 	#tmpListItem AS TLI 
			INNER JOIN CancerGov..ListItem AS PLI	
				ON TLI.NCIViewID = PLI.NCIViewID
				AND TLI.ListID = PLI.ListID 
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN Tran_PushNCIViewToProduction
			RAISERROR ( 80007, 16, 1)
			RETURN  
		END 
			
		PRINT '--    (h) Clear Production from un used ListItems'	+'<br>'
		DELETE 	PLI
		FROM 	CancerGov..ListItem AS PLI
			INNER JOIN #tmpListItem AS TLI
				ON TLI.ListID = PLI.ListID 
				AND TLI.NCIViewID = PLI.NCIViewID
				AND TLI.Staging = 'N' 
				AND TLI.Production = 'Y' 
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN Tran_PushNCIViewToProduction
			RAISERROR ( 80007, 16, 1)
			RETURN  
		END 

		PRINT '--    (i) Update Existing LISTITEM Data On production'	+'<br>'
		UPDATE 	Prod
		SET	Prod.NCIViewID = Staging.NCIViewID,
			Prod.Priority = Staging.Priority,
			Prod.IsFeatured = Staging.IsFeatured,
			Prod.UpdateDate = @UpdateDate,
			Prod.UpdateUserID = @UpdateUserID
		FROM 	CancerGov..ListItem AS Prod,
			CancerGovStaging..ListItem AS Staging,
			#tmpListItem AS Tmp	 
		WHERE 	Prod.NCIViewID = Staging.NCIViewID
				AND Prod.ListID = Staging.ListID
				AND Prod.NCIViewID = Tmp.NCIViewID
				AND Prod.ListID = Tmp.ListID	
				AND Tmp.Staging = 'Y'
				AND Tmp.Production = 'Y'
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN Tran_PushNCIViewToProduction
			RAISERROR ( 80007, 16, 1)
			RETURN  
		END 
				
		PRINT '--    (j) Insert new LISTITEM to production'	+'<br>'
		INSERT INTO CancerGov..ListItem (ListID, NCIViewID, Priority, IsFeatured, UpdateDate, UpdateUserID)
		SELECT 	SLI.ListID,
				SLI.NCIViewID,
				SLI.Priority,
				SLI.IsFeatured,
				@UpdateDate AS UpdateDate,
				@UpdateUserID AS UpdateUserID
		FROM 	CancerGovStaging..ListItem SLI,
				#tmpListItem TLI
		WHERE SLI.NCIViewID = TLI.NCIViewID 
				AND SLI.ListID = TLI.ListID
				AND TLI.Production = 'N'
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN Tran_PushNCIViewToProduction
			RAISERROR ( 80007, 16, 1)
			RETURN  
		END 				
	END		-- end if (len(listid))

	IF (EXISTS (SELECT CategoryID FROM CancerGov..BestBetCategories WHERE CategoryID = @CategoryID))	
	BEGIN
		PRINT '*** UPDATE PRODUCTION BestBetCategories TABLE<Br>'
		UPDATE 	Prod
		SET 	Prod.CatName	=	Staging.CatName,
			Prod.CatProfile	=	Staging.CatProfile,
			Prod.ListID	=	Staging.ListID,
			Prod.Weight	=	Staging.Weight,
			Prod.IsSpanish	=	Staging.IsSpanish,
			Prod.Status 	= 	@ProductionStatus, 	-- Set Status = 'PRODUCTION'
			Prod.IsOnProduction = 	1, 			--Staging.IsOnProduction,
			Prod.IsExactMatch = 	Staging.IsExactMatch, 			--Staging.IsExactMatch,
			Prod.UpdateDate = 	@UpdateDate, 		-- Set new UpdateDate
			Prod.UpdateUserID = 	@UpdateUserID, 		-- Set new UpdateUserID,
			Prod.ChangeComments=Staging.ChangeComments	
		FROM 	CancerGov..BestBetCategories Prod,
			CancerGovStaging..BestBetCategories Staging
		WHERE 	Prod.CategoryID = Staging.CategoryID 
			AND Prod.CategoryID = @CategoryID	 
		IF (@@ERROR <> 0 OR @@ROWCOUNT <> 1)
		BEGIN
			ROLLBACK TRAN Tran_PushNCIViewToProduction
			RAISERROR ( 80001, 16, 1)
			RETURN  
		END 

		PRINT '---Use cursor to update all synonyms'
		
		DECLARE BestBet_Cursor CURSOR LOCAL FORWARD_ONLY  FOR
			SELECT  SynonymID, SynName, IsNegated, Notes,  IsExactMatch
			FROM 	CancerGovStaging..BestBetSynonyms
			WHERE  	CategoryID = @CategoryID
		For Read Only
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN Tran_PushNCIViewToProduction
			RAISERROR ( 80001, 16, 1)
			RETURN  
		END 	
		
		OPEN BestBet_Cursor 
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN Tran_PushNCIViewToProduction
			RAISERROR ( 80001, 16, 1)
			RETURN  
		END 
		
		FETCH NEXT FROM BestBet_Cursor
		INTO @SynonymID, @SynName, @IsNegated, @Notes, @IsExactMatch

		WHILE @@FETCH_STATUS = 0
		BEGIN
			PRINT 'Insert synonym since it is anew category'
			IF (EXISTS (SELECT SynonymID FROM CancerGov..BestBetSynonyms WHERE SynonymID = @SynonymID))	
			BEGIN
				UPDATE 	CancerGov..BestBetSynonyms 
				SET 	SynName	=	@SynName,
					IsNegated=	@IsNegated,
					IsExactMatch = 	@IsExactMatch, 			--Staging.IsExactMatch,
					Notes		= @Notes,
					UpdateDate = 	@UpdateDate, 		-- Set new UpdateDate
					UpdateUserID = 	@UpdateUserID 		-- Set new UpdateUserID	
				WHERE 	SynonymID = @SynonymID	
				IF (@@ERROR <> 0)
				BEGIN
					CLOSE BestBet_Cursor 
					DEALLOCATE BestBet_Cursor
					ROLLBACK TRAN Tran_PushNCIViewToProduction
					RAISERROR ( 80001, 16, 1)
					RETURN  
				END 
			END
			ELSE
			BEGIN
				INSERT into CancerGov..BestBetSynonyms (SynonymID,CategoryID,SynName,
						UpdateDate,UpdateUserID,IsNegated, Notes, IsExactMatch)
				values
				( @SynonymID,@CategoryID,@SynName,@UpdateDate,@UpdateUserID,@IsNegated, @Notes, @IsExactMatch)
				IF (@@ERROR <> 0)
				BEGIN
					CLOSE BestBet_Cursor 
					DEALLOCATE BestBet_Cursor
					ROLLBACK TRAN Tran_PushNCIViewToProduction
					RAISERROR ( 80001, 16, 1)
					RETURN  
				END 
			END
			
			-- GET NEXT OBJECT
			FETCH NEXT FROM  BestBet_Cursor
			INTO @SynonymID, @SynName,  @IsNegated, @Notes, @IsExactMatch

		END -- End while
	
		-- CLOSE ViewObject_Cursor		
		CLOSE BestBet_Cursor
		DEALLOCATE BestBet_Cursor
	END
	ELSE BEGIN
		PRINT '*** INSERT NEW RECORD INTO PRODUCTION BestBetCategories TABLE<br>'
		INSERT INTO CancerGov..BestBetCategories (CategoryID, CatName, CatProfile,
			ListID,Weight,UpdateDate,UpdateUserID,Status, IsOnProduction,IsSpanish, ChangeComments, IsExactMatch )
		SELECT 		CategoryID,
				CatName,
				CatProfile,
				ListID,
				Weight,
				@UpdateDate AS UpdateDate,
				@UpdateUserID AS UpdateUserID,
				@ProductionStatus AS  Status,
				1 AS IsOnProduction,
				IsSpanish,
				ChangeComments,
				IsExactMatch
		FROM 		CancerGovStaging..BestBetCategories 
		WHERE 		CategoryID = @CategoryID
		IF (@@ERROR <> 0 OR @@ROWCOUNT <> 1)
		BEGIN
			ROLLBACK TRAN Tran_PushNCIViewToProduction
			RAISERROR ( 80005, 16, 1)
			RETURN  
		END 

		DECLARE BestBet_Cursor CURSOR LOCAL FORWARD_ONLY  FOR
			SELECT  SynonymID, SynName,  IsNegated , Notes, IsExactMatch
			FROM 	CancerGovStaging..BestBetSynonyms
			WHERE  	CategoryID = @CategoryID
		For Read Only
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN Tran_PushNCIViewToProduction
			RAISERROR ( 80001, 16, 1)
			RETURN  
		END 	
		
		OPEN BestBet_Cursor 
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN Tran_PushNCIViewToProduction
			RAISERROR ( 80001, 16, 1)
			RETURN  
		END 
		
		FETCH NEXT FROM BestBet_Cursor
		INTO @SynonymID, @SynName,  @IsNegated, @Notes, @IsExactMatch

		WHILE @@FETCH_STATUS = 0
		BEGIN
			PRINT 'insert synonym '
			INSERT into CancerGov..BestBetSynonyms (SynonymID,CategoryID,SynName,
					UpdateDate,UpdateUserID,IsNegated, Notes, IsExactMatch)
			values
			( @SynonymID,@CategoryID,@SynName,@UpdateDate,@UpdateUserID,@IsNegated, @Notes, @IsExactMatch)
			IF (@@ERROR <> 0)
			BEGIN
				CLOSE BestBet_Cursor 
				DEALLOCATE BestBet_Cursor
				ROLLBACK TRAN Tran_PushNCIViewToProduction
				RAISERROR ( 80001, 16, 1)
				RETURN  
			END 
			
			-- GET NEXT OBJECT
			FETCH NEXT FROM  BestBet_Cursor
			INTO @SynonymID, @SynName,  @IsNegated, @Notes, @IsExactMatch

		END -- End while
	
		-- CLOSE ViewObject_Cursor		
		CLOSE BestBet_Cursor
		DEALLOCATE BestBet_Cursor
	END

	PRINT '--     Clear Production from un used synonyms'	+'<br>'
	DELETE  From CancerGov..BestBetSynonyms 
		WHERE  CancerGov..BestBetSynonyms.CategoryID =@CategoryID
		AND	 CancerGov..BestBetSynonyms.SynonymID 
		not in (select SynonymID 
			from CancerGovStaging..BestBetSynonyms 
			where CategoryID=@CategoryID)  
	IF (@@ERROR <> 0)
	BEGIN
		ROLLBACK TRAN Tran_PushNCIViewToProduction
		RAISERROR ( 80007, 16, 1)
		RETURN  
	END 

	PRINT '*** CHANGE STATUS FOR STAGING BestBet RECORD "PRODUCTION"<br>'
	UPDATE	CancerGovStaging..BestBetCategories 
	SET 	IsOnProduction = 1,
		Status =	@ProductionStatus, 	-- Set Status = 'PRODUCTION'
		UpdateDate =	@UpdateDate, 		-- Set new UpdateDate
		UpdateUserID = 	@UpdateUserID 		-- Set new UpdateUserID	
	WHERE  	CategoryID = @CategoryID 	

	

	COMMIT TRAN  Tran_PushNCIViewToProduction

	PRINT '--    (k) Clear Temporary tables (prepare for the next object)'	+'<br>'
	TRUNCATE TABLE #tmpListItem	
	

	SET NOCOUNT OFF
	RETURN 0 
END



GO
GRANT EXECUTE ON [dbo].[usp_PushBestBetToProduction] TO [webadminuser_role]
GO
