IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_deleteTrialType]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_deleteTrialType]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO

/**********************************************************************************

	Object's name:	usp_InsertBestBetCategory
	Object's type:	Stored Procedure
	Purpose:	Insert data
	Change History:	02-11-03	Jay He	
			11/04/2004	Lijia add ChangeComments

**********************************************************************************/
CREATE PROCEDURE dbo.usp_deleteTrialType
(
	@TypeID 	int
)
AS
BEGIN
	SET NOCOUNT ON;

	Delete from TrialTypeManualList Where TypeID = @TypeID	

	SET NOCOUNT OFF
	RETURN 0 

END


GO
GRANT EXECUTE ON [dbo].[usp_deleteTrialType] TO [webAdminUser_role]
GO
