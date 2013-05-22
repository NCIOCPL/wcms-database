IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_EditSearch]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_EditSearch]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** 	Object:  Stored Procedure dbo.dbo.usp_addSearch -- Jay He
	Purpose: This script can be used for adding Search. This will be a transactional script, which creates a nciview and several viewobjects in document table.
	Script Date: 8/28/2002 15:43:49 pM ******/

CREATE PROCEDURE dbo.usp_EditSearch
(
	@DocumentID       	UniqueIdentifier,
	@UpdateUserID		VarChar(40),
	@xml			VarChar(4000),
	@Title			VarChar(200),
	@Short			VarChar(200)
)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRAN Tran_AddEForm
	/*
	** STEP - A
	** Update document viewobjects for the above-created view .
	*/		
	UPDATE Document 
	set 	data =@xml, 
		title = @Title,
		shortTitle =@Short,
		updateUserID=@UpdateUSerID, 
		UpdateDate=getdate()
	WHERE DocumentID =@DocumentID
	IF (@@ERROR <> 0)
	BEGIN
			ROLLBACK TRAN Tran_AddEForm
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
	END 

	COMMIT TRAN Tran_AddEForm
	SET NOCOUNT OFF
	RETURN 0 

END
GO
GRANT EXECUTE ON [dbo].[usp_EditSearch] TO [webadminuser_role]
GO
