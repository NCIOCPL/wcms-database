IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetTrialTypes]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetTrialTypes]
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
CREATE PROCEDURE dbo.usp_GetTrialTypes
AS
BEGIN
	select typeID, displayname, displayposition from TrialTypeManualList order by displayposition
END


GO
GRANT EXECUTE ON [dbo].[usp_GetTrialTypes] TO [webAdminUser_role]
GO
