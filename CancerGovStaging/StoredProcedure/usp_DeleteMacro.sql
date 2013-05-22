IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_DeleteMacro]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_DeleteMacro]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
/* usp_deleteMacro for deleting macro. Only called by SubmitMacroForDeletionApproval
* Jay He 4/4/2003
*/

CREATE PROCEDURE [dbo].[usp_DeleteMacro]
(
	@MacroID 	uniqueidentifier,
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
	  (@MacroID IS NULL) OR (NOT EXISTS (SELECT MacroID FROM CancerGovStaging..TSMacros WHERE MacroID= @MacroID)) 
	  )	
	BEGIN
		RAISERROR ( 70001, 16, 1)
		RETURN 70001
	END

	
	BEGIN TRAN Tran_DeleteList

		/*	
		** Delete Synonym from the  BestBetSynonyms  table 
		*/
		DELETE FROM  CancerGovStaging..TSMacros 
		WHERE MacroID = @MacroID
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN  Tran_DeleteList
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 	
		/*
		** Delete category from the BestBetCategories table 
		*/
	
		if(	
		 EXISTS (SELECT MacroID FROM CancerGov..TSMacros WHERE MacroID = @MacroID)
		 )	
		BEGIN
			DELETE FROM  CancerGov..TSMacros 
			WHERE MacroID = @MacroID
			IF (@@ERROR <> 0)
			BEGIN
				ROLLBACK TRAN  Tran_DeleteList
				RAISERROR ( 70004, 16, 1)
				RETURN 70004
			END 	

		END

	COMMIT TRAN  Tran_DeleteList

	SET NOCOUNT OFF
	RETURN 0 

END
GO
GRANT EXECUTE ON [dbo].[usp_DeleteMacro] TO [webadminuser_role]
GO
