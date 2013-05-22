IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_insertTrialType]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_insertTrialType]
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
CREATE PROCEDURE dbo.usp_insertTrialType
(
	@DisplayName 	varchar(255)
)
AS
BEGIN
	Declare @DisplayPosition int

	if (exists(select 1 from TrialTypeManualList))
	BEGIN
		select @DisplayPosition = max(DisplayPosition) + 1 from TrialTypeManualList
	END
	ELSE
	BEGIN
		select @DisplayPosition= 1
	END

	SET NOCOUNT ON;


	INSERT INTO TrialTypeManualList (DisplayName, DisplayPosition)
	VALUES 
	(@DisplayName, @DisplayPosition)
	IF (@@ERROR <> 0)
	BEGIN
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 

	SET NOCOUNT OFF
	RETURN 0 

END


GO
GRANT EXECUTE ON [dbo].[usp_insertTrialType] TO [webAdminUser_role]
GO
