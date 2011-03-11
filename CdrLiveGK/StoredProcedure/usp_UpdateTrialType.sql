IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_UpdateTrialType]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_UpdateTrialType]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


/**********************************************************************************

	Object's name:	usp_UpdateBestBetsCategories  
	Object's type:	Stored Procedure
	Purpose:	Update Categories
	Change History:	7/16/2003	Jay He	
			11/04/2004	Lijia add ChangeComments

**********************************************************************************/

CREATE PROCEDURE dbo.usp_UpdateTrialType
(
	@TypeID		int,
	@DisplayName 	VarChar(255))
AS
BEGIN

	UPDATE  TrialTypeManualList
	set 	DisplayName		=	@DisplayName
	where 	TypeID = @TypeID
	IF (@@ERROR <> 0)
	BEGIN
		RAISERROR ( 70004, 16, 1)
		RETURN 70004
	END 

	RETURN 0 

END


GO
GRANT EXECUTE ON [dbo].[usp_UpdateTrialType] TO [webAdminUser_role]
GO
