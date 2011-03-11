IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetGlossaryTermSynonym]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetGlossaryTermSynonym]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO

/**********************************************************************************

	Object's name:	usp_GetGlossaryTermSynonym
	Object's type:	Stored Procedure
	Purpose:	Insert data
	Change History:	02-11-03	Jay He	

**********************************************************************************/
CREATE PROCEDURE dbo.usp_GetGlossaryTermSynonym
AS
BEGIN
	SELECT TermName, Synonym FROM GlossaryTermSynonym
END


GO
GRANT EXECUTE ON [dbo].[usp_GetGlossaryTermSynonym] TO [webAdminUser_role]
GO
