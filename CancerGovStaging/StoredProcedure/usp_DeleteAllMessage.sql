IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_DeleteAllMessage]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_DeleteAllMessage]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/* usp_deleteMacro for deleting macro. Only called by SubmitMacroForDeletionApproval
* Jay He 4/4/2003
*/

CREATE PROCEDURE [dbo].[usp_DeleteAllMessage]
(
	@LoginName varchar(40)
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
	  (@LoginName  IS NULL) OR (NOT EXISTS (SELECT *  FROM  NCIUsers WHERE LoginName = @LoginName )) 
	  )	
	BEGIN
		RAISERROR ( 70001, 16, 1)
		RETURN 70001
	END

	Declare @UserID uniqueidentifier	

	select @UserID = userID FROM  NCIUsers WHERE LoginName = @LoginName

	BEGIN TRAN Tran_DeleteList

		/*	
		** Delete Synonym from the  BestBetSynonyms  table 
		*/
		DELETE FROM NCIMessageAttachment 		
		where messageID  in 
			(select messageID FROM NCIMessage 
			where RecipientID  = @UserID)
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN  Tran_DeleteList
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 	
		/*
		** Delete category from the BestBetCategories table 
		*/
	
		DELETE FROM NCIMessage 
		where RecipientID  = @UserID
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
GRANT EXECUTE ON [dbo].[usp_DeleteAllMessage] TO [webadminuser_role]
GO
