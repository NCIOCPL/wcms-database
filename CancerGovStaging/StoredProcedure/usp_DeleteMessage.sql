IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_DeleteMessage]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_DeleteMessage]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/* usp_deleteMacro for deleting macro. Only called by SubmitMacroForDeletionApproval
* Jay He 4/4/2003
*/

CREATE PROCEDURE [dbo].[usp_DeleteMessage]
(
	@MessageID 	uniqueidentifier
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
	  (@MessageID  IS NULL) OR (NOT EXISTS (SELECT MessageID  FROM  NCIMessage WHERE MessageID = @MessageID )) 
	  )	
	BEGIN
		RAISERROR ( 70001, 16, 1)
		RETURN 70001
	END

	
	BEGIN TRAN Tran_DeleteList

		/*	
		** Delete Synonym from the  BestBetSynonyms  table 
		*/
		DELETE FROM NCIMessageAttachment WHERE MessageID = @MessageID				
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN  Tran_DeleteList
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 	
		/*
		** Delete category from the BestBetCategories table 
		*/
	
		DELETE FROM NCIMessage WHERE MessageID =@MessageID
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN  Tran_DeleteList
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 	


	COMMIT TRAN  Tran_DeleteList

	SET NOCOUNT OFF
	RETURN 0 

END
GO
GRANT EXECUTE ON [dbo].[usp_DeleteMessage] TO [webadminuser_role]
GO
