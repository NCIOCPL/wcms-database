IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_updateTypepriority]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_updateTypepriority]
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
CREATE PROCEDURE dbo.usp_updateTypepriority
(
	@DisplayPosition		int,
	@TypeID			int
)
AS
BEGIN
	SET NOCOUNT OFF;

	UPDATE TrialTypeManualList 
	SET 	DisplayPosition = @DisplayPosition 
	WHERE TypeID = @TypeID
	IF (@@ERROR <> 0)
	BEGIN
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 
	SET NOCOUNT OFF
	RETURN 0 

END


GO
GRANT EXECUTE ON [dbo].[usp_updateTypepriority] TO [webAdminUser_role]
GO
