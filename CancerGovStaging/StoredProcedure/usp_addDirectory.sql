IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_addDirectory]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_addDirectory]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** 	Object:  Stored Procedure dbo.dbo.usp_addDirectory -- Jay He
	Purpose: This script can be used for adding Search. This will be a transactional script, which creates a nciview and several viewobjects in document table.
	Script Date: 12/27/2002 15:43:49 pM ******/

CREATE PROCEDURE dbo.usp_addDirectory
(
	@DirectoryName 	VarChar(255),
	@UpdateUserID		VarChar(40),
	@SectionID		UniqueIdentifier
)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRAN Tran_AddEForm

	Declare @DirectoryID UniqueIdentifier
	
	if exists (select DirectoryID from Directories where DirectoryName = @DirectoryName)
	BEGIN
		select @DirectoryID= DirectoryID from Directories where DirectoryName = @DirectoryName
	END
	else  
	BEGIN
		SET @DirectoryID = newid()

		INSERT INTO Directories  (DirectoryID, DirectoryName, CreateDate, updateUserID, UpdateDate)
		VALUES
		(@DirectoryID, @DirectoryName, getdate(), @UpdateUserID, getdate())
		IF (@@ERROR <> 0)
		BEGIN
			ROLLBACK TRAN Tran_AddEForm
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 
	END

	INSERT INTO SectionDirectoryMap 
	(DirectoryID,SectionID, UpdateDate, UpdateUserID) 
	VALUES 
	(@DirectoryID, @SectionID, GETDATE(), @UpdateUserID)
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
GRANT EXECUTE ON [dbo].[usp_addDirectory] TO [webadminuser_role]
GO
