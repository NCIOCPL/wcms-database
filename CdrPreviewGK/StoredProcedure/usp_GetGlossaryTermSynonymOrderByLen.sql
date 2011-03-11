IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetGlossaryTermSynonymOrderByLen]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetGlossaryTermSynonymOrderByLen]
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
CREATE PROCEDURE dbo.usp_GetGlossaryTermSynonymOrderByLen
AS
BEGIN
	SELECT Synonym FROM GlossaryTermSynonym ORDER BY LEN(Synonym) DESC
END


GO
GRANT EXECUTE ON [dbo].[usp_GetGlossaryTermSynonymOrderByLen] TO [webAdminUser_role]
GO
