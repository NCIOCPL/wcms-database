IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_DeleteBestBetBoth]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_DeleteBestBetBoth]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[usp_DeleteBestBetBoth]
(
	@CategoryID uniqueidentifier,
	@UpdateUserID varchar(50) = 'system'  -- Not Used but must support for step command processing
)
AS
BEGIN	
	SET NOCOUNT ON;
	/*
	** STEP - A
	** First Validate that the guid provided is valid
	** if not return and 70001 error
	*/	
	if(	
	  (@CategoryID IS NULL) OR (NOT EXISTS (SELECT CategoryID FROM CancerGovStaging..BestBetCategories WHERE CategoryID = @CategoryID)) 
	  )	
	BEGIN
		RAISERROR ( 70001, 16, 1)
		RETURN 70001
	END
	/*
	** STEP - C
	** Get ListID for the relevant list in this best bets' category
	*/

	DECLARE @listID uniqueidentifier

	BEGIN TRAN Tran_DeleteList
		/*
		** STEP - C
		** Ok now we need to get listID for deleting list and all its child elements.
		*/
	
		select @listID = ListID
		from  CancerGovStaging..BestBetCategories
		where  CategoryID = @CategoryID
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN Tran_DeleteList
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 
	
		/*	
		** Delete Synonym from the  BestBetSynonyms  table 
		*/
		DELETE FROM  CancerGovStaging..BestBetSynonyms 
		WHERE CategoryID = @CategoryID
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN  Tran_DeleteList
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 	
		/*
		** Delete category from the BestBetCategories table 
		*/
		DELETE FROM  CancerGovStaging..BestBetCategories 
		WHERE CategoryID = @CategoryID
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN  Tran_DeleteList
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 	

		/*
		** Delete List items for the List
		*/
		delete from  CancerGovStaging..listitem
		where listid = @listID

		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN Tran_DeleteList
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 	
		/*
		** Delete List
		*/
		delete from  CancerGovStaging..list
		where listid = @listID
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN Tran_DeleteList
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 
		
		if(	
		 EXISTS (SELECT CategoryID FROM CancerGov..BestBetCategories WHERE CategoryID = @CategoryID)
		 )	
		BEGIN

			select @listID = ListID
			from CancerGov..BestBetCategories
			where  CategoryID = @CategoryID
			IF (@@ERROR <> 0)
			BEGIN
				ROLLBACK TRAN Tran_DeleteList
				RAISERROR ( 70004, 16, 1)
				RETURN 70004
			END 
	
			/*	
			** Delete Synonym from the  BestBetSynonyms  table 
			*/
			DELETE FROM CancerGov..BestBetSynonyms 
			WHERE CategoryID = @CategoryID
			IF (@@ERROR <> 0)
			BEGIN
				ROLLBACK TRAN  Tran_DeleteList
				RAISERROR ( 70004, 16, 1)
				RETURN 70004
			END 	
			/*
			** Delete category from the BestBetCategories table 
			*/
			DELETE FROM CancerGov..BestBetCategories 
			WHERE CategoryID = @CategoryID
			IF (@@ERROR <> 0)
			BEGIN
				ROLLBACK TRAN  Tran_DeleteList
				RAISERROR ( 70004, 16, 1)
				RETURN 70004
			END 	

			/*
			** Delete List items for the List
			*/
			delete from CancerGov..listitem
			where listid = @listID
	
			IF (@@ERROR <> 0)
			BEGIN
				ROLLBACK TRAN Tran_DeleteList
				RAISERROR ( 70004, 16, 1)
				RETURN 70004
			END 	
			/*
			** Delete List
			*/
			delete from CancerGov..list
			where listid = @listID
			IF (@@ERROR <> 0)
			BEGIN
				ROLLBACK TRAN Tran_DeleteList
				RAISERROR ( 70004, 16, 1)
				RETURN 70004
			END 
		
		END

	COMMIT TRAN  Tran_DeleteList

	SET NOCOUNT OFF
	RETURN 0 

END
GO
GRANT EXECUTE ON [dbo].[usp_DeleteBestBetBoth] TO [webadminuser_role]
GO
