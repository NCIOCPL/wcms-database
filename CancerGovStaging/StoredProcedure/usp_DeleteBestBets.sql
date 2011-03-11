IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_DeleteBestBets]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_DeleteBestBets]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[usp_DeleteBestBets]
(
	@CategoryID uniqueidentifier
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
	  (@CategoryID IS NULL) OR (NOT EXISTS (SELECT CategoryID FROM BestBetCategories WHERE CategoryID = @CategoryID)) 
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
		from BestBetCategories
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
		DELETE FROM BestBetSynonyms 
		WHERE CategoryID = @CategoryID
		/*
		** Check Status
		*/
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN  Tran_DeleteList
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 	
		/*
		** Delete category from the BestBetCategories table 
		*/
		DELETE FROM BestBetCategories 
		WHERE CategoryID = @CategoryID
		/*
		** Check Status
		*/
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN  Tran_DeleteList
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 	

		-- DELETE Each List & items
		/*
		** Delete List items for the List
		*/
		delete from listitem
		where listid = @listID
		/*
		** Check Status
		*/
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN Tran_DeleteList
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 	
		/*
		** Delete List
		*/
		delete from list
		where listid = @listID
		/*
		** Check Status
		*/
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN Tran_DeleteList
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 

	COMMIT TRAN  Tran_DeleteList

	SET NOCOUNT OFF
	RETURN 0 

END
GO
GRANT EXECUTE ON [dbo].[usp_DeleteBestBets] TO [webadminuser_role]
GO
