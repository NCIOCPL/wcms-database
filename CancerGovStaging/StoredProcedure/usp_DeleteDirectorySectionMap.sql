IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_DeleteDirectorySectionMap]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_DeleteDirectorySectionMap]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/* usp_deleteMacro for deleting macro. Only called by SubmitMacroForDeletionApproval
* Jay He 4/4/2003
*/

CREATE PROCEDURE [dbo].[usp_DeleteDirectorySectionMap]
(
	@DirectoryID	 	uniqueidentifier,
	@SectionID		uniqueidentifier
)
AS
BEGIN	
	SET NOCOUNT ON;

	delete from SectionDirectoryMap where DirectoryID=@DirectoryID  and SectionID =@SectionID	
	IF (@@ERROR <> 0)
	BEGIN
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 	
	
	SET NOCOUNT OFF
	RETURN 0 

END
GO
GRANT EXECUTE ON [dbo].[usp_DeleteDirectorySectionMap] TO [webadminuser_role]
GO
