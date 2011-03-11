IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_deleteDirectory]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_deleteDirectory]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** 	Object:  Stored Procedure dbo.dbo.usp_deleteDirectory -- Jay He
	Purpose: This script can be used for adding Search. This will be a transactional script, which creates a nciview and several viewobjects in document table.
	Script Date: 12/27/2002 15:43:49 pM ******/

CREATE PROCEDURE dbo.usp_deleteDirectory
(
	@DirectoryID	UniqueIdentifier
)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRAN Tran_AddEForm

	Delete from SectionDirectoryMap where DirectoryID =@DirectoryID
	IF (@@ERROR <> 0)
	BEGIN
			ROLLBACK TRAN Tran_AddEForm
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
	END

	Delete from Directories  where DirectoryID=@DirectoryID
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
GRANT EXECUTE ON [dbo].[usp_deleteDirectory] TO [webadminuser_role]
GO
