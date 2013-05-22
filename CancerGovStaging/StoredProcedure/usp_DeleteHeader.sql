IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_DeleteHeader]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_DeleteHeader]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/* usp_deleteMacro for deleting macro. Only called by SubmitMacroForDeletionApproval
* Jay He 4/4/2003
*/

CREATE PROCEDURE [dbo].[usp_DeleteHeader]
(
	@HeaderID 	uniqueidentifier,
	@UpdateUserID varchar(50) 
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
	  (@HeaderID  IS NULL) OR (NOT EXISTS (SELECT HeaderID  FROM CancerGovStaging..Header WHERE HeaderID = @HeaderID )) 
	  )	
	BEGIN
		RAISERROR ( 70001, 16, 1)
		RETURN 70001
	END

	
	BEGIN TRAN Tran_DeleteList

		/*	
		** Delete Synonym from the  BestBetSynonyms  table 
		*/
		Delete from CancerGovStaging..Header 
		where HeaderId=@HeaderID
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
		 EXISTS (SELECT HeaderID FROM CancerGov..Header where HeaderId=@HeaderID)
		 )	
		BEGIN
			Delete from CancerGov..Header where HeaderId=@HeaderID
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
GRANT EXECUTE ON [dbo].[usp_DeleteHeader] TO [webadminuser_role]
GO
